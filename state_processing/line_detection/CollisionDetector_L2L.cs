using System;
using System.Numerics;

public class CollisionDetector_L2L
{
    public static bool CheckCollision(LineSegment line1, LineSegment line2, out Vector2 intersectionPoint)
    {
        intersectionPoint = new Vector2();

        Vector2 dir1 = line1.B - line1.A; // Direction of line 1
        Vector2 dir2 = line2.B - line2.A; // Direction of line 2
        
        float denominator = dir1.X * dir2.Y - dir1.Y * dir2.X; // Denominator for calculating t and u

        // If denominator is zero, the lines are parallel (or collinear)
        if (Math.Abs(denominator) < float.Epsilon)
        {
            return false; // No intersection
        }

        Vector2 diff = line2.A - line1.A;

        float t = (diff.X * dir2.Y - diff.Y * dir2.X) / denominator; // Calculate t
        float u = (diff.X * dir1.Y - diff.Y * dir1.X) / denominator; // Calculate u

        // Check if t and u are within the line segments
        if (t >= 0 && t <= 1 && u >= 0 && u <= 1)
        {
            // The lines intersect at a point within the segments
            intersectionPoint = line1.A + t * dir1; // Calculate the intersection point
            return true;
        }

        return false; // No intersection within the segments
    }
}
