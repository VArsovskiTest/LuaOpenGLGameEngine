using System;
using System.Runtime.InteropServices;
using OpenTK.Graphics.OpenGL;

internal static class Native
{
    // GDI32
    [DllImport("gdi32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr CreateFont(
        int nHeight, int nWidth, int nEscapement, int nOrientation, int fnWeight,
        uint fdwItalic, uint fdwUnderline, uint fdwStrikeOut, uint fdwCharSet,
        uint fdwOutputPrecision, uint fdwClipPrecision, uint fdwQuality,
        uint fdwPitchAndFamily, string lpszFace);

    [DllImport("gdi32.dll")]
    public static extern IntPtr SelectObject(IntPtr hDC, IntPtr hGDIObj);

    [DllImport("gdi32.dll")]
    public static extern bool DeleteObject(IntPtr hObject);

    [DllImport("user32.dll")]
    public static extern IntPtr GetDC(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern int ReleaseDC(IntPtr hWnd, IntPtr hDC);

    // Constants
    public const int FW_NORMAL = 400;
    public const int FW_BOLD   = 700;
    public const uint DEFAULT_CHARSET = 1;
    public const uint OUT_DEFAULT_PRECIS = 0;
    public const uint CLIP_DEFAULT_PRECIS = 0;
    public const uint ANTIALIASED_QUALITY = 4;
    public const uint DEFAULT_PITCH = 0;
    public const uint FF_DONTCARE = 0;
}

internal static class WglExtensions
{
    [DllImport("opengl32.dll")]
    public static extern bool wglUseFontBitmaps(IntPtr hDC, uint first, uint count, uint listBase);
}
