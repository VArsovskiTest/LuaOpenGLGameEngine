using OpenTK.Graphics.OpenGL;

public class GraphicsRenderer
{
    public GraphicsRenderer() { }

    public void InitGraphics()
    {
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
}