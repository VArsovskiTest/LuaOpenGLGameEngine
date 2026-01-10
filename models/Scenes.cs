using NLua;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Security.AccessControl;

public class SceneEmpty { }

public class GenericScene
{
    public List<ClearRGB> Clears { get; set; } = new List<ClearRGB>();   // use List, not array
    public List<ActorRGB> Actors { get; set; } = new List<ActorRGB>();    // use List, not array

    public static GenericScene FromLuaTable(Lua lua, LuaTable table)
    {
        var scene = new GenericScene();

        // ---------- Parse clears ----------
        if (table != null && table["clears"] is LuaTable clearsTable)
        {
            foreach (object key in clearsTable.Keys)
            {
                if (clearsTable[key] is LuaTable t)
                {
                    scene.Clears.Add(new ClearRGB(new RGBColor
                    {
                        r = Convert.ToSingle(t["r"] ?? 0.0)
                        ,
                        g = Convert.ToSingle(t["g"] ?? 0.0)
                        ,
                        b = Convert.ToSingle(t["b"] ?? 0.0)
                    }));
                }
            }
        }

        // ---------- Parse actors ----------
        if (table != null && table["actors"] is LuaTable actorsTable)
        {
            foreach (object key in actorsTable.Keys)
            {
                if (actorsTable[key] is LuaTable t)
                {
                    string type = (string?)t["type"] ?? "";
                    string id = GetSafeId(lua, t);

                    var color = new RGBColor
                    {
                        r = Convert.ToSingle((t["color"] as LuaTable)?["r"] ?? 1.0f),
                        g = Convert.ToSingle((t["color"] as LuaTable)?["g"] ?? 1.0f),
                        b = Convert.ToSingle((t["color"] as LuaTable)?["b"] ?? 1.0f)
                    };

                    ActorRGB? actor = type switch
                    {
                        "rect" => GenerateRectangle(id, t),
                        "circle" => GenerateCircle(id, t),
                        "resource_bar" => GenerateResourceBar(id, t),
                        "colored_resource_bar" => GenerateResourceBar(id, t),
                        _ => null
                    };
                    actor.Color = color;

                    if (actor != null)
                        scene.Actors.Add(actor);
                }
            }
        }

        return scene;
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
