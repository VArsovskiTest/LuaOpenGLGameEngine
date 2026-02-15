using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
namespace MinimalEngineApi.Models;

public class Actor
{
    [Key]
    [Column(TypeName = "binary(16)")]
    public Guid Id { get; set; } = new Guid();
    public Guid SceneId { get; set; } = new Guid();
    public string Type { get; set; } = string.Empty;     // "Player", "Enemy", etc.
    public float X { get; set; }
    public float Y { get; set; }
    public Scene? Scene { get; set; }
}
