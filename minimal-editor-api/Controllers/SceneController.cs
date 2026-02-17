using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MinimalEngineApi.Data;
using MinimalEngineApi.Models;

[ApiController]
[Route("api/[controller]")]
public class ScenesController : ControllerBase
{
    private readonly AppDbContext _context;

    public ScenesController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IEnumerable<Scene>> GetScenes()
    {
        return _context.Scenes.ToList();
    }

    [HttpPost("{id?}"), HttpPut("{id?}")]
    public async Task<IActionResult> SaveScene([FromRoute] Guid? id, [FromBody] Scene scene)
    {
        if (id.HasValue)
        {
            var existing = await _context.Scenes.FindAsync(id.Value);
            if (existing == null) return NotFound();

            existing.Name = scene.Name;
            existing.Actors = scene.Actors;   // simplistic – in reality you'd merge/update
            existing.UpdatedAt = DateTime.UtcNow;
        }
        else
        {
            scene.CreatedAt = DateTime.UtcNow;
            scene.UpdatedAt = DateTime.UtcNow;
            _context.Scenes.Add(scene);
        }

        foreach(var actor in scene.Actors)
        {
            var existing = await _context.Actors.FindAsync(actor.Id);
            if (existing != null)
            {
                existing.Type = actor.Type;
                existing.X = actor.X;
                existing.Y = actor.Y;
                existing.SceneId = scene.Id;
                existing.Scene = scene;
                existing.UpdatedAt = DateTime.Now;
            }
            else
            {
                actor.CreatedAt = DateTime.Now;
                _context.Actors.Add(actor);
            }
        }

        await _context.SaveChangesAsync();
        return Ok(scene.Id);   // return new/existing ID
    }
}
