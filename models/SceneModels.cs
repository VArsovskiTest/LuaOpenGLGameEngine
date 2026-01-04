using System.Drawing;

public class ModelEmpty {}

[JsonType("clear")]
public class ClearRGB : ModelRGB
{
    public ClearRGB(IColorable color) { Color = color; }
}

[JsonType("rect")]
public class RectangleRGB : ActorRGB
{
    public float X { get; set; }
    public float Y { get; set; }
    public float Width { get; set; }
    public float Height { get; set; }
}

[JsonType("circle")]
public class CircleRGB : ActorRGB
{
    public float X { get; set; }
    public float Y { get; set; }
    public float rad { get; set; }
}

[JsonType("resource_bar")]
public class ResourceBarRGB : ActorRGB
{
    public float X { get; set; }
    public float Y { get; set; }
    public string Name { get; set; }
    public float Current { get; set; }
    public float Maximum { get; set; }
    public float Thickness { get; set; }
    public float Percentage { get; set; }
}

[JsonType("text")]
public class TextRGB : ActorRGB
{
    public float X { get; set; }
    public float Y { get; set; }
    public string value { get; set; }
}

public interface IColorable
{
    float r { get; set; }
    float g { get; set; }
    float b { get; set; }
}

public class RGBColor : IColorable
{
    public float r { get; set; }
    public float g { get; set; }
    public float b { get; set; }
}

// public class RGBColor : IColorable
// {
//     public float r;
//     public float g;
//     public float b;

//     public RGBColor(float r, float g, float b)
//     {
//         this.r = r;
//         this.g = g;
//         this.b = b;
//     }
// }

public abstract class ModelRGB
{
    public IColorable Color { get; set; }
}

public interface IActor
{
    Guid Id { get; set; }
    bool hovered { get; set; }
    bool selected { get; set; }
    bool isDirty { get; set; }
}

public abstract class ActorRGB : ModelRGB, IActor
{
    public Guid Id { get; set; }
    public bool isDirty { get; set; }
    public bool hovered { get; set; }
    public bool selected { get; set; }    
}

public interface IPlaceable
{
    public float X { get; set; }
    public float Y { get; set; }
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
