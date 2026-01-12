[JsonType("clear")]
public class ClearRGB : ModelRGB
{
    public ClearRGB(IColorable color) { Color = color; }
}

[JsonType("rect")]
public class RectangleRGB : ActorRGB, IPlaceable
{
    public float X { get; set; }
    public float Y { get; set; }
    public float Width { get; set; }
    public float Height { get; set; }
}

[JsonType("circle")]
public class CircleRGB : ActorRGB, IPlaceable
{
    public float X { get; set; }
    public float Y { get; set; }
    public float rad { get; set; }
}

[JsonType("resource_bar")]
public class ResourceBarRGB : ActorRGB, IPlaceable
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
public class TextRGB : ActorRGB, IPlaceable
{
    public float X { get; set; }
    public float Y { get; set; }
    public string value { get; set; }
}
