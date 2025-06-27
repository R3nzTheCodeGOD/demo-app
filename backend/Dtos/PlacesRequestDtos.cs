namespace PlacesAPI.Dtos;

using System.ComponentModel.DataAnnotations;

public class PlacesRequestDto
{
    [Required]
    [Range(-90.0, 90.0)]
    public double Latitude { get; set; }

    [Required]
    [Range(-180.0, 180.0)]
    public double Longitude { get; set; }

    [Required]
    [Range(100, 50000)]
    public int Radius { get; set; }

    public string LanguageCode { get; set; } = "tr";
    public int MaxResults { get; set; } = 20;
    public bool WithGoogle { get; set; } = true;
}
