using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.Swagger;
using Swashbuckle.AspNetCore.SwaggerGen;
using MinimalEngineApi.Data;
using MinimalEngineApi.Models;

var builder = WebApplication.CreateBuilder(args);

// ── Add services ────────────────────────────────────────────────
builder.Services.AddControllers();

// EF Core + SQLite (file will be created in bin/Debug/net8.0/)
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
app.MapControllers();

// ── Simple test endpoint ────────────────────────────────────────
app.MapGet("/health", () => "OK");
app.Run();
