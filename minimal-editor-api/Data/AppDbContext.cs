using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using MinimalEngineApi.Models;

namespace MinimalEngineApi.Data;

public class AppDbContext : DbContext
{
    public DbSet<Scene> Scenes { get; set; }
    public DbSet<Actor> Actors { get; set; }
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Scene>()
            .Property(e => e.Id)
            .HasColumnType("binary(16)");

        modelBuilder.Entity<Actor>()
            .Property(e => e.Id)
            .HasColumnType("binary(16)");

        modelBuilder.Entity<Actor>()
            .Property(e => e.SceneId)
            .HasColumnType("binary(16)");

        // Create a converter that knows how to translate between SizeEnum and string
        var sizeEnumConverter = new ValueConverter<Enum_SceneSizeEnum, string>(
            v => v.GetEnumMemberValue(),                        // Convert C# enum to DB value
            v => v.ParseEnumMemberValue<Enum_SceneSizeEnum>()   // Convert DB value to C# enum
        );

        // Apply this converter to the 'Size' property of the 'Scene' entity
        modelBuilder.Entity<Scene>()
            .Property(p => p.Size)
            .HasConversion(sizeEnumConverter)
            .HasDefaultValue(Enum_SceneSizeEnum.Unset);

        modelBuilder.Entity<Actor>()
            .HasOne(a => a.Scene)
            .WithMany(s => s.Actors)
            .HasForeignKey(a => a.SceneId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
