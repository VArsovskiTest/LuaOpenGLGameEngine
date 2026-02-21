using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Reflection.Metadata;
using System.Text.Json;
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

    // Not mapped in DB directly
    [NotMapped]
    public TransformData Transform { get; set; } = new();

    // The DB column
    [Column("transformation", TypeName = "json")]
    public string TransformDataJson
    {
        get => JsonSerializer.Serialize(Transform);
        set => Transform = string.IsNullOrEmpty(value) ? new() : JsonSerializer.Deserialize<TransformData>(value)!;
    }
}

public class TransformData
{
    [System.Text.Json.Serialization.JsonPropertyName("rotation")]
    public float Rotation { get; set; }

    [System.Text.Json.Serialization.JsonPropertyName("scaleX")]
    public float ScaleX { get; set; } = 1.0f;

    [System.Text.Json.Serialization.JsonPropertyName("scaleY")]
    public float ScaleY { get; set; } = 1.0f;
}
