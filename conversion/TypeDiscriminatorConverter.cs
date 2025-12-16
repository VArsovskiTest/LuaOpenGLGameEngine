using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

public class TypeDiscriminatorConverter<T> : JsonConverter<T> where T : class
{
    private readonly string _typePropertyName;
    private readonly Dictionary<string, Type> _typeMapping;
    private readonly bool _caseInsensitive;

    public TypeDiscriminatorConverter(
        string typePropertyName = "type",
        bool caseInsensitive = true)
    {
        _typePropertyName = typePropertyName;
        _caseInsensitive = caseInsensitive;
        _typeMapping = BuildTypeMapping();
    }

    private Dictionary<string, Type> BuildTypeMapping()
    {
        var mapping = new Dictionary<string, Type>(
            _caseInsensitive ? 
                StringComparer.OrdinalIgnoreCase : 
                StringComparer.Ordinal);
        
        var baseType = typeof(T);
        
        // Get all concrete types that inherit from T in all loaded assemblies
        var assemblies = AppDomain.CurrentDomain.GetAssemblies()
            .Where(a => !a.IsDynamic && !a.FullName.StartsWith("System.") && !a.FullName.StartsWith("Microsoft."));
        
        foreach (var assembly in assemblies)
        {
            try
            {
                foreach (var type in assembly.GetTypes()
                    .Where(t => t.IsClass && !t.IsAbstract && baseType.IsAssignableFrom(t)))
                {
                    // Try to get discriminator from JsonTypeAttribute
                    var jsonTypeAttr = type.GetCustomAttribute<JsonTypeAttribute>();
                    if (jsonTypeAttr != null)
                    {
                        mapping[jsonTypeAttr.Discriminator] = type;
                        continue;
                    }
                    
                    // Try to get discriminator from type name (as fallback)
                    var simpleName = type.Name.ToLower();
                    if (!mapping.ContainsKey(simpleName))
                    {
                        mapping[simpleName] = type;
                    }
                }
            }
            catch (ReflectionTypeLoadException)
            {
                // Skip assemblies we can't load types from
                continue;
            }
        }
        
        return mapping;
    }

    public override T ReadJson(
        JsonReader reader, 
        Type objectType, 
        T existingValue, 
        bool hasExistingValue, 
        JsonSerializer serializer)
    {
        if (reader.TokenType == JsonToken.Null)
            return null;

        var obj = JObject.Load(reader);
        
        // Find the discriminator property (check common names)
        JToken typeToken = null;
        if (!string.IsNullOrEmpty(_typePropertyName))
        {
            typeToken = obj[_typePropertyName];
        }
        
        if (typeToken == null)
        {
            // Try common alternative names
            typeToken = obj["Type"] ?? obj["$type"] ?? obj["_type"];
        }
        
        if (typeToken == null)
        {
            throw new JsonSerializationException(
                $"No type discriminator found. Looking for property: '{_typePropertyName}'");
        }
        
        string discriminator = typeToken.Value<string>();
        
        if (string.IsNullOrEmpty(discriminator))
        {
            throw new JsonSerializationException("Type discriminator is empty");
        }
        
        if (!_typeMapping.TryGetValue(discriminator, out Type concreteType))
        {
            // Try to find by full type name
            var fullTypeName = discriminator;
            concreteType = Type.GetType(fullTypeName) ?? 
                          _typeMapping.Values.FirstOrDefault(t => t.FullName == fullTypeName);
            
            if (concreteType == null)
            {
                throw new JsonSerializationException(
                    $"No concrete type found for discriminator '{discriminator}'. " +
                    $"Registered types: {string.Join(", ", _typeMapping.Keys)}");
            }
        }
        
        // Create instance and populate
        var instance = Activator.CreateInstance(concreteType) as T;
        if (instance == null)
        {
            throw new JsonSerializationException(
                $"Failed to create instance of type {concreteType.Name}");
        }
        
        using (var objReader = obj.CreateReader())
        {
            serializer.Populate(objReader, instance);
        }
        
        return instance;
    }

    public override void WriteJson(
        JsonWriter writer, 
        T value, 
        JsonSerializer serializer)
    {
        // Let default serialization handle writing
        var obj = JObject.FromObject(value, serializer);
        
        // Ensure type discriminator is included
        if (!string.IsNullOrEmpty(_typePropertyName) && 
            !obj.ContainsKey(_typePropertyName))
        {
            // Try to add discriminator from attribute or type name
            var type = value.GetType();
            var jsonTypeAttr = type.GetCustomAttribute<JsonTypeAttribute>();
            string discriminator = jsonTypeAttr?.Discriminator ?? type.Name.ToLower();
            
            obj[_typePropertyName] = discriminator;
        }
        
        obj.WriteTo(writer);
    }
}

// Optional attribute for explicit discriminator values
[AttributeUsage(AttributeTargets.Class, Inherited = false)]
public class JsonTypeAttribute : Attribute
{
    public string Discriminator { get; }
    
    public JsonTypeAttribute(string discriminator)
    {
        Discriminator = discriminator;
    }
}