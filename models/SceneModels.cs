public class ModelEmpty {}

public class RGBColor : IColorable
{
    public float r { get; set; }
    public float g { get; set; }
    public float b { get; set; }
}

public abstract class ModelRGB
{
    public IColorable Color { get; set; }
}

public abstract class ActorRGB : ModelRGB, IActor
{
    public Guid Id { get; set; }
    public bool isDirty { get; set; }
    public bool hovered { get; set; }
    public bool selected { get; set; }    
}

public interface ISizable
{
    public float Width { get; set; }
    public float Height { get; set; }
}

public class Viewport : ISizable
{
    public float Width { get; set; }
    public float Height { get; set; }
}
