using System;
using OpenTK;
using OpenTK.Graphics;
using OpenTK.Input;             // For Keyboard
using OpenTK.Graphics.OpenGL;   // For GL
using NLua;
using System.Drawing;

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

        public GameEngine() : base(1024, 768, GraphicsMode.Default, "C# + Lua + OpenGL Engine")
        {
            _graphicsRenderer = new GraphicsRenderer();

            // === Lua Setup ===
            _lua = new Lua();

            // Get the current working directory
            string projectRoot = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", ".."));
            if (projectRoot.Contains(@"\bin\Debug\net8.0"))
            {
                projectRoot = Path.GetFullPath(Path.Combine(projectRoot, Path.DirectorySeparatorChar.ToString()
                , Path.DirectorySeparatorChar.ToString()
                , Path.DirectorySeparatorChar.ToString()));
            }
            _luaFilePath = Path.Combine(projectRoot, "src", "game.lua");

            _redisQueue = new RedisQueue(_lua);
            _redisQueue.SetupBindings();

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
            _lua.DoString("init_logging()");

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
            _lua["clear"] = (Action<float, float, float>)_graphicsRenderer.ClearScreen;
            _lua["drawRect"] = (Action<float, float, float, float, float, float, float>)_graphicsRenderer.DrawRect;
            _lua["update"] = (Action<string>)UpdateState;

            _lua.DoString("current_scene = {}");
            // _lua["render_scene"] = (Action<string, string>)RenderTable;
            renderTable = _lua["initGame"] as LuaTable;

            var sceneData = new GenericScene(_luaProcessor.ProcessLuaQuery<Dictionary<string, ModelRGB>>("initGame"));
            RedrawScene(sceneData);
        }

        protected override void OnRenderFrame(FrameEventArgs e)
        {
            base.OnRenderFrame(e);

            // Check if lua is initialized
            if (_lua == null)
            {
                Console.WriteLine("Lua state is not initialized.");
                return; // Exit if lua is not ready
            }

            GL.Clear(ClearBufferMask.ColorBufferBit);

            // _luaProcessor.ProcessLuaNonQuery("update");

            var sceneData = new GenericScene(_luaProcessor.ProcessLuaQuery<Dictionary<string, ModelRGB>>("render_scene"));
            RedrawScene(sceneData);

            _lua.DoString("current_state = {}"); // Reset for next frame
            SwapBuffers();
        }

        protected override void OnUpdateFrame(FrameEventArgs e)
        {
            base.OnUpdateFrame(e);

            if (Keyboard.GetState().IsKeyDown(Key.F5))  // Or file watcher
            {
                _luaProcessor.ReloadScript();
            }

            if (Keyboard.GetState().IsKeyDown(Key.Escape))
                Close();

            if (Keyboard.GetState().IsKeyDown(Key.W))
                Close();

            if (Keyboard.GetState().IsKeyDown(Key.S))
                Close();

            if (Keyboard.GetState().IsKeyDown(Key.A))
                Close();

            if (Keyboard.GetState().IsKeyDown(Key.D))
                Close();

        }

        // FIXED: Resize event uses different args in OpenTK 3.3.3
        protected override void OnResize(EventArgs e)  // ← Changed from ResizeEventArgs
        {
            base.OnResize(e);
            GL.Viewport(0, 0, Width, Height);
        }

        void UpdateState(string state_name)
        {
            Console.WriteLine("State updated !");
        }

        void SetupGraphics(ISizable viewport)
        {
            _viewport = viewport;
            // Optionally, if you want to ensure the viewport matches the window size:
            // GL.Viewport(0, 0, viewportWidth, viewportHeight);

            // Output
            Console.WriteLine("Viewport size: " + viewport.Width + " x " + viewport.Height);

            _graphicsRenderer.InitGraphics(viewport as ISizable);
        }

        void RedrawScene(GenericScene sceneData)
        {
            foreach(var element in sceneData.Actors)
            {
                if (element is RectangleRGB)
                    _graphicsRenderer.DrawRect((element as RectangleRGB).x, (element as RectangleRGB).y, (element as RectangleRGB).w, (element as RectangleRGB).h,  element.r, element.g, element.b);
                else if (element is ClearRGB)
                    _graphicsRenderer.ClearScreen((element as ClearRGB).r, (element as ClearRGB).g, (element as ClearRGB).b);
                else if (element is CircleRGB)
                    _graphicsRenderer.DrawCircle((element as CircleRGB).x, (element as CircleRGB).y, (element as CircleRGB).rad, (element as CircleRGB).r, (element as CircleRGB).g, (element as CircleRGB).b);
                else if (element is ResourceBarRGB)
                    _graphicsRenderer.DrawBar((element as ResourceBarRGB).name, (element as ResourceBarRGB).current, (element as ResourceBarRGB).maximum, (element as ResourceBarRGB).percentage, (element as ResourceBarRGB).r, (element as ResourceBarRGB).g, (element as ResourceBarRGB).b);
                // else graphicsRenderer.DrawText("Element unindentified", element.x, element.y,1, element.r, element.g, element.b);
            }
        }
    }
}
