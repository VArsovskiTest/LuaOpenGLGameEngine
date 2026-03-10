namespace engine_api.Models
{
    public static class EnumModelTransformations
    {
        public static Dictionary<Enum_ActorTypesEnum, string> ActorTypeEnumTransformation = new Dictionary<Enum_ActorTypesEnum, string>
        {
            { Enum_ActorTypesEnum.Circle, "circle" },
            { Enum_ActorTypesEnum.Rectangle, "rectangle" },
            { Enum_ActorTypesEnum.Background, "background" },
            { Enum_ActorTypesEnum.ResourceBar, "resource-bar" },
            { Enum_ActorTypesEnum.Image, "image" }
        };
    }
}
