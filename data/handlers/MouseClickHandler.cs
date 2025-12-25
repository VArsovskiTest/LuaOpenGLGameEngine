using System.Drawing;
using System.Security.Cryptography.X509Certificates;

public class MouseClickHandler
{
    private (float ndcX, float ndcY) MouseToNdc(int mouseX, int mouseY, int windowWidth, int windowHeight)
    {
        // Mouse coords: (0,0) = top-left, windowWidth/Height = bottom-right
        // NDC: (-1,1) = top-left, (1,-1) = bottom-right  (y positive up)

        float ndcX = (2.0f * mouseX) / windowWidth - 1.0f;
        float ndcY = 1.0f - (2.0f * mouseY) / windowHeight;  // Flip Y

        return (ndcX, ndcY);
    }

    public ActorRGB? SelectActor(GenericScene scene, int mouseX, int mouseY, int windowWidth, int windowHeight)
    {
        var (nx, ny) = MouseToNdc(mouseX, mouseY, windowWidth, windowHeight);

        ActorRGB? picked = null;
        float bestDistance = float.MaxValue; // For circles, we can prioritize closest

        foreach (var actor in scene.Actors)
        {
            if (actor is RectangleRGB rect)
            {
                // Axis-aligned rectangle hit test
                float left = rect.X - rect.Width / 2f;
                float right = rect.X + rect.Width / 2f;
                float bottom = rect.Y - rect.Height / 2f;
                float top = rect.Y + rect.Height / 2f;

                if (nx >= left && nx <= right && ny >= bottom && ny <= top)
                {
                    picked = actor;
                    // You can return immediately if you want first hit, or continue for closest
                }
            }
            else if (actor is CircleRGB circle)
            {
                float dx = nx - circle.X;
                float dy = ny - circle.Y;
                float distSq = dx * dx + dy * dy;
                float radSq = circle.rad * circle.rad;

                if (distSq <= radSq)
                {
                    float dist = MathF.Sqrt(distSq);
                    if (dist < bestDistance)
                    {
                        bestDistance = dist;
                        picked = actor;
                    }
                }
            }
            else if (actor is ResourceBarRGB bar)
            {
                // Treat bar as rectangle
                var rBar = new RectangleRGB { X = bar.X, Y = bar.Y, Width = bar.Percentage * 0.1f * windowWidth, Height = windowHeight * 0.01f
                , Color = new RGBColor { r = bar.Color.r, g = bar.Color.g, b = bar.Color.b } };
                float left = rBar.X - rBar.Width / 2f;
                float right = rBar.X + rBar.Width / 2f;
                float bottom = rBar.Y - rBar.Height / 2f;
                float top = rBar.Y + rBar.Height / 2f;

                // You'll need to expose width/height on ResourceBarRGB or compute it
                if (nx >= left && nx <= right && ny >= bottom && ny <= top)
                {
                    picked = actor;
                }
            }
        }

        return picked;
    }

    public void HandleClick(ActorRGB? clickedActor)
    {
        if (clickedActor == null) return;

        Console.WriteLine($"Clicked: {clickedActor.GetType().Name}");

        // Example reactions
        if (clickedActor is RectangleRGB rect)
        {
            rect.Color.r = 1f; rect.Color.g = 0f; rect.Color.b = 0f; // Flash red
        }
        else if (clickedActor is ResourceBarRGB bar)
        {
            bar.Current = bar.Maximum; // Refill on click
        }
        // ... etc.
    }
}
