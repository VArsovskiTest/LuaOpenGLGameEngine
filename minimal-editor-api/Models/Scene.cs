using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
namespace MinimalEngineApi.Models;

public class Scene
{
    [Key]
    [Column(TypeName = "binary(16)")] // This was needed to execute RANDOM_BYTES(16) in Migration
    public Guid Id { get; set; } = new Guid();
    public string Name { get; set; } = string.Empty;
    [NotMapped]
    public string SizeStr { get; set; } = Enum_SceneSizeEnum.Unset.ToString(); // For receiving as string in JSON
    public Enum_SceneSizeEnum Size { get; set; } = Enum_SceneSizeEnum.Unset;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public List<Actor> Actors { get; set; } = new();
}
