using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.Swagger;
using Swashbuckle.AspNetCore.SwaggerGen;
using MinimalEngineApi.Data;
using MinimalEngineApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add this early in the services section
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowEditorFrontend", policy =>
    {
        policy.WithOrigins("*"
            // "http://localhost:4200",          // Angular port
            // "https://localhost:4200",
            // "http://127.0.0.1:4200",          // sometimes browsers use this
            // "http://your-machine-name:4200"   // if accessing via network
            // Add production origins later, e.g. "https://minimal-api-engine-domain.com"
        )
        .AllowAnyHeader()
        .AllowAnyMethod();
        //.AllowCredentials();
    });
});

builder.Services.AddControllers();

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite("Data Source=scenes.db"));

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Scene Editor API", Version = "v1" });
});

var app = builder.Build();

// ── Middleware pipeline ─────────────────────────────────────────
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.UseCors("AllowEditorFrontend");  // ← MUST come before UseAuthorization / MapControllers
app.MapControllers();

// ── Simple test endpoint ────────────────────────────────────────
app.MapGet("/health", () => "OK");
app.Run();
