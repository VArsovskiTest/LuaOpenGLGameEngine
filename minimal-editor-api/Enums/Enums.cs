using System.Runtime.Serialization;

public enum Enum_SceneSizeEnum
{
    [EnumMember(Value = "nil")]
    Unset,
    [EnumMember(Value = "s")]
    Small,
    [EnumMember(Value = "m")]
    Medium,
    [EnumMember(Value = "l")]
    Large,
    [EnumMember(Value = "xl")]
    XtraLarge
}

public enum Enum_ActorTypesEnum
{
    [EnumMember(Value = "nil")]
    Unset,
    [EnumMember(Value = "circle")]
    Circle,
    [EnumMember(Value = "rectangle")]
    Rectangle,
    [EnumMember(Value = "background")]
    Background,
    [EnumMember(Value = "resource-bar")]
    ResourceBar,
    [EnumMember(Value = "image")]
    Image
}
