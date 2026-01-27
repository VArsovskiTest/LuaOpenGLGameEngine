public static class ActorExtensions {
    public static ActorState AsActorState(this ActorRGB actorRGB)
    {
        return new ActorState(actorRGB.Id, (actorRGB as IPlaceable).X, (actorRGB as IPlaceable).Y, Enum_ControlledByEnum.Player);
    }
}