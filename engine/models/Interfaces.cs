public interface IPlaceable
{
    public float X { get; set; }
    public float Y { get; set; }
}

public interface IColorable
{
    float r { get; set; }
    float g { get; set; }
    float b { get; set; }
}

public interface IRegen
{
    public int Max { get; set; }
    public int Current { get; set; }
    public float Regen { get; set; }
}

public interface IActor
{
    Guid Id { get; set; }
    bool hovered { get; set; }
    bool selected { get; set; }
    bool isDirty { get; set; }
}

public interface IGenericEntity
{
    string Id { get; set; }
    float Damage { get; set; }
    float Spellpower { get; set; }
    float Armor { get; set; }
    float SightRange { get; set; }
    IRegen HP { get; set; }
    IRegen Resource { get; set; }
    IPlaceable Position { get; set; }
}
