using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
namespace MinimalEngineApi.Models;

public class Actor
{
    // [Column(TypeName = "binary(16)")]
    [Key]
    public int Id { get; set; }
    public int SceneId { get; set; }
    public string Type { get; set; } = string.Empty;     // "Player", "Enemy", etc.
    public float X { get; set; }
    public float Y { get; set; }
    public Scene? Scene { get; set; }
}
