namespace PlacesApi.Entities;

using System.ComponentModel.DataAnnotations;

public class Review
{
    [Key]
    public int Id { get; set; }

    [Required]
    public string Name { get; set; } = string.Empty;

    public double Rating { get; set; }
    public string? Text { get; set; }
    public string? LanguageCode { get; set; }
    public string AuthorDisplayName { get; set; } = string.Empty;
    public string? AuthorPhotoUri { get; set; }
    public string RelativePublishTimeDescription { get; set; } = string.Empty;
    public DateTime PublishTime { get; set; }

    // review tablosunu place tablosuna bağla
    public string PlaceId { get; set; } = string.Empty;

    // hangi place'e ait olduğu
    public virtual Place? Place { get; set; }
}