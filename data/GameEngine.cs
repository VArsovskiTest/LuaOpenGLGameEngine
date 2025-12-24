using System;
using OpenTK;
using OpenTK.Graphics;
using OpenTK.Input;             // For Keyboard
using OpenTK.Graphics.OpenGL;   // For GL
using NLua;

namespace LuaOpenGLGameEngine
{
    public class GameEngine : GameWindow
    {
        private Lua _lua;
        private LuaProcessor _luaProcessor { get; set; }
        private LuaTable renderTable;
        private GraphicsRenderer graphicsRenderer;
        private string _luaFilePath;

        private EngineState _state { get; set; }

        private RedisQueue _redisQueue { get; set; }

        public GameEngine() : base(1024, 768, GraphicsMode.Default, "C# + Lua + OpenGL Engine")
        {
            graphicsRenderer = new GraphicsRenderer();

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
            graphicsRenderer.InitGraphics();

            // Register converters for Lua base types
            JsonSettingsFactory.RegisterDiscriminatorConverter<ModelRGB>("type");

            _lua.LoadCLRPackage();

            // Bind Scene objects to Graphics
            _lua["clear"] = (Action<float, float, float>)graphicsRenderer.ClearScreen;
            _lua["drawRect"] = (Action<float, float, float, float, float, float, float>)graphicsRenderer.DrawRect;

            // Bind Scripts
            _lua.DoString("current_scene = {}");
            //_lua["render_scene"] = (Action<string, string>)RenderTable;
            _lua["update"] = (Action<string>)UpdateState;
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

            new LuaProcessor(_lua, _luaFilePath).ProcessLuaNonQuery("update");

            var sceneData = new GenericScene(new LuaProcessor(_lua, _luaFilePath).ProcessLuaQuery<Dictionary<string, ModelRGB>>("render_scene"));
            RedrawScene(sceneData);

            _lua.DoString("render = {}"); // Reset for next frame
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

        void RedrawScene(GenericScene sceneData)
        {
            foreach(var element in sceneData.Actors)
            {
                if (element is RectangleRBG)
                    graphicsRenderer.DrawRect((element as RectangleRBG).x, (element as RectangleRBG).y, (element as RectangleRBG).w, (element as RectangleRBG).h,  element.r, element.g, element.b);
                else graphicsRenderer.ClearScreen(element.r, element.g, element.b);
            }            
        }
    }
}
