using OpenTK.Graphics.OpenGL;
using System.Text;

public class GraphicsRenderer
{
    public GraphicsRenderer() { }
    private ISizable _viewport { get; set; }
    private uint _fontBase = 0; // 0 = font not built yet

    public void InitGraphics()
    {
        UpdateViewportValues();
        BuildBitmapFont("Arial", 28, bold: true);
        GL.ClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        GL.Enable(EnableCap.Blend);
        GL.BlendFunc(BlendingFactor.SrcAlpha, BlendingFactor.OneMinusSrcAlpha);
    }

    public void ClearScreen(IColorable color)
    {
        GL.ClearColor(color.r, color.g, color.b, 1f);
        GL.Clear(ClearBufferMask.ColorBufferBit);
    }

    private void UpdateViewportValues()
    {
        int[] viewport = new int[4]; // Create an array to hold the viewport dimensions.
        GL.GetInteger(GetPName.Viewport, viewport); // Get the current viewport

        int width = viewport[2];    // Assign the width of the viewport
        int height = viewport[3];   // Assign the height of the viewport
        _viewport = new Viewport { Width = width, Height = height };
    }

    public void BuildBitmapFont(string fontName = "Consolas", int height = 24, bool bold = true)
    {
        if (_fontBase != 0) return; // Already built

        IntPtr hdc = Native.GetDC(IntPtr.Zero); // Screen DC is sufficient

        int weight = bold ? Native.FW_BOLD : Native.FW_NORMAL;

        IntPtr hFont = Native.CreateFont(
            -height, 0, 0, 0, weight,
            0, 0, 0,
            Native.DEFAULT_CHARSET,
            Native.OUT_DEFAULT_PRECIS,
            Native.CLIP_DEFAULT_PRECIS,
            Native.ANTIALIASED_QUALITY,
            Native.DEFAULT_PITCH | Native.FF_DONTCARE,
            fontName);

        if (hFont == IntPtr.Zero)
            throw new Exception($"Failed to create font: {fontName}");

        IntPtr oldFont = Native.SelectObject(hdc, hFont);

        _fontBase = (uint)GL.GenLists(256);                    // Allocate 256 display lists
        bool success = WglExtensions.wglUseFontBitmaps(hdc, 0, 255, _fontBase);

        Native.SelectObject(hdc, oldFont);
        Native.DeleteObject(hFont);
        Native.ReleaseDC(IntPtr.Zero, hdc);

        if (!success)
            throw new Exception("wglUseFontBitmaps failed");
    }

    public void DrawLine(float x1, float y1, float x2, float y2, IColorable color)
    {
        GL.Color3(color.r, color.g, color.b);
        GL.Begin(PrimitiveType.Lines);
        GL.Vertex2(x1, y1);
        GL.Vertex2(x2, y2);
        GL.End();
    }

    public void DrawRect(float x, float y, float w, float h, IColorable color)
    {
        GL.Color3(color.r, color.g, color.b);
        GL.Begin(PrimitiveType.Quads);
        GL.Vertex2(x, y);
        GL.Vertex2(x + w, y);
        GL.Vertex2(x + w, y + h);
        GL.Vertex2(x, y + h);
        GL.End();
    }

    public void DrawPercentageLine(float percentage, float thickness, float x, float y, bool isHorizontal, IColorable color)
    {
        DrawRect(x, y
        , isHorizontal ? percentage : thickness
        , isHorizontal ? thickness : percentage
        , color);
    }

    public void DrawBar(string name, float current, float max, float percentage, float thickness, float x, float y, IColorable color)
    {
        DrawPercentageLine(percentage, thickness, x, y, true, color);
        DrawText(name + ": " + current + "/" + max, x, y, 1, color);
    }

    public void DrawText(string text, float x, float y, float scale, IColorable color)
    {
        if (string.IsNullOrEmpty(text) || _fontBase == 0) return;

        // Save absolutely everything we might change
        GL.PushAttrib(AttribMask.AllAttribBits);

        // Disable things that interfere with 2D overlay
        GL.Disable(EnableCap.Lighting);
        GL.Disable(EnableCap.DepthTest);
        GL.Disable(EnableCap.Texture2D);
        GL.Disable(EnableCap.Blend); // Optional — re-enable if you want alpha

        GL.Color3(color.r, color.g, color.b);

        // === Force 2D orthographic projection (-1 to 1 NDC) ===
        GL.MatrixMode(MatrixMode.Projection);
        GL.PushMatrix();
        GL.LoadIdentity();
        GL.Ortho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);  // Bottom-left = (-1,-1), Top-right = (1,1)

        GL.MatrixMode(MatrixMode.Modelview);
        GL.PushMatrix();
        GL.LoadIdentity();

        // Position and scale the text
        GL.Translate(x, y, 0.0f);
        GL.Scale(scale, scale, scale);

        // Render text
        GL.ListBase(_fontBase);

        byte[] bytes = System.Text.Encoding.ASCII.GetBytes(text + '\0'); // null-terminate just in case
        GL.CallLists(bytes.Length - 1, ListNameType.UnsignedByte, bytes);

        // === Restore everything exactly as it was ===
        GL.MatrixMode(MatrixMode.Modelview);
        GL.PopMatrix();

        GL.MatrixMode(MatrixMode.Projection);
        GL.PopMatrix();

        // PopAttrib restores enables, color mask, etc.
        GL.PopAttrib();
    }

    public void DrawCircle(float x, float y, float radius, IColorable color)
    {
        int numSegments = 100; // Number of segments to approximate the circle
        float angleStep = (float)(2 * Math.PI / numSegments);

        GL.Color3(color.r, color.g, color.b);
        GL.Begin(PrimitiveType.TriangleFan);
        GL.Vertex2(x, y); // Center of the circle

        for (int i = 0; i <= numSegments; i++)
        {
            float angle = i * angleStep;
            float px = x + radius * (float)Math.Cos(angle);
            float py = y + radius * (float)Math.Sin(angle);
            GL.Vertex2(px, py); // Create vertex
        }

        GL.End();
    }
}
