using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.OpenApi.Models;
using MinimalEngineApi.Data;
using MinimalEngineApi.Models;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;
using Swashbuckle.AspNetCore.Swagger;
using Swashbuckle.AspNetCore.SwaggerGen;
using System.Data.Common;
using System.Text.Json;

public class Program
{
    public static void Main(string[] args)
    {
        // var builder = WebApplication.CreateBuilder(args);
        var builder = WebApplication.CreateBuilder(new WebApplicationOptions
        {
            Args = args,
            ContentRootPath = AppContext.BaseDirectory // Optional if you have wwwroot copied there too: WebRootPath = Path.Combine(AppContext.BaseDirectory, "wwwroot")
        });

        var cfg = builder.Configuration;
        Console.WriteLine("Environment name       : " + builder.Environment.EnvironmentName);
        Console.WriteLine("DefaultConnection      : " + cfg.GetConnectionString("DefaultConnection"));
        Console.WriteLine("ConnectionStrings:Default: " + cfg["ConnectionStrings:DefaultConnection"]);
        Console.WriteLine("ConnectionStrings      : " + cfg["ConnectionStrings"]);

#if DEBUG
        builder.Environment.EnvironmentName = "Development";   // force it for debugging purposes
        // --- DEBUGGING CODE ---
        Console.WriteLine("--- Full Configuration Dump ---");
        Console.WriteLine(builder.Configuration.GetDebugView());
        Console.WriteLine("------------------------------");

        var basePath = Directory.GetCurrentDirectory();
        Console.WriteLine("ContentRootPath: " + builder.Environment.ContentRootPath);
        Console.WriteLine("CurrentDirectory: " + Directory.GetCurrentDirectory());
        Console.WriteLine("BaseDirectory (bin folder): " + AppContext.BaseDirectory);

        // Check if file would be found at content root
        var jsonPath = Path.Combine(builder.Environment.ContentRootPath, "appsettings.json");
        Console.WriteLine($"appsettings.json expected at: {jsonPath}");
        Console.WriteLine(File.Exists(jsonPath) ? "→ Exists" : "→ NOT found");

#endif

        // For boostrapping router for distributed use later: mysqlrouter --bootstrap root@localhost:3310 --directory /path/to/router-config
        var defaultConnection = builder.Configuration.GetConnectionString("DefaultConnection");
        defaultConnection = ConnectionStringBuilder.GetConnectionString(defaultConnection); // update connection from Env_variable

        builder.Services.AddDbContext<AppDbContext>(options =>
            options.UseMySql(defaultConnection, ServerVersion.AutoDetect(defaultConnection)));

        // builder.Services.AddControllers();
        builder.Services.AddControllers().AddJsonOptions(options =>
        {
            options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
            //// Optional: also nice defaults
            //options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
            //options.JsonSerializerOptions.WriteIndented = true; // for debugging
        });

        // Add this early in the services section
        builder.Services.AddCors(options =>
        {
            options.AddPolicy("AllowEditorFrontend", policy =>
            {
                policy.WithOrigins(//"*"
                    "http://localhost:4200",          // Angular port
                    "https://localhost:4200",
                    // "http://minimal-editor-api.local:4400/",
                    // "https://minimal-editor-api.local:4401/",
                    "http://127.0.0.1:4200",          // sometimes browsers use this
                    "http://your-machine-name:4200"   // if accessing via network
                                                      //Add production origins later, e.g. "https://minimal-api-engine-domain.com"
                )
                .AllowAnyHeader()
                .AllowAnyMethod()
                .AllowCredentials();
            });
        });

        // Swagger
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen(c =>
        {
            c.SwaggerDoc("v1", new OpenApiInfo { Title = "Scene Editor API", Version = "v1" });
        });

        // builder.Services.AddHttpsRedirection(options =>
        // {
        //     options.HttpsPort = 4401;
        //     options.RedirectStatusCode = StatusCodes.Status307TemporaryRedirect; // optional
        // });

        var app = builder.Build();

        // ── Middleware pipeline ─────────────────────────────────────────
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        // app.UseHttpsRedirection();
        app.UseAuthorization();
        app.UseCors("AllowEditorFrontend");  // ← MUST come before UseAuthorization / MapControllers
        app.MapControllers();

        // ── Simple test endpoint ────────────────────────────────────────
        app.MapGet("/health", () => "OK");
        app.Run();
    }

    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(webBuilder =>
            {
                // webBuilder.UseStartup<Startup>();
            });
}
