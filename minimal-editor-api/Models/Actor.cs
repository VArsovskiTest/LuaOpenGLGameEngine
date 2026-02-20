using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Reflection.Metadata;
namespace MinimalEngineApi.Models;

public class Actor
{
    [Key]
    [Column(TypeName = "binary(16)")]
    public Guid Id { get; set; } = new Guid();

    [ForeignKey("SceneId")]
    public Guid? SceneId { get; set; } = new Guid();

    public string Type { get; set; } = string.Empty;     // "Player", "Enemy", etc.
    public float X { get; set; }
    public float Y { get; set; }
    [Column(TypeName = "varchar(7)")]
    public string Color { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public Scene? Scene { get; set; }
}
