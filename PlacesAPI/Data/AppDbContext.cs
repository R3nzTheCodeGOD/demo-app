namespace PlacesApi.Data;

using Microsoft.EntityFrameworkCore;
using PlacesApi.Entities;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    // DbSet: Veritabanındaki bir tabloyu temsil ediyor.
    public DbSet<Place> Places { get; set; }
    public DbSet<Review> Reviews { get; set; }
    public DbSet<GoogleApiQuery> GoogleApiQueries { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasPostgresExtension("postgis");

        // Place ve Review arasında bire-çok (one-to-many) ilişkisi kurar.
        modelBuilder.Entity<Place>()
            .HasMany(p => p.Reviews) // Bir Place'in çok sayıda Review'ı vardır.
            .WithOne(r => r.Place)    // Bir Review'ın sadece bir Place'i vardır.
            .HasForeignKey(r => r.PlaceId) // İki tabloyu bağlayan foreign key 'PlaceId'dir.
            .OnDelete(DeleteBehavior.Cascade); // Bir Place silindiğinde, ona bağlı tüm Review'lar da silinir.

        // Coğrafi sorguları hızlandırmak için GIST index.
        modelBuilder.Entity<Place>()
            .HasIndex(p => p.Location)
            .HasMethod("GIST");

        // Review'ları unique 'Name' alanına göre hızlıca bulmak için index.
        modelBuilder.Entity<Review>()
            .HasIndex(r => r.Name)
            .IsUnique();

        modelBuilder.Entity<Place>(entity =>
        {
            entity.Property(e => e.Location)
                  .HasColumnType("geography (Point, 4326)"); // radius ile metre cinsinden sorgu için Geography yaptım.
        });

        modelBuilder.Entity<GoogleApiQuery>(entity =>
        {
            entity.Property(e => e.Center)
                  .HasColumnType("geography (Point, 4326)");
        });

        base.OnModelCreating(modelBuilder);
    }
}