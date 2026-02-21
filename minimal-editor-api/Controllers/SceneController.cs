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
            var existing = await _context.Scenes
                .Include(s => s.Actors)
                .FirstOrDefaultAsync(s => s.Id == id.Value);

            if (existing == null) return NotFound();

            existing.Name = scene.Name;
            existing.UpdatedAt = DateTime.UtcNow;

            var incomingActorIds = scene.Actors.Select(a => a.Id).ToHashSet();
            var toRemove = existing.Actors.Where(ea => !incomingActorIds.Contains(ea.Id)).ToList();
            foreach (var actor in toRemove) { existing.Actors.Remove(actor); }

            foreach (var incoming in scene.Actors)
            {
                var existingActor = existing.Actors.FirstOrDefault(ea => ea.Id == incoming.Id);

                if (existingActor != null)
                {
                    // update existing child
                    existingActor.Type = incoming.Type;
                    existingActor.X = incoming.X;
                    existingActor.Y = incoming.Y;
                    existingActor.Color = incoming.Color;
                    existingActor.Transform = incoming.Transform;
                    existingActor.UpdatedAt = DateTime.UtcNow;
                }
                else
                {
                    var newActor = new Actor
                    {
                        Id = incoming.Id,     // assuming client sends stable IDs
                        Type = incoming.Type,
                        X = incoming.X,
                        Y = incoming.Y,
                        Color = incoming.Color,
                        Transform = incoming.Transform,
                        UpdatedAt = DateTime.UtcNow,
                    };
                    existing.Actors.Add(newActor);
                    _context.Entry(newActor).State = EntityState.Added; // Important, mark as new to prevent issues with Concurrency
                }
            }
        }
        else
        {
            scene.CreatedAt = DateTime.UtcNow;
            _context.Scenes.Add(scene);

            foreach (var actor in scene.Actors)
            {
                actor.CreatedAt = DateTime.Now;
                _context.Actors.Add(actor);
            }
        }

        await _context.SaveChangesAsync();
        return Ok(scene.Id);   // return new/existing ID
    }
}
