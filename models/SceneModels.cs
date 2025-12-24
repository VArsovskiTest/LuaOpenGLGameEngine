public class ModelEmpty {}

[JsonType("clear")]
public class ClearRGB : ModelRGB
{
}

[JsonType("rect")]
public class RectangleRGB : ModelRGB
{
    public float x { get; set; }
    public float y { get; set; }
    public float w { get; set; }
    public float h { get; set; }
}

[JsonType("circle")]
public class CircleRGB : ModelRGB
{
    public float x { get; set; }
    public float y { get; set; }
    public float rad { get; set; }
}

[JsonType("resource_bar")]
public class ResourceBarRGB : ModelRGB
{
    public float x { get; set; }
    public float y { get; set; }
    public string name { get; set; }
    public float current { get; set; }
    public float maximum { get; set; }
    public float percentage { get; set; }    
}

[JsonType("text")]
public class TextRGB : ModelRGB
{
    public float x { get; set; }
    public float y { get; set; }
    public string value { get; set; }
}


public abstract class ModelRGB
{
    public float r { get; set; }
    public float g { get; set; }
    public float b { get; set; }
}

public interface ISizable
{
    public int Width { get; set; }
    public int Height { get; set; }
}

public class Viewport : ISizable
{
    public int Width { get; set; }
    public int Height { get; set; }
}
