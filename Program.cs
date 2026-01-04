using OpenTK;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualBasic;
using System.ComponentModel.Design;

namespace LuaOpenGLGameEngine
{
    internal class Program
    {
        static void Main(string[] args)
        {
            var host = new HostBuilder()
                .ConfigureAppConfiguration((context, configBuilder) =>
                {
                    configBuilder
                        .SetBasePath(Directory.GetCurrentDirectory())
                        .AddJsonFile("appsettings.json", optional: true)
                        .AddJsonFile($"appsettings.{context.HostingEnvironment.EnvironmentName}.json", optional: true);
                })
                .ConfigureServices((context, services) =>
                {
                    services.AddSingleton<RedisConfig>();
                    services.AddSingleton<GameEngine>();
                })
                .Build();

            var game = host.Services.GetRequiredService<GameEngine>();
            game.Run();

            host.Run();
        }
    }
}
