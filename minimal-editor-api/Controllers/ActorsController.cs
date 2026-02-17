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
        return _dbContext.Actors.ToList();
    }
}
