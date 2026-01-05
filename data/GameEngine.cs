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

        private ISizable _viewport { get; set; }// = new ViewPort { Width = 0, Height = 0 };

        private EngineState _state { get; set; }
        private RedisQueue _redisQueue { get; set; }

        private MouseClickHandler _mouseClickHandler { get; set; }

        private GenericScene _currentScene { get; set; }

        #region BaseSetup & Rendering

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
            _lua.DoString("game.log_handler.init_logging()");
            _lua.DoString("game.log_handler.init_error_logging()");

            if (redisConfig.IsAvailable())
            {
                _lua.DoString("game.setup_command_queue()");
            }

            // === Set State ===
            _state = new EngineState(_lua);
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
            _lua["clear"] = (Action<IColorable>)_graphicsRenderer.ClearScreen;
            _lua["drawRect"] = (Action<float, float, float, float, IColorable>)_graphicsRenderer.DrawRect;
            _lua["update"] = (Action<string>)UpdateState;

            _lua.DoString("current_scene = {}");
            renderTable = _lua["initGame"] as LuaTable;

            LuaTable luaResult = _lua.DoString("return game.render_scene()").First() as LuaTable;
            _currentScene = GenericScene.FromLuaTable(luaResult);

            RedrawScene(_currentScene);
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
            _currentScene = GenericScene.FromLuaTable(luaResult);

            RedrawScene(_currentScene);

            // Reset (only when changing level or game-over, i.e. globalStateChange)
            // if (globalStateChange) _lua.DoString("return clear_current_scene()");

            SwapBuffers();
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

        void SetupGraphics(ISizable viewport)
        {
            _viewport = viewport;
            // Optionally, if you want to ensure the viewport matches the window size:
            // GL.Viewport(0, 0, viewportWidth, viewportHeight);

            // Output
            Console.WriteLine("Viewport size: " + viewport.Width + " x " + viewport.Height);

            _graphicsRenderer.InitGraphics();
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

        private ActorRGB? hoveredActor = null;
        private ActorRGB? selectedActor = null;

        void UpdateState(string state_name)
        {
            Console.WriteLine("State updated !");
        }

        #region Interaction & Handlers

        protected override void OnUpdateFrame(FrameEventArgs e)
        {
            base.OnUpdateFrame(e);

            var base_move_speed = 1.9;

            var pickedActor = selectedActor ?? null;

            if (Keyboard.GetState().IsKeyDown(Key.F5))  // Or file watcher
            {
                _luaProcessor.ReloadScript();
            }

            if (Keyboard.GetState().IsKeyDown(Key.Escape))
                Close();

            if (pickedActor != null)
            {
                var move_up = Keyboard.GetState().IsKeyDown(Key.W) || Keyboard.GetState().IsKeyDown(Key.Up);
                var move_down = Keyboard.GetState().IsKeyDown(Key.S) || Keyboard.GetState().IsKeyDown(Key.Down);
                var move_left = Keyboard.GetState().IsKeyDown(Key.A) || Keyboard.GetState().IsKeyDown(Key.Left);
                var move_right = Keyboard.GetState().IsKeyDown(Key.D) || Keyboard.GetState().IsKeyDown(Key.Right);

                var move_direction = move_up ? "up"
                    : move_down ? "down"
                    : move_left ? "left"
                    : "right";

                if (move_up || move_down || move_left || move_right) {
                    _lua.DoString($"game.move_actor_by_id(\"{pickedActor.Id}\", \"{move_direction}\", \"{base_move_speed}\")");
                }
            }
        }

        protected override void OnMouseDown(MouseButtonEventArgs e)
        {
            base.OnMouseDown(e);

            if (e.Button == MouseButton.Left && e.IsPressed) // Only on press down
            {
                var pickedActor = _mouseClickHandler.SelectActor(_currentScene, e.Position.X, e.Position.Y, (int)_viewport.Width, (int)_viewport.Height);
                if (pickedActor != null)
                {
                    var actor = _currentScene.Actors.First(i => i.Id == pickedActor.Id);
                    selectedActor = actor;
                    bool newSelected = !actor.selected;
                    actor.selected = newSelected;

                    _lua.DoString(string.Format("game.select_actor_by_id(\"{0}\", {1})",
                        pickedActor.Id.ToString(),
                        newSelected ? "true" : "false"));
                }
            }
        }

        // Optional: Hover support
        protected override void OnMouseMove(MouseMoveEventArgs e)
        {
            base.OnMouseMove(e);

            ActorRGB? pickedActor = _mouseClickHandler.SelectActor(_currentScene, e.Position.X, e.Position.Y, (int)_viewport.Width, (int)_viewport.Height);

            if (pickedActor != null)
            {
                hoveredActor = pickedActor;
                // _currentScene.Actors.First(i => i.Id == pickedActor.Id).selected = true;
            }

            // TODO: Adjust/add mouse cursor manipulation feature
            // Cursor = pickedActor != null ? MouseCursor.Arrow : MouseCursor.Default;
        }

        // Keyboard example (you mentioned it's already there)
        protected override void OnKeyDown(KeyboardKeyEventArgs e)
        {
            base.OnKeyDown(e);

            // if (e.Key == Keys.Escape)
            //     Close();
            // // ... other keys
        }

        #endregion
    }
}
