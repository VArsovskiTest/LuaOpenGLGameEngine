using OpenTK.Graphics.OpenGL;
using System.Text;

public class GraphicsRenderer
{
    public GraphicsRenderer() { }
    private ISizable _viewport { get; set; }

    public void InitGraphics(ISizable viewport)
    {
        _viewport = viewport;
        GL.ClearColor(0.1f, 0.1f, 0.2f, 1.0f);
        GL.Enable(EnableCap.Blend);
        GL.BlendFunc(BlendingFactor.SrcAlpha, BlendingFactor.OneMinusSrcAlpha);
    }

    public void ClearScreen(float r, float g, float b)
    {
        GL.ClearColor(r, g, b, 1f);
        GL.Clear(ClearBufferMask.ColorBufferBit);
    }

    public void DrawRect(float x, float y, float w, float h, float r, float g, float b)
    {
        GL.Color3(r, g, b);
        GL.Begin(PrimitiveType.Quads);
        GL.Vertex2(x, y);
        GL.Vertex2(x + w, y);
        GL.Vertex2(x + w, y + h);
        GL.Vertex2(x, y + h);
        GL.End();
    }

    public void DrawPercentageLine(float percentage, float x, float y, bool isHorizontal, float r, float g, float b)
    {
        // Get the current viewport dimensions
        int[] viewport = new int[4];
        GL.GetInteger(GetPName.Viewport, viewport);

        float width = viewport[2];  // Viewport width
        float height = viewport[3]; // Viewport height

        // Calculate line endpoints based on percentage and orientation
        float lineLength = isHorizontal ? width * percentage : height * percentage;

        // Define line endpoints
        float x1 = isHorizontal ? 0 : (width - lineLength) / 2; // Starting x for vertical
        float y1 = isHorizontal ? (height - lineLength) / 2 : 0; // Starting y for horizontal
        float x2 = isHorizontal ? lineLength : (width - lineLength) / 2; // Ending x for horizontal
        float y2 = isHorizontal ? (height - lineLength) / 2 : lineLength; // Ending y for vertical

        // Translate to (x, y) being starting position/s
        x1 += x;
        x2 += x;
        y1 += y;
        y2 += y;

        // Set color
        GL.Color3(r, g, b);

        // Draw the line
        GL.Begin(PrimitiveType.Lines);
        GL.Vertex2(x1, y1);
        GL.Vertex2(x2, y2);
        GL.End();
    }

    public void DrawBar(string name, float current, float max, float percentage, float r, float g, float b)
    {
        var x = 0.05f;
        var y = 0.05f;
        DrawText(name + ": " + current + "/" + max, x, y, 1, r, g, b);
        DrawPercentageLine((float)(percentage * 0.1), x, y, true, r, g, b);
    }

    public void DrawText(string text, float x, float y, float scale, float r, float g, float b)
    {
        GL.Color3(r, g, b); // Set the color

        // // Assuming you have a texture for the font loaded
        // GL.BindTexture(TextureTarget.Texture2D, fontTextureId);

        GL.Enable(EnableCap.Texture2D);
        GL.Begin(PrimitiveType.Quads);

        // foreach (char character in text)
        // {
        //     // Calculate the texture coordinates and position
        //     float texX = (character % numColumns) / (float)numColumns; // numColumns: number of characters in your texture atlas row
        //     float texY = (character / numColumns) / (float)numRows; // numRows: number of rows in your texture atlas

        //     float width = charWidth * scale;  // charWidth: width of each character in pixels
        //     float height = charHeight * scale; // charHeight: height of each character in pixels

        //     // Bottom-left
        //     GL.TexCoord2(texX, texY + charHeight / fontHeight);
        //     GL.Vertex2(x, y);

        //     // Bottom-right
        //     GL.TexCoord2(texX + charWidth / fontWidth, texY + charHeight / fontHeight);
        //     GL.Vertex2(x + width, y);

        //     // Top-right
        //     GL.TexCoord2(texX + charWidth / fontWidth, texY);
        //     GL.Vertex2(x + width, y + height);

        //     // Top-left
        //     GL.TexCoord2(texX, texY);
        //     GL.Vertex2(x, y + height);

        //     // Move the position for the next character
        //     x += width;
        // }

        GL.End();
        GL.Disable(EnableCap.Texture2D);
    }

    public void DrawCircle(float x, float y, float radius, float r, float g, float b)
    {
        int numSegments = 100; // Number of segments to approximate the circle
        float angleStep = (float)(2 * Math.PI / numSegments);

        GL.Color3(r, g, b); // Set the color

        GL.Begin(PrimitiveType.TriangleFan); // Start drawing a triangle fan

        GL.Vertex2(x, y); // Center of the circle

        // Generate vertices for the circle
        for (int i = 0; i <= numSegments; i++)
        {
            float angle = i * angleStep;
            float px = x + radius * (float)Math.Cos(angle); // X coordinate of the perimeter
            float py = y + radius * (float)Math.Sin(angle); // Y coordinate of the perimeter
            GL.Vertex2(px, py); // Create vertex
        }

        GL.End();
    }

    // // TODO: Consider refactoring DrawText (and maybe DrawCircle, if possible)
    // public void InitializeFreeType(string fontPath)
    // {
    //     // Initialize FreeType and load the font
    //     // Create a texture atlas for the characters as needed
    // }

    // public void RenderText(string text, float x, float y, float scale)
    // {
    //     foreach (char c in text)
    //     {
    //         Character ch = characters[c];

    //         // Rendering logic here using OpenGL 
    //         // Use the character's texture and position it at (x, y)

    //         x += (ch.Advance >> 6) * scale; // Advance to the next character
    //     }
    // }
}
