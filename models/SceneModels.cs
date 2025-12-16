public class ModelEmpty {}

[JsonType("clear")]
public class ClearRGB : ModelRGB
{
}

[JsonType("rect")]
public class RectangleRBG : ModelRGB
{
    public float x { get; set; }
    public float y { get; set; }
    public float w { get; set; }
    public float h { get; set; }
}

public abstract class ModelRGB
{
    public float r { get; set; }
    public float g { get; set; }
    public float b { get; set; }
}
