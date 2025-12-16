using System;
using OpenTK.Graphics.OpenGL;

public enum AttackTypes { MELEE, RANGED, MAGIC }

public class Armament
{
    // Define properties relevant to Armament
}

public class Specialization
{
    // Define properties relevant to Specialization
}

public class RegenStat : IRegen
{
    public int Max { get; set; }
    public int Current { get; set; }
    public float Regen { get; set; }

    public RegenStat(int max, int current, float regen)
    {
        Max = max;
        Current = current;
        Regen = regen;
    }
}

public class PlayerData : IGenericEntity
{
    public string Id { get; set; }
    public string Name { get; set; }
    public float Damage { get; set; }
    public float Spellpower { get; set; }
    public float Armor { get; set; }
    public float SightRange { get; set; }
    public Armament[] Armaments { get; }
    public IRegen HP { get; set; }
    public IRegen Resource { get; set; }
    public IPosition Position { get; set; }

    public PlayerData(string name, int maxHp, int hp, float hpRegen, int maxResource, int resource, 
                   float resourceRegen, int damage, int spellpower, int sightRange, Armament[] armaments)
    {
        Name = name;
        HP = new RegenStat(maxHp, hp, hpRegen);
        Resource = new RegenStat(maxResource, resource, resourceRegen);
        Damage = damage;
        Spellpower = spellpower;
        SightRange = sightRange;
        Armaments = armaments;
    }

    public override string ToString()
    {
        return $"Player: name: {Name}, HP: {HP.Current}/{HP.Max}, Resources: {Resource.Current/Resource.Max} Damage: {Damage}";
    }
}

public class MonsterData : IGenericEntity
{
    public string Id { get; set; }
    public string Name { get; set; }
    public float Damage { get; set; }
    public float Spellpower { get; set; }
    public float Armor {get; set; }
    public float SightRange { get; set; }
    public IRegen HP { get; set; }
    public IRegen Resource { get; set; }
    public IPosition Position { get; set; }

    public double RetreatThreshold { get; set; }
    public Armament[] Armaments { get; set; }
    public Specialization Specialization { get; set; }
    public AttackTypes AttackType { get; set; }

    public MonsterData(string name, int maxHp, int hp, float hpRegen, int maxResource, int resource, 
                   float resourceRegen, int damage, int spellpower, int sightRange, 
                   float retreatThreshold, Armament[] armaments, Specialization specialization, 
                   AttackTypes attackType)
    {
        Name = name;
        HP = new RegenStat(maxHp, hp, hpRegen);
        Resource = new RegenStat(maxResource, resource, resourceRegen);
        Damage = damage;
        Spellpower = spellpower;
        SightRange = sightRange;
        RetreatThreshold = retreatThreshold;
        Armaments = armaments;
        Specialization = specialization;
        AttackType = attackType;
    }

    public override string ToString()
    {
        return Resource.Max != 0
        ? $"Name: {Name}, HP: {HP.Current}/{HP.Max}, Damage: {Damage}, Resource: {Resource.Current}/{Resource.Max} AttackType: {AttackType}"
        : $"Name: {Name}, HP: {HP.Current}/{HP.Max}, Damage: {Damage}, AttackType: {AttackType}";
    }
}
