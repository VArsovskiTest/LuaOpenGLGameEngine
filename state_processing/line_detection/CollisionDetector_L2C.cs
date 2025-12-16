using System.Numerics;

public class CollisionDetector_L2C
{
    public static bool CheckCollision(LineSegment line, Circle circle)
    {
        Vector2 d = line.B - line.A;
        Vector2 f = line.A - circle.Center;

        float a = Vector2.Dot(d, d);
        float b = 2 * Vector2.Dot(f, d); // b = 2 * (fx * dx + fy * dy)
        float c = Vector2.Dot(f, f) - (circle.Radius * circle.Radius); // c = (A - C)^2 - r^2

        float discriminant = b * b - 4 * a * c; // D = b^2 - 4ac

        if (discriminant < 0)
        {
            return false; // No intersection
        }
        else
        {
            discriminant = (float)Math.Sqrt(discriminant);
            float t1 = (-b - discriminant) / (2 * a);
            float t2 = (-b + discriminant) / (2 * a);

            // Check if any intersection points are within the line segment
            return (t1 >= 0 && t1 <= 1) || (t2 >= 0 && t2 <= 1);
        }
    }
}
