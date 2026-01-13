using System.Diagnostics.Contracts;
using System.Text.Json;
using NLua;

public class GameState
{
    // TODO: create SceneState when possibility for multiple scenes in the future
    public Guid SceneId { get; set; } = Guid.NewGuid();
    public ActorState CurrentActor { get; set; } = new ActorState();
    public List<ActorState> Actors { get; set; } = new List<ActorState>();
    public KeyboardState KeyboardState { get; set; } = new KeyboardState();

    private const string GAME_STATE_NAME = "cached_game_state";
    private const string KB_STATE_NAME   = "cached_keyboard_state";
    private const string KB_ACTOR_STATE_NAME = "cached_actor_state";

    private Lua _lua;
    private LuaTable _cachedGameStateTable;
    private LuaTable _cachedKeyboardStateTable;
    private LuaTable _cachedActorState;

    public GameState(Lua lua)
    {
        _lua = lua;

        lua.NewTable(GAME_STATE_NAME);
        _cachedGameStateTable = lua.GetTable(GAME_STATE_NAME);

        lua.NewTable(KB_STATE_NAME);
        _cachedKeyboardStateTable = lua.GetTable(KB_STATE_NAME);

        lua.NewTable(KB_ACTOR_STATE_NAME);
        _cachedActorState = lua.GetTable(KB_ACTOR_STATE_NAME);
    }

    public ActorState GetSelectedActor()
    {
        return Actors.FirstOrDefault(actor => actor.Selected);
    }
    public bool UpdateActor(ActorState actorState)
    {
        actorState.Selected = true;
        Actors.ForEach(actor =>
        {
            if (actor.ActorId == actorState.ActorId)
                // actor = actorState;
                actor.Selected = actorState.Selected;
            actor.Hovered = actorState.Hovered;
            actor.X = actorState.X;
            actor.Y = actorState.Y;
            actor.TargetX = actorState.TargetX;
            actor.TargetY = actorState.TargetY;
            actor.Tags = actorState.Tags;
        });
        return true;
    }

    public ActorState GetHoveredActor()
    {
        return Actors.FirstOrDefault(actor => actor.Hovered);
    }

    public LuaTable GetLuaTableData() {
        foreach(var kvp in KeyboardState.Keys)
        {
            _cachedKeyboardStateTable[kvp.Key] = kvp.Value;
        }
        _cachedGameStateTable["SceneId"] = SceneId;
        _cachedGameStateTable["CurrentActor"] = CurrentActor.GetLuaTableData(_cachedActorState);
        _cachedGameStateTable["KeyboardState"] = _cachedKeyboardStateTable;

        return _cachedGameStateTable;
    }
}

public class KeyboardState
{
    public List<KeyValuePair<string, bool>> Keys { get; set; } = new List<KeyValuePair<string, bool>>();
}
