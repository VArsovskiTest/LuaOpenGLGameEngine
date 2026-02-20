using Microsoft.EntityFrameworkCore;
using MinimalEngineApi.Data;

public class DbContextHelper
{
    private AppDbContext _context;

    public DbContextHelper(MinimalEngineApi.Data.AppDbContext context)
    {
        _context = context;
    }

    public void CurrentDbContextState()
    {
        var entries = _context.ChangeTracker.Entries().Where(e => e.State != EntityState.Unchanged).ToList();
        foreach (var entry in entries)
        {
            Console.WriteLine($"Entity: {entry.Entity.GetType().Name}, State: {entry.State}");

            // Primary key(s)
            var pkValues = entry.Metadata.FindPrimaryKey()
                ?.Properties
                .Select(p => $"{p.Name} = {entry.CurrentValues[p.Name]}")
                ?? new[] { "No PK found" };
            Console.WriteLine("  PK: " + string.Join(", ", pkValues));

            // All changed/modified properties (for Modified state especially useful)
            var changedProps = entry.Properties
                .Where(p => p.IsModified)
                .Select(p => $"{p.Metadata.Name} = {p.CurrentValue} (original: {p.OriginalValue})");

            if (changedProps.Any())
            {
                Console.WriteLine("  Modified properties:");
                foreach (var prop in changedProps)
                    Console.WriteLine("    " + prop);
            }

            // If you suspect a concurrency token (RowVersion, Timestamp, etc.)
            var concurrencyProps = entry.Properties
                .Where(p => p.Metadata.IsConcurrencyToken)
                .Select(p => $"{p.Metadata.Name}: current={p.CurrentValue}, original={p.OriginalValue}");

            if (concurrencyProps.Any())
            {
                Console.WriteLine("  Concurrency tokens:");
                foreach (var ct in concurrencyProps)
                    Console.WriteLine("    " + ct);
            }
        }        
    }
}