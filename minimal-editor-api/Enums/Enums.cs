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
