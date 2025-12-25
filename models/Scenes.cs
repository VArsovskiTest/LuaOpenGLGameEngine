using NLua;
using System;
using System.Collections.Generic;
using System.Drawing;

public class SceneEmpty { }

public class GenericScene
{
    public List<ClearRGB> Clears { get; set; } = new List<ClearRGB>();   // use List, not array
    public List<ActorRGB> Actors { get; set; } = new List<ActorRGB>();    // use List, not array

    public static GenericScene FromLuaTable(LuaTable table)
    {
        var scene = new GenericScene();

        // ---------- Parse clears ----------
        if (table["clears"] is LuaTable clearsTable)
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
        if (table["actors"] is LuaTable actorsTable)
        {
            foreach (object key in actorsTable.Keys)
            {
                if (actorsTable[key] is LuaTable t)
                {
                    string type = (string?)t["type"] ?? "";
                    string id = (string?)t["id"] ?? Guid.NewGuid().ToString();
                    var color = new RGBColor
                    {
                        r = Convert.ToSingle((t["color"] as LuaTable)?["r"] ?? 1.0f),
                        g = Convert.ToSingle((t["color"] as LuaTable)?["g"] ?? 1.0f),
                        b = Convert.ToSingle((t["color"] as LuaTable)?["b"] ?? 1.0f)
                    };

                    ActorRGB? actor = type switch
                    {
                        "rect" => new RectangleRGB
                        {
                            Id = new Guid(id),
                            X = Convert.ToSingle(t["x"] ?? 0.0),
                            Y = Convert.ToSingle(t["y"] ?? 0.0),
                            Width = Convert.ToSingle(t["width"] ?? t["w"] ?? 0.0),
                            Height = Convert.ToSingle(t["height"] ?? t["h"] ?? 0.0),
                            Color = color,
                        },

                        "circle" => new CircleRGB
                        {
                            Id = new Guid(id),
                            X = Convert.ToSingle(t["x"] ?? 0.0),
                            Y = Convert.ToSingle(t["y"] ?? 0.0),
                            rad = Convert.ToSingle(t["rad"] ?? 0.1),
                            Color = color,
                        },

                        "resource_bar" => new ResourceBarRGB
                        {
                            Id = new Guid(id),
                            // Name = (string?)t["name"] ?? "bar",
                            Current = Convert.ToSingle(t["current"] ?? 0.0),
                            Maximum = Convert.ToSingle(t["maximum"] ?? 100.0),
                            Percentage = Convert.ToSingle(t["percentage"] ?? 0.0),
                            X = Convert.ToSingle(t["x"] ?? 0.0),
                            Y = Convert.ToSingle(t["y"] ?? 0.0),
                            Color = color,
                        },

                        _ => null
                    };

                    if (actor != null)
                        scene.Actors.Add(actor);
                }
            }
        }

        return scene;
    }
}
