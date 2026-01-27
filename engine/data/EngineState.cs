using System.Numerics;
using NLua;

public class EngineState {
    private Lua _luaContext;

    public List<PlayerData> Players { get; }
    public HashSet<MonsterData> Monsters { get; }

    public EngineState(Lua luaContext)
    {
        _luaContext = luaContext;
        BindEngineStateToLua();
        Players = new List<PlayerData>();
        Monsters = new HashSet<MonsterData>();
    }

    public void BindEngineStateToLua()
    {
        // Exposing EngineState methods to Lua
        _luaContext["Engine"] = new
        {
            GetPlayerPosition = new Func<string, Vector2>(GetPositionData),
            GetEntityPosition = new Func<string, Vector2>(GetPositionData),
            GetEntityHealth = new Func<string, float>(id => GetEntityById(id).HP.Current),
            GetDistance = new Func<Vector2, Vector2, float>(GetDistance),
            // Additional methods can be added here
        };

        Console.WriteLine("Engine methods bound to Lua.");
    }

    public IGenericEntity GetEntityById(string id)
    {
        var monster = Monsters.First(entity => entity.Id == id);
        return monster != null
        ? monster
        : Players.First(player => player.Id == id);
    }
    
    public Vector2 GetPositionData(string playerId) {
        var positionData = GetEntityById(playerId).Position;
        return positionData != null ?
        new Vector2(positionData.X, positionData.Y)
        : new Vector2(-2, -2); //Out of screen (range is [-1, 1])
    }

    public float GetDistance(Vector2 pos1, Vector2 pos2) {
        return Vector2.Distance(pos1, pos2);
    }

    // You could expose this method to Lua
    public void UpdateMonsterBehavior(float dt, string playerId, string selfId) {
        // Fetch data and call the Lua update function
        MonsterData monsterData = (MonsterData)GetEntityById(selfId);
        PlayerData playerData = (PlayerData)GetEntityById(playerId);

        _luaContext.GetFunction("MonsterBehaviors:update").Call(dt, selfId, monsterData, playerData);
    }
}
