public static class ActorExtensions {
    public static ActorState AsActorState(this ActorRGB actorRGB)
    {
        return new ActorState
        {
            ActorId = actorRGB.Id,
            X = (actorRGB as IPlaceable).X,
            Y = (actorRGB as IPlaceable).Y,
        };
    }
}