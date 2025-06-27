namespace PlacesApi.Entities;

using NetTopologySuite.Geometries;
using System.ComponentModel.DataAnnotations;

public class Place
{
    [Key] // Primary Key
    public string Id { get; set; } = string.Empty;

    public string DisplayName { get; set; } = string.Empty;

    public Point Location { get; set; } = Point.Empty;

    public double? Rating { get; set; }
    public int? UserRatingCount { get; set; }
    public string? FormattedAddress { get; set; }
    public string? PrimaryTypeDisplayName { get; set; }
    public string? IconMaskBaseUri { get; set; }
    public string? IconBackgroundColor { get; set; }
    public DateTime LastGoogleUpdateDate { get; set; }

    // 'virtual' ef'nin lazy load yapması için.
    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
}