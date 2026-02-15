using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
namespace MinimalEngineApi.Models;

public class Scene
{
    [Key]
    [Column(TypeName = "binary(16)")] // This was needed to execute RANDOM_BYTES(16) in Migration
    public Guid Id { get; set; } = new Guid();
    public string Name { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public List<Actor> Actors { get; set; } = new();
}
