using NLua;

public static class LuaHelper
{
    public static Dictionary<string, object> LuaTableToDictionary(object[] data)
    {
        var dict = new Dictionary<string, object>();

        if (data.Length > 0 && data[0] is LuaTable)
        {
            var luaTable = data[0] as LuaTable;
            var luaEnumerator = luaTable.GetEnumerator();

            while (luaEnumerator.MoveNext())
            {
                var entry = luaEnumerator.Entry;

                // Check the type of entry value
                // For nested Lua tables
                if (entry.Value is LuaTable nestedTable)
                {
                    // Call recursively to convert nested table
                    dict[entry.Key.ToString()] = LuaTableToDictionary(new object[] { nestedTable });
                }
                else
                {
                    dict[entry.Key.ToString()] = entry.Value; // Directly set key/value pairs
                }
            }
        }

        return dict;
    }

    public static T ConvertDictionaryToObject<T>(Dictionary<string, object> dict)
    {
        var obj = Activator.CreateInstance<T>();

        foreach (var kvp in dict)
        {
            var propertyInfo = typeof(T).GetProperty(kvp.Key);
            if (propertyInfo != null && kvp.Value != null)
            {
                propertyInfo.SetValue(obj, Convert.ChangeType(kvp.Value, propertyInfo.PropertyType));
            }
        }

        return obj;
    }

    // public static List<T> LuaTableToObjectList<T>(object[] data)
    // {
    //     var list = new List<T>();

    //     // Ensure we have data to process
    //     if (data.Length > 0 && data[0] is LuaTable luaTable)
    //     {
    //         var luaEnumerator = luaTable.GetEnumerator();

    //         while (luaEnumerator.MoveNext())
    //         {
    //             var entry = luaEnumerator.Entry;

    //             var customObject = new KeyValuePair<string, T>
    //             {
    //                 Key = entry.Key.ToString(),
    //                 Value = entry.Value // You can cast or transform the value if needed
    //             };

    //             list.Add(customObject);
    //         }
    //     }

    //     return list;
    //}
}
