using System.Diagnostics.Contracts;
using System.Security.Cryptography.X509Certificates;
using NLua;

public class ActorState
{
    public Guid ActorId { get; set; }
    public bool Hovered { get; set; }
    public bool Selected { get; set; }
    public float X { get; set; }
    public float Y { get; set; }
    public float TargetX { get; set; }
    public float TargetY { get; set; }
    public float Speed { get; set; }
    public List<ActorEffect> Effects = new List<ActorEffect>();   // Stunned, Dazed, Silenced, Displaced, e.t.c. TODO: Adjust later
    public Enum_ControlledByEnum ControlledBy { get; set; }

    public ActorState()
    {
        ActorId = Guid.Empty; ControlledBy = Enum_ControlledByEnum.Noone;
    }

    public ActorState(Guid id, float x, float y, Enum_ControlledByEnum controlledBy)
    {
        ActorId = id; X = x; Y = y; ControlledBy = controlledBy;
    }

    // Hidden, Moving, Immobilized, OOC, Non-Targetted
    public BitFlags Tags { get; set; } = new BitFlags(5); // ==> With 0,0,0,0 default we expect our actor/s to be Visible, Still, Movable, and not in Combat (OOC + not targetted)

    public LuaTable GetLuaTableData(LuaTable table)
    {
        table["ActorId"] = ActorId;
        table["Hovered"] = Hovered;
        table["Selected"] = Selected;
        table["X"] = X;
        table["Y"] = Y;
        table["TargetX"] = TargetX;
        table["TargetY"] = TargetY;
        table["Tags"] = Tags.GetBinaryString();
        table["Speed"] = Speed;
        return table;
    }

    public class ActorEffect
    {
        public string Name { get; set; }
        public float Duration { get; set; } = -1f; // -1 == Indefinite until updated further
    }
}
