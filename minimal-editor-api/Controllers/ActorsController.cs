using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MinimalEngineApi.Data;
using MinimalEngineApi.Models;

[ApiController]
[Route("api/[controller]")]

public class ActorsController : ControllerBase {
    public AppDbContext _dbContext { get; private set; }
    public ActorsController(AppDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    [HttpGet]
    public async Task<IEnumerable<Actor>> GetActors()
    {
        return await Task.Run(() => _dbContext.Actors);
    }

    [HttpGet("{id}")]
    public async Task<IEnumerable<Actor>> GetActorsForScene(Guid id)
    {
        return await Task.Run(() => _dbContext.Actors.Where(actor => actor.SceneId == id));
    }

    [HttpPost]
    [Route("upload/{sceneId}")]
    public async Task<IAsyncResult> Upload([FromQuery]Guid sceneId, [FromBody]FileStream fileData)
    {
        var assetsPathWithFile = Path.Combine(Directory.GetCurrentDirectory(), "assets", fileData.Name);
        using var assetFile = System.IO.File.Open(assetsPathWithFile, FileMode.OpenOrCreate);
        using (var memoryStream = new MemoryStream())
        {
            await fileData.CopyToAsync(memoryStream);
            var fileBytes = memoryStream.ToArray();
            await assetFile.WriteAsync(fileBytes);
        };

        var newActor = new Actor
        {
            Id = Guid.NewGuid(),
            SceneId = sceneId,
            ActorUrl = assetsPathWithFile,
            ActorType = Enum_ActorTypesEnum.Image,
            Type = EnumExtensions.GetEnumMemberValue(Enum_ActorTypesEnum.Image),
            X = 0,
            Y = 0,
            Color = null
        };

        _dbContext.Actors.Add(newActor);
        return Task.FromResult(assetFile.Name);
    }
}
