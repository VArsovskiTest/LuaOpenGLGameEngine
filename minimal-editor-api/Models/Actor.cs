using engine_api.Models;
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

    [Column(TypeName = "varchar(7)")]
    public string? Color { get; set; }

    public Guid? SceneId { get; set; } = new Guid();

    public float X { get; set; }
    public float Y { get; set; }
    public float Z { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public Scene? Scene { get; set; }
    public string ActorUrl { get; set; }

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

    [NotMapped]
    public Enum_ActorTypesEnum ActorType { get; set; } = Enum_ActorTypesEnum.Unset;

    [Column("type", TypeName = "varchar(20)")]
    public string Type
    {
        // EnumModelTransformations.ActorTypeEnumTransformation.TryGetValue(ActorType, out var typeString) ? typeString : "nil";
        get => EnumExtensions.GetEnumMemberValue(ActorType);
        set => ActorType = EnumExtensions.ParseEnumMemberValue<Enum_ActorTypesEnum>(value);
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
