using NLua;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public class LuaProcessor
{
    private Lua _lua;
    private string _luaFilePath;

    public LuaProcessor(Lua luaContext, string luaFilePath)
    {
        _lua = new Lua();
        _luaFilePath = luaFilePath;
    }

    public T ProcessLuaQuery<T>(string functionName, params object[] args) where T : class
    {
        _lua.DoFile(_luaFilePath);

        if (_lua[functionName] is LuaFunction luaFunction)
        {
            var luaTable = luaFunction.Call(args)[0] as LuaTable;
            return ConvertLuaTableToObject<T>(luaTable);
        }

        return default;
    }

    public void ProcessLuaNonQuery(string functionName)
    {
        _lua.DoFile(_luaFilePath);

        if (_lua[functionName] is LuaFunction luaFunction)
            luaFunction.Call();
    }

    private T ConvertLuaTableToObject<T>(LuaTable luaTable) where T : class
    {
        // Get the JsonSerializer from factory settings
        var settings = JsonSettingsFactory.GetSettingsForType<T>();
        var serializer = JsonSerializer.Create(settings);

        var jObject = LuaTableToJObject(luaTable);
        return jObject.ToObject<T>(serializer);
    }

    private JObject LuaTableToJObject(LuaTable luaTable)
    {
        var jObject = new JObject();

        foreach (var key in luaTable.Keys)
        {
            var value = luaTable[key];
            var keyStr = key.ToString();

            if (value is LuaTable nestedTable)
            {
                jObject[keyStr] = LuaTableToJObject(nestedTable);
            }
            else if (value is string str)
            {
                jObject[keyStr] = str;
            }
            else if (value is double num)
            {
                jObject[keyStr] = num;
            }
            else if (value is bool boolVal)
            {
                jObject[keyStr] = boolVal;
            }
            else if (value == null)
            {
                jObject[keyStr] = JValue.CreateNull();
            }
            else
            {
                jObject[keyStr] = value.ToString();
            }
        }

        return jObject;
    }
}
