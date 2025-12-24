using OpenTK;

namespace LuaOpenGLGameEngine
{
    internal class Program
    {
        static void Main(string[] args)
        {
            using (var engine = new GameEngine())
            {
                engine.Run(); // This starts the loop (60 FPS by default)
            }
        }
    }
}
