namespace PlacesApi.Entities;

using NetTopologySuite.Geometries;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class GoogleApiQuery
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }
    public Point Center { get; set; } = Point.Empty;
    public int Radius { get; set; }
    public DateTime QueryDate { get; set; }
}