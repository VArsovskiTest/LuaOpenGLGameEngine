using NLua;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Runtime.CompilerServices;
using System.Security.AccessControl;

public class SceneEmpty { }

public class GenericScene
{
    public List<ClearRGB> Clears { get; set; } = new List<ClearRGB>();   // use List, not array
    public List<ActorRGB> Actors { get; set; } = new List<ActorRGB>();    // use List, not array

    public static GenericScene FromLuaTable(Lua lua, LuaTable table)
    {
        var scene = new GenericScene();

        var actors = new List<ActorRGB>();
        var clears = new List<ClearRGB>();

        if (table != null)
        {
            // ---------- Parse actors ----------
            foreach (var key in table.Keys)
            {
                var actorData = table[key] as LuaTable;
                string type = (string?)(actorData as LuaTable)["type"] ?? "";
                var id = GetSafeId(lua, (actorData as LuaTable));

                var color = new RGBColor
                {
                    r = Convert.ToSingle(((actorData as LuaTable)["color"] as LuaTable)?["r"] ?? 1.0f),
                    g = Convert.ToSingle(((actorData as LuaTable)["color"] as LuaTable)?["g"] ?? 1.0f),
                    b = Convert.ToSingle(((actorData as LuaTable)["color"] as LuaTable)?["b"] ?? 1.0f)
                };

                ActorRGB? actor = type switch
                {
                    // "clear" => GenerateBackground(id, color),
                    "rect" => GenerateRectangle(id, (actorData as LuaTable)),
                    "circle" => GenerateCircle(id, (actorData as LuaTable)),
                    "resource_bar" => GenerateResourceBar(id, (actorData as LuaTable)),
                    // "colored_resource_bar" => GenerateResourceBar(id, t),
                    _ => null
                };

                if (actor != null)
                {
                    actor.Color = color;
                    actors.Add(actor);
                }
                else if (type == "clear") clears.Add(GenerateBackground(id, color));
            }
        }

        scene.Clears = clears;
        scene.Actors = actors;

        return scene;
    }

    private static ClearRGB GenerateBackground(string id, RGBColor color)
    {
        return new ClearRGB(color);
    }

    private static RectangleRGB GenerateRectangle(string id, LuaTable t)
    {
        return new RectangleRGB
        {
            Id = new Guid(id),
            X = Convert.ToSingle(t["x"] ?? 0.0),
            Y = Convert.ToSingle(t["y"] ?? 0.0),
            Width = Convert.ToSingle(t["width"] ?? t["w"] ?? 0.0),
            Height = Convert.ToSingle(t["height"] ?? t["h"] ?? 0.0)
        };
    }

    private static CircleRGB GenerateCircle(string id, LuaTable t)
    {
        return new CircleRGB
        {
            Id = new Guid(id),
            X = Convert.ToSingle(t["x"] ?? 0.0),
            Y = Convert.ToSingle(t["y"] ?? 0.0),
            rad = Convert.ToSingle(t["rad"] ?? 0.1)
        };
    }

    private static ResourceBarRGB GenerateResourceBar(string id, LuaTable t)
    {
        return new ResourceBarRGB
        {
            Id = new Guid(id),
            // Name = (string?)t["name"] ?? "bar",
            Current = Convert.ToSingle((t["_data"] as LuaTable)["current"] ?? 0.0),
            Maximum = Convert.ToSingle((t["_data"] as LuaTable)["maximum"] ?? 100.0),
            Percentage = 50,// Convert.ToSingle(((t["_data"] as LuaTable)["__index"] as LuaTable)["percentage"] ?? 0.0),
            Thickness = Convert.ToSingle((t["_data"] as LuaTable)["thickness"] ?? 0.0),
            X = Convert.ToSingle(t["x"] ?? 0.0),
            Y = Convert.ToSingle(t["y"] ?? 0.0)
        };
    }

    private static string GetSafeId(Lua lua, LuaTable t)
    {
        lua["temp_t"] = t;  // temporary assignment
        string id = Guid.Empty.ToString();
        var safeGetIdFunc = lua["safe_get_id"] as LuaFunction;

        if (safeGetIdFunc != null)
        {
            var result = safeGetIdFunc.Call(t);
            // var result = luaStr?.FirstOrDefault()?.ToString();
            // return !String.IsNullOrEmpty(result) ? result : Guid.Empty.ToString();
            id = result?.Length > 0
                ? (result[0] as string ?? Guid.Empty.ToString())
                : Guid.Empty.ToString();
        }

        // Clean up (optional but good practice)
        lua["temp_t"] = null;

        return string.IsNullOrEmpty(id) ? Guid.Empty.ToString() : id;
    }
}
