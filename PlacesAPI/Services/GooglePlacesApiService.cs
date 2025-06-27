namespace PlacesApi.Services;

using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using PlacesApi.Dtos;
using System.Net.Http.Headers;

public class GooglePlacesApiService : IGooglePlacesApiService
{
    private readonly HttpClient _httpClient;
    private readonly string _apiKey;
    public GooglePlacesApiService(HttpClient httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _apiKey = configuration["GoogleApi:ApiKey"] ?? throw new InvalidOperationException("API Key Bulunamadı");
        _httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
    }

    public async Task<GooglePlacesSearchResponse?> SearchNearbyAsync(double lat, double lng, int radius, string languageCode, int maxResults)
    {
        var payload = new { maxResultCount = maxResults, locationRestriction = new { circle = new { center = new { latitude = lat, longitude = lng }, radius } }, languageCode };
        var request = new HttpRequestMessage(HttpMethod.Post, "https://places.googleapis.com/v1/places:searchNearby")
        { Content = new StringContent(JsonConvert.SerializeObject(payload), System.Text.Encoding.UTF8, "application/json") };
        request.Headers.Add("X-Goog-Api-Key", _apiKey);
        request.Headers.Add("X-Goog-FieldMask", "places.id,places.displayName,places.location,places.rating,places.userRatingCount,places.formattedAddress,places.primaryTypeDisplayName,places.reviews,places.iconBackgroundColor,places.iconMaskBaseUri");
        var response = await _httpClient.SendAsync(request);
        if (response.IsSuccessStatusCode)
        {
            var jsonString = await response.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<GooglePlacesSearchResponse>(jsonString);
        }
        return null;
    }
}