using Microsoft.EntityFrameworkCore;
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

        modelBuilder.Entity<Actor>()
            .HasOne(a => a.Scene)
            .WithMany(s => s.Actors)
            .HasForeignKey(a => a.SceneId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
