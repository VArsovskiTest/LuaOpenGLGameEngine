using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

public static class JsonSettingsFactory
{
    private static readonly Dictionary<Type, JsonConverter> _registeredConverters = 
        new Dictionary<Type, JsonConverter>();
    
    private static readonly Dictionary<Type, JsonSerializerSettings> _settingsCache = 
        new Dictionary<Type, JsonSerializerSettings>();
    
    private static readonly object _lock = new object();

    static JsonSettingsFactory()
    {
        // Optional: Register default converters here
        // RegisterDefaultConverters();
    }

    /// <summary>
    /// Register a converter for a specific base type
    /// </summary>
    public static void RegisterConverter<T>(JsonConverter converter) where T : class
    {
        lock (_lock)
        {
            _registeredConverters[typeof(T)] = converter;
            _settingsCache.Clear(); // Clear cache since settings may change
        }
    }

    /// <summary>
    /// Register a TypeDiscriminatorConverter for a type with custom discriminator
    /// </summary>
    public static void RegisterDiscriminatorConverter<T>(
        string discriminatorProperty = "type",
        bool caseInsensitive = true) where T : class
    {
        var converter = new TypeDiscriminatorConverter<T>(discriminatorProperty, caseInsensitive);
        RegisterConverter<T>(converter);
    }

    /// <summary>
    /// Get JsonSerializerSettings configured for a specific type
    /// </summary>
    public static JsonSerializerSettings GetSettingsForType(Type type)
    {
        lock (_lock)
        {
            if (_settingsCache.TryGetValue(type, out var cachedSettings))
                return cachedSettings;

            var settings = CreateSettingsForType(type);
            _settingsCache[type] = settings;
            return settings;
        }
    }

    /// <summary>
    /// Get JsonSerializerSettings configured for type T
    /// </summary>
    public static JsonSerializerSettings GetSettingsForType<T>()
    {
        return GetSettingsForType(typeof(T));
    }

    private static JsonSerializerSettings CreateSettingsForType(Type type)
    {
        var settings = new JsonSerializerSettings
        {
            ContractResolver = new CamelCasePropertyNamesContractResolver(),
            NullValueHandling = NullValueHandling.Ignore,
            ReferenceLoopHandling = ReferenceLoopHandling.Ignore,
            Formatting = Formatting.None
        };

        // Add converters based on the type structure
        AddConvertersForType(type, settings.Converters);
        
        return settings;
    }

    private static void AddConvertersForType(Type type, IList<JsonConverter> converters)
    {
        // Check if the type itself has a registered converter
        if (_registeredConverters.TryGetValue(type, out var converter))
        {
            if (!converters.Contains(converter))
                converters.Add(converter);
        }

        // Handle generic types
        if (type.IsGenericType)
        {
            foreach (var genericArg in type.GetGenericArguments())
            {
                AddConvertersForType(genericArg, converters);
            }
        }

        // Handle arrays
        if (type.IsArray)
        {
            var elementType = type.GetElementType();
            if (elementType != null)
            {
                AddConvertersForType(elementType, converters);
            }
        }

        // Handle collections (List<T>, IEnumerable<T>, etc.)
        if (type.GetInterfaces().Any(i => 
            i.IsGenericType && 
            (i.GetGenericTypeDefinition() == typeof(IEnumerable<>) ||
             i.GetGenericTypeDefinition() == typeof(ICollection<>))))
        {
            var elementType = type.GetGenericArguments().FirstOrDefault();
            if (elementType != null)
            {
                AddConvertersForType(elementType, converters);
            }
        }
    }

    /// <summary>
    /// Deserialize JSON with automatic converter configuration
    /// </summary>
    public static T Deserialize<T>(string json) where T : class
    {
        var settings = GetSettingsForType<T>();
        return JsonConvert.DeserializeObject<T>(json, settings);
    }

    /// <summary>
    /// Serialize object with automatic converter configuration
    /// </summary>
    public static string Serialize<T>(T obj) where T : class
    {
        var settings = GetSettingsForType<T>();
        return JsonConvert.SerializeObject(obj, settings);
    }

    /// <summary>
    /// Clear all cached settings (useful for testing or dynamic converter registration)
    /// </summary>
    public static void ClearCache()
    {
        lock (_lock)
        {
            _settingsCache.Clear();
        }
    }
}