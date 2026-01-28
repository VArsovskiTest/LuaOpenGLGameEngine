[ApiController]
[Route("api/[controller]")]
public class ScenesController : ControllerBase
{
    private readonly AppDbContext _context;

    public ScenesController(AppDbContext context)
    {
        _context = context;
    }

    [HttpPost("{id?}")]   // POST /api/scenes or /api/scenes/5 for update
    public async Task<IActionResult> SaveScene(int? id, [FromBody] Scene scene)
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

        await _context.SaveChangesAsync();
        return Ok(scene.Id);   // return new/existing ID
    }
}
