using NLua;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public class LuaProcessor
{
    private Lua _lua;

    // Cache the LuaFunction objects to avoid repeated lookups
    private readonly Dictionary<string, LuaFunction> _luaFunctionCache;

    private string _luaFilePath;

    private bool _scriptLoaded = false;

    public LuaProcessor(Lua lua, string luaFilePath)
    {
        _lua = lua;
        _luaFilePath = luaFilePath;
        _luaFunctionCache = new Dictionary<string, LuaFunction>();

        // --- Load the script ONCE here ---
        try
        {
            _lua.DoFile(luaFilePath);
            _scriptLoaded = true;
        }
        catch (Exception ex)
        {
            // Handle file not found, syntax errors, etc.
            Console.WriteLine($"FATAL: Could not load or execute Lua script at {luaFilePath}. Error: {ex.Message}");
        }
    }

    // Helper to get and cache a function
    private LuaFunction GetLuaFunction(string functionName)
    {
        if (!_scriptLoaded)
        {
            throw new InvalidOperationException("Lua script not loaded successfully — check constructor logs.");
        }
        if (_luaFunctionCache.TryGetValue(functionName, out LuaFunction func))
        {
            return func;
        }

        func = _lua[functionName] as LuaFunction;
        if (func == null)
        {
            throw new InvalidOperationException($"Lua function '{functionName}' not found.");
        }

        _luaFunctionCache[functionName] = func;
        return func;
    }

    public void ReloadScript()
    {
        _luaFunctionCache.Clear();
        try
        {
            _lua.DoFile(_luaFilePath);  // Re-execute the script
            _scriptLoaded = true;
            Console.WriteLine($"Lua script reloaded: {_luaFilePath}");
        }
        catch (Exception ex)
        {
            _scriptLoaded = false;
            Console.WriteLine($"Reload failed: {ex.Message}");
        }
    }

    public T ProcessLuaQuery<T>(string functionName, params object[] args) where T : class
    {
        var luaFunction = GetLuaFunction(functionName);
        var result = luaFunction.Call(args);
        
        if (result.Length > 0 && result[0] is LuaTable luaTable)
        {
            return ConvertLuaTableToObject<T>(luaTable);
        }
        
        return default;
    }

    public void ProcessLuaNonQuery(string functionName, params object[] args)
    {
        var luaFunction = GetLuaFunction(functionName);
        luaFunction.Call(args);
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

    public void Dispose()
    {
        _lua?.Dispose();
        foreach(var func in _luaFunctionCache.Values)
        {
            func?.Dispose();
        }
    }
}
