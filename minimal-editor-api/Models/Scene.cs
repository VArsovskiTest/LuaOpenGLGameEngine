using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
namespace MinimalEngineApi.Models;

public class Scene
{
    //[Column(TypeName = "binary(16)")] // This was needed to execute RANDOM_BYTES(16) in Migration
    [Key]
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public List<Actor> Actors { get; set; } = new();
}
