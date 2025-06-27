namespace PlacesApi.Services;

using PlacesApi.Dtos;

public interface IPlaceService
{
    Task<PlaceResponseDto> GetPlacesAsync(double lat, double lng, int radius, string languageCode, int maxResults, bool withGoogle);
}