public interface IPosition
{
    public float X { get; set; }
    public float Y { get; set; }
}

public interface IRegen
{
    public int Max { get; set; }
    public int Current { get; set; }
    public float Regen { get; set; }
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
    IPosition Position { get; set; }
}
