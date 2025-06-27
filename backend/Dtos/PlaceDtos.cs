namespace PlacesApi.Dtos;

using Newtonsoft.Json;

public record GooglePlacesSearchResponse([JsonProperty("places")] List<GooglePlace> Places);
public record GooglePlace(
    [JsonProperty("id")] string Id,
    [JsonProperty("location")] GoogleLocation Location,
    [JsonProperty("displayName")] GoogleDisplayName DisplayName,
    [JsonProperty("rating")] double? Rating,
    [JsonProperty("userRatingCount")] int? UserRatingCount,
    [JsonProperty("formattedAddress")] string? FormattedAddress,
    [JsonProperty("primaryTypeDisplayName")] GoogleDisplayName? PrimaryTypeDisplayName,
    [JsonProperty("reviews")] List<GoogleReview>? Reviews,
    [JsonProperty("iconMaskBaseUri")] string? IconMaskBaseUri,
    [JsonProperty("iconBackgroundColor")] string? IconBackgroundColor
);
public record GoogleLocation(double Latitude, double Longitude);
public record GoogleDisplayName(string Text, string LanguageCode);
public record GoogleReview(
    string Name,
    string RelativePublishTimeDescription,
    double Rating,
    GoogleDisplayName? Text,
    GoogleAuthorAttribution AuthorAttribution,
    DateTime PublishTime
);
public record GoogleAuthorAttribution(string DisplayName, string Uri, string PhotoUri);

public record PlaceResponseDto(List<PlaceDto> Places);
public record PlaceDto(
    string Id,
    PlaceLocationDto Location,
    double? Rating,
    int? UserRatingCount,
    DisplayNameDto DisplayName,
    string? FormattedAddress,
    DisplayNameDto? PrimaryTypeDisplayName,
    List<ReviewDto> Reviews,
    string? IconMaskBaseUri,
    string? IconBackgroundColor
);
public record PlaceLocationDto(double Latitude, double Longitude);
public record DisplayNameDto(string Text, string LanguageCode);
public record ReviewDto(
    string Name,
    string RelativePublishTimeDescription,
    double Rating,
    DisplayNameDto? Text,
    AuthorAttributionDto AuthorAttribution,
    DateTime PublishTime
);
public record AuthorAttributionDto(string DisplayName, string Uri, string PhotoUri);