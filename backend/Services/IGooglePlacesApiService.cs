namespace PlacesApi.Services;

using PlacesApi.Dtos;

public interface IGooglePlacesApiService
{
    Task<GooglePlacesSearchResponse?> SearchNearbyAsync(double lat, double lng, int radius, string languageCode, int maxResults);
}