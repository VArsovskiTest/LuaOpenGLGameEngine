using System.Numerics;

public struct LineSegment
{
    public Vector2 A;
    public Vector2 B;

    public LineSegment(Vector2 a, Vector2 b)
    {
        A = a;
        B = b;
    }
}

public struct Circle
{
    public Vector2 Center;
    public float Radius;

    public Circle(Vector2 center, float radius)
    {
        Center = center;
        Radius = radius;
    }
}
