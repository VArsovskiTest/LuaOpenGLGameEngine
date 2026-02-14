namespace MinimalEngineApi.Models;

public class Actor
{
    public Guid Id { get; set; }
    public Guid SceneId { get; set; }
    public string Type { get; set; } = string.Empty;     // "Player", "Enemy", etc.
    public float X { get; set; }
    public float Y { get; set; }
    public Scene? Scene { get; set; }
}
