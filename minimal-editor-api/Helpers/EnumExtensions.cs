using System.Runtime.Serialization;

public static class EnumExtensions
{
    public static string GetEnumMemberValue<T>(this T enumValue)
        where T : Enum
    {
        var type = typeof(T);
        var memberInfo = type.GetMember(enumValue.ToString());
        var attributes = memberInfo[0].GetCustomAttributes(typeof(EnumMemberAttribute), false);

        // Return the EnumMember value if it exists, otherwise return the enum's name (e.g., "Small")
        return attributes.Length > 0 ? ((EnumMemberAttribute)attributes[0]).Value : enumValue.ToString();
    }

    public static T ParseEnumMemberValue<T>(this string value) where T : Enum
    {
        var type = typeof(T);
        foreach (var field in type.GetFields())
        {
            var attribute = Attribute.GetCustomAttribute(field, typeof(EnumMemberAttribute)) as EnumMemberAttribute;
            if (attribute != null && attribute.Value == value)
            {
                return (T)field.GetValue(null);
            }
        }
        // Fallback to standard parsing if no EnumMember matches
        return (T)Enum.Parse(typeof(T), value, true);
    }
}
