using System;
using OpenTK;
using OpenTK.Graphics;
using OpenTK.Input;             // For Keyboard
using OpenTK.Graphics.OpenGL;   // For GL
using NLua;
using System.Drawing;
using System.Text.Json;
using System.Security.Cryptography.X509Certificates;

namespace LuaOpenGLGameEngine
{
    public class GameEngine : GameWindow
    {
        private Lua _lua;
        private LuaProcessor _luaProcessor { get; set; }
        private GraphicsRenderer _graphicsRenderer;
        private string _luaFilePath;
        private LuaTable renderTable;

        private System.Timers.Timer _gameSpanTimer { get; set; }
        private System.Timers.Timer _periodTimer { get; set; }

        private ISizable _viewport { get; set; }// = new ViewPort { Width = 0, Height = 0 };

        private EngineState _state { get; set; }
        public GameState _gameState { get; set; }
        private RedisQueue _redisQueue { get; set; }

        private MouseClickHandler _mouseClickHandler { get; set; }

        private GenericScene _currentScene { get; set; }

        #region Base setup

        public GameEngine(RedisConfig redisConfig) : base(1024, 768, GraphicsMode.Default, "C# + Lua + OpenGL Engine")
        {
            _graphicsRenderer = new GraphicsRenderer();

            // === Lua Setup ===
            _lua = new Lua();

            _redisQueue = new RedisQueue(redisConfig, _lua);
            _redisQueue.SetupBindings();

            // Get the current working directory
            string projectRoot = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", ".."));
            if (projectRoot.Contains(@"\bin\Debug\net8.0"))
            {
                projectRoot = Path.GetFullPath(Path.Combine(projectRoot, Path.DirectorySeparatorChar.ToString()
                , Path.DirectorySeparatorChar.ToString()
                , Path.DirectorySeparatorChar.ToString()));
            }
            _luaFilePath = Path.Combine(projectRoot, "src", "game.lua");

            _mouseClickHandler = new MouseClickHandler();

            // === CRITICAL: Load the Lua script FIRST ===
            if (File.Exists(_luaFilePath))
            {
                _lua.DoFile(_luaFilePath);  // ← This executes game.lua and defines init_logging(), log(), etc.
                Console.WriteLine("game.lua loaded successfully.");
            }
            else
            {
                Console.WriteLine($"ERROR: game.lua not found at {_luaFilePath}");
                return;
            }

            _luaProcessor = new LuaProcessor(_lua, _luaFilePath);

            // -- Initialize Logging: Once
            _lua.DoString("game.init_logging()");
            _lua.DoString("game.init_error_logging()");

            if (redisConfig.IsAvailable())
            {
                _lua.DoString("game.setup_command_queue()");
            }

            // === Set State ===
            _gameState = new GameState(_lua);
            _state = new EngineState(_lua);
            _periodTimer = new System.Timers.Timer(500); //Loop event/update once per 500ms
            _periodTimer.Elapsed += UpdateTimedEvent;
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            // == Setup Graphics ==
            ISizable currentViewport = new Viewport { Width = this.Width, Height = this.Height };
            SetupGraphics(currentViewport);

            // Register converters for Lua base types
            JsonSettingsFactory.RegisterDiscriminatorConverter<ModelRGB>("type");

            _lua.LoadCLRPackage();

            // Bind Scripts
            // _lua["clear"] = (Action<IColorable>)_graphicsRenderer.ClearScreen;
            // _lua["drawRect"] = (Action<float, float, float, float, IColorable>)_graphicsRenderer.DrawRect;
            // _lua["update"] = (Action<string>)UpdateState;
            renderTable = _lua["initGame"] as LuaTable;

            _lua.DoString("initEngine()"); // Initialize ONCE
            _lua.DoString("current_scene = {}");

            LuaTable luaResult = _lua.DoString("return initGame()").First() as LuaTable;
            _currentScene = GenericScene.FromLuaTable(_lua, luaResult);

            RedrawScene(_currentScene);
        }

        // FIXED: Resize event uses different args in OpenTK 3.3.3
        protected override void OnResize(EventArgs e)  // ← Changed from ResizeEventArgs
        {
            base.OnResize(e);

            // var width = e.target.Bounds.Width;
            // var height = e.target.Bounds.Height;
            // var left = e.target.Bounds.Left;
            // var right = e.target.Bounds.Right;

            _viewport.Width = Width;
            _viewport.Height = Height;
            GL.Viewport(0, 0, Width, Height);
        }

        #endregion

        #region GameState Logic

        // private ActorRGB? hoveredActor = null;
        // private ActorRGB? selectedActor = null;

        void UpdateState(string state_name)
        {
            Console.WriteLine("State updated !");
        }

        void UpdateTimedEvent(object sender, EventArgs e)
        {
            _lua.DoString("game.tick_all_resource_bars()");
        }

        #endregion

        #region Interaction & Handlers

        #region Graphics

        void SetupGraphics(ISizable viewport)
        {
            _viewport = viewport;
            // Optionally, if you want to ensure the viewport matches the window size:
            // GL.Viewport(0, 0, viewportWidth, viewportHeight);

            // Output
            Console.WriteLine("Viewport size: " + viewport.Width + " x " + viewport.Height);

            _graphicsRenderer.InitGraphics();
        }

        protected override void OnRenderFrame(FrameEventArgs e)
        {
            base.OnRenderFrame(e);

            if (_lua == null)
            {
                Console.WriteLine("Lua state is not initialized.");
                return;
            }

            GL.Clear(ClearBufferMask.ColorBufferBit);

            // Pull the latest scene state from Lua — this reflects all updates!
            LuaTable luaResult = _lua.DoString("return game.get_current_scene()").First() as LuaTable;
            _currentScene = GenericScene.FromLuaTable(_lua, luaResult);

            RedrawScene(_currentScene);

            // Reset (only when changing level or game-over, i.e. globalStateChange)
            // if (globalStateChange) _lua.DoString("return clear_current_scene()");

            SwapBuffers();
        }

        void RedrawScene(GenericScene sceneData)
        {
            // 1. Handle clears (there should be only one usually)
            foreach (var clear in sceneData.Clears)
            {
                _graphicsRenderer.ClearScreen(clear.Color);
            }

            // 2. Debug crosshair
            _graphicsRenderer.DrawLine(-0.1f, 0f, 0.1f, 0f, new RGBColor { r = 1f, g = 0f, b = 0f });
            _graphicsRenderer.DrawLine(0f, -0.1f, 0f, 0.1f, new RGBColor { r = 1f, g = 0f, b = 0f });

            // 3. Draw all actors with hover/selection
            foreach (var actor in sceneData.Actors)
            {
                // Draw main shape
                switch (actor)
                {
                    case RectangleRGB rect:
                        _graphicsRenderer.DrawRect(rect.X, rect.Y, rect.Width, rect.Height, rect.Color);
                        break;

                    case CircleRGB circle:
                        _graphicsRenderer.DrawCircle(circle.X, circle.Y, circle.rad, circle.Color);
                        break;

                    case ResourceBarRGB bar:
                        _graphicsRenderer.DrawBar(
                            bar.Name,
                            bar.Current,
                            bar.Maximum,
                            bar.Percentage / 500f,
                            bar.Thickness,
                            bar.X,
                            bar.Y,
                            bar.Color);
                        break;

                    default:
                        _graphicsRenderer.DrawText("Unknown actor", 0.05f, 0.05f, 1f, new RGBColor { r = 1f, g = 0f, b = 0f });
                        break;
                }

                // Draw hover/selection outline
                bool shouldHighlight = actor.hovered || actor.selected;

                if (shouldHighlight &&
                    actor is IPlaceable placeable &&
                    actor is ISizable sizable)
                {
                    float brightness = actor.selected ? 1.5f : 1.2f;
                    float outlineW = sizable.Width + 0.02f;
                    float outlineH = sizable.Height + 0.02f;

                    _graphicsRenderer.DrawRect(
                        placeable.X, placeable.Y,
                        outlineW, outlineH,
                        new RGBColor { r = actor.Color.r, g = actor.Color.g, b = actor.Color.b });
                }
            }

            // 4. Overlay text (always on top)
            var textColorLegend = new RGBColor { r = 1f, g = 0f, b = 0f };
            _graphicsRenderer.DrawText("TL", -0.95f, 0.95f, 5.5f, textColorLegend);
            _graphicsRenderer.DrawText("TR", 0.80f, 0.95f, 5.5f, textColorLegend);
            _graphicsRenderer.DrawText("BL", -0.95f, -0.95f, 5.5f, textColorLegend);
            _graphicsRenderer.DrawText("BR", 0.80f, -0.95f, 5.5f, textColorLegend);
            _graphicsRenderer.DrawText(JsonSerializer.Serialize(_viewport), 0.05f, 0.05f, 5.5f, textColorLegend);
        }

        #endregion

        protected override void OnUpdateFrame(FrameEventArgs e)
        {
            if (Keyboard.GetState().IsKeyDown(OpenTK.Input.Key.F5))  // Or file watcher
                _luaProcessor.ReloadScript();

            if (Keyboard.GetState().IsKeyDown(OpenTK.Input.Key.Escape))
                Close();

            LuaTable gameStateTable = _gameState.GetLuaTableData();
            _lua.GetFunction("game_tick").Call(gameStateTable);
            base.OnUpdateFrame(e);
        }

        protected override void OnMouseDown(MouseButtonEventArgs e)
        {
            base.OnMouseDown(e);

            if (e.Button == MouseButton.Left && e.IsPressed) // Only on press down
            {
                var (cx, cy) = _mouseClickHandler.MouseToNdc(e.Position.X, e.Position.Y, (int)_viewport.Width, (int)_viewport.Height);
                var pickedActor = _mouseClickHandler.SelectActor(_currentScene, e.Position.X, e.Position.Y, (int)_viewport.Width, (int)_viewport.Height);
                if (pickedActor != null)
                {
                    var actor = _currentScene.Actors.First(i => i.Id == pickedActor.Id).AsActorState();
                    actor.TargetX = cx;
                    actor.TargetY = cy;

                    bool newSelected = !actor.Selected;
                    actor.Selected = newSelected;

                    _gameState.CurrentActor = actor;
                    _gameState.UpdateActor(actor);  
                }
            }
        }

        // Optional: Hover support
        protected override void OnMouseMove(MouseMoveEventArgs e)
        {
            base.OnMouseMove(e);
            var pickedActor = _mouseClickHandler.SelectActor(_currentScene, e.Position.X, e.Position.Y, (int)_viewport.Width, (int)_viewport.Height)?.AsActorState();

            if (pickedActor != null)
            {
                _gameState.CurrentActor = pickedActor;
                _gameState.UpdateActor(pickedActor);
            }
        }

        // Keyboard example (you mentioned it's already there)
        protected override void OnKeyDown(KeyboardKeyEventArgs e)
        {
            base.OnKeyDown(e);

            // Get fresh keyboard state
            _gameState.KeyboardState = GetKeyboardState(Keyboard.GetState());            

            var base_move_speed = 1.9;
            var pickedActor = _gameState.GetSelectedActor();
            // _lua.DoString($"Keyboard.isPressed['{keyName}'] = true");
            // _lua.GetFunction("Keyboard_update_from_csharp")?.Call();

            if (pickedActor != null)
            {
                pickedActor.Selected = true;
                var move_up = Keyboard.GetState().IsKeyDown(Key.W) || Keyboard.GetState().IsKeyDown(OpenTK.Input.Key.Up);
                var move_down = Keyboard.GetState().IsKeyDown(Key.S) || Keyboard.GetState().IsKeyDown(OpenTK.Input.Key.Down);
                var move_left = Keyboard.GetState().IsKeyDown(Key.A) || Keyboard.GetState().IsKeyDown(OpenTK.Input.Key.Left);
                var move_right = Keyboard.GetState().IsKeyDown(Key.D) || Keyboard.GetState().IsKeyDown(OpenTK.Input.Key.Right);

                var move_direction = move_up ? "up"
                    : move_down ? "down"
                    : move_left ? "left"
                    : "right";
                
                var currentX = (pickedActor as IPlaceable).X;
                var currentY = (pickedActor as IPlaceable).Y;

                var newX = move_direction == "left" ? currentX - base_move_speed : move_direction == "right" ? currentX + base_move_speed : currentX;
                var newY = move_direction == "up" ? currentY - base_move_speed : move_direction == "down" ? currentY + base_move_speed : currentY;

                if (move_up || move_down || move_left || move_right) {
                    pickedActor.X = (float)newX;
                    pickedActor.Y = (float)newY;

                    _gameState.UpdateActor(pickedActor);
                }
                _gameState.CurrentActor = pickedActor;
            }
        }

        #endregion

        private static Dictionary<string, Key> keyMapping = new Dictionary<string, Key>()
        {
            { "w" , Key.W },
            { "a" , Key.A },
            { "s" , Key.S },
            { "d" , Key.D },
            { "j" , Key.J },
            { "k" , Key.K },
            { "l" , Key.L },
            { "q" , Key.Q },
            { "e" , Key.E },
            { "c" , Key.C },
            { "v" , Key.V },
            { "tab" , Key.Tab },
            { "space" , Key.Space },
            { "1" , Key.Number1 },
            { "2" , Key.Number2 },
            { "3" , Key.Number3 },
            { "4" , Key.Number4 },
            { "5" , Key.Number5 },
            { "6" , Key.Number6 },
            { "7" , Key.Number7 },
            { "8" , Key.Number8 },
            { "9" , Key.Number9 },
            { "0" , Key.Number0 }
        };

        private static KeyboardState GetKeyboardState(OpenTK.Input.KeyboardState state)
        {
            var keyboardState = new KeyboardState();

            foreach (var key in keyMapping)
                keyboardState.Keys.Add(new KeyValuePair<string, bool>(key.Key, state.IsKeyDown(key.Value)));

            return keyboardState;
        }
    }
}
