namespace PlacesApi.Services;

using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using NetTopologySuite;
using NetTopologySuite.Geometries;
using PlacesApi.Data;
using PlacesApi.Dtos;
using PlacesApi.Entities;
using System.Linq;

public class PlaceService : IPlaceService
{
    private readonly AppDbContext _context;
    private readonly IGooglePlacesApiService _googleApiService;
    private readonly ILogger<PlaceService> _logger;
    private readonly GeometryFactory _geometryFactory;

    public PlaceService(AppDbContext context, IGooglePlacesApiService googleApiService, ILogger<PlaceService> logger)
    {
        _context = context;
        _googleApiService = googleApiService;
        _logger = logger;
        _geometryFactory = NtsGeometryServices.Instance.CreateGeometryFactory(srid: 4326); // WGS 84
    }

    public async Task<PlaceResponseDto> GetPlacesAsync(double lat, double lng, int radius, string languageCode, int maxResults, bool withGoogle)
    {
        var requestLocation = _geometryFactory.CreatePoint(new Coordinate(lng, lat));
        await LogGoogleApiQuery(requestLocation, radius);

        if (!withGoogle)
        {
            return await GetPlacesFromDbOnlyAsync(requestLocation, radius);
        }

        var placesFromGoogle = await _googleApiService.SearchNearbyAsync(lat, lng, radius, languageCode, maxResults);

        if (placesFromGoogle?.Places != null && placesFromGoogle.Places.Any())
        {
            await SaveOrUpdatePlacesFromGoogle(placesFromGoogle.Places);
        }

        // Google'dan gelen veriler veritabanına kaydedildikten sonra,
        // en güncel ve birleştirilmiş listeyi veritabanından tekrar çek.
        var finalPlaces = await GetPlacesFromDbOnlyAsync(requestLocation, radius);
        return finalPlaces;
    }

    private async Task<PlaceResponseDto> GetPlacesFromDbOnlyAsync(Point center, int radius)
    {
        // LINQ Sorgu
        var placesInDb = await _context.Places
            .Include(p => p.Reviews) // LEFT JOIN
            .Where(p => p.Location.IsWithinDistance(center, radius)) // Belirtilen mesafe içindekileri bul
            .ToListAsync();

        var placeDtos = placesInDb.Select(MapPlaceEntityToDto).ToList();
        return new PlaceResponseDto(placeDtos);
    }

    private async Task SaveOrUpdatePlacesFromGoogle(List<GooglePlace> googlePlaces)
    {
        var placeIds = googlePlaces.Select(p => p.Id).ToList();

        // Veritabanında zaten var olan işletmeleri ve onların yorumlarını tek bir sorguyla çek.
        var existingPlaces = await _context.Places
            .Include(p => p.Reviews)
            .Where(p => placeIds.Contains(p.Id))
            .ToDictionaryAsync(p => p.Id);

        foreach (var googlePlace in googlePlaces)
        {
            if (existingPlaces.TryGetValue(googlePlace.Id, out var existingPlace))
            {
                // İşletme Zaten Var -> Güncelle ve Yorumları Birleştir
                UpdatePlaceEntity(existingPlace, googlePlace);
                await MergeReviewsAsync(existingPlace, googlePlace.Reviews ?? new List<GoogleReview>());
            }
            else
            {
                // İşletme Yeni -> Ekle
                var newPlace = MapGooglePlaceToEntity(googlePlace);
                _context.Places.Add(newPlace);
            }
        }

        await _context.SaveChangesAsync(); // Commit
    }

    private async Task MergeReviewsAsync(Place placeInDb, List<GoogleReview> reviewsFromGoogle)
    {
        if (!reviewsFromGoogle.Any()) return;

        // (O(1)) için hashset kullan
        var existingReviewNames = placeInDb.Reviews.Select(r => r.Name).ToHashSet();
        var newReviewsToAdd = new List<Review>();

        foreach (var googleReview in reviewsFromGoogle)
        {
            // yeni yorum
            if (!existingReviewNames.Contains(googleReview.Name))
            {
                newReviewsToAdd.Add(MapGoogleReviewToEntity(googleReview, placeInDb.Id));
            }
        }

        if (newReviewsToAdd.Any())
        {
            await _context.Reviews.AddRangeAsync(newReviewsToAdd);
        }
    }

    private async Task LogGoogleApiQuery(Point center, int radius)
    {
        await _context.GoogleApiQueries.AddAsync(new GoogleApiQuery { Center = center, Radius = radius, QueryDate = DateTime.UtcNow });
    }

    private Place MapGooglePlaceToEntity(GooglePlace gp) => new()
    {
        Id = gp.Id,
        DisplayName = gp.DisplayName.Text,
        Location = _geometryFactory.CreatePoint(new Coordinate(gp.Location.Longitude, gp.Location.Latitude)),
        Rating = gp.Rating,
        UserRatingCount = gp.UserRatingCount,
        FormattedAddress = gp.FormattedAddress,
        PrimaryTypeDisplayName = gp.PrimaryTypeDisplayName?.Text,
        IconBackgroundColor = gp.IconBackgroundColor,
        IconMaskBaseUri = gp.IconMaskBaseUri,
        LastGoogleUpdateDate = DateTime.UtcNow,
        // Yeni Place oluşturulurken, Google'dan gelen tüm yorumları da oluştur.
        Reviews = gp.Reviews?.Select(gr => MapGoogleReviewToEntity(gr, gp.Id)).ToList() ?? new List<Review>()
    };

    private Review MapGoogleReviewToEntity(GoogleReview gr, string placeId) => new()
    {
        Name = gr.Name,
        PlaceId = placeId,
        Rating = gr.Rating,
        Text = gr.Text?.Text,
        LanguageCode = gr.Text?.LanguageCode,
        AuthorDisplayName = gr.AuthorAttribution.DisplayName,
        AuthorPhotoUri = gr.AuthorAttribution.PhotoUri,
        RelativePublishTimeDescription = gr.RelativePublishTimeDescription,
        PublishTime = gr.PublishTime,
    };

    private void UpdatePlaceEntity(Place place, GooglePlace gp)
    {
        place.DisplayName = gp.DisplayName.Text;
        place.Rating = gp.Rating;
        place.UserRatingCount = gp.UserRatingCount;
        place.LastGoogleUpdateDate = DateTime.UtcNow;
    }

    private PlaceDto MapPlaceEntityToDto(Place place)
    {
        return new PlaceDto(
            place.Id,
            new PlaceLocationDto(place.Location.Y, place.Location.X),
            place.Rating,
            place.UserRatingCount,
            new DisplayNameDto(place.DisplayName, "tr"),
            place.FormattedAddress,
            place.PrimaryTypeDisplayName != null ? new DisplayNameDto(place.PrimaryTypeDisplayName, "tr") : null,
            place.Reviews.Select(MapReviewEntityToDto).ToList(),
            place.IconMaskBaseUri,
            place.IconBackgroundColor
        );
    }

    private ReviewDto MapReviewEntityToDto(Review review)
    {
        return new ReviewDto(
            review.Name,
            review.RelativePublishTimeDescription,
            review.Rating,
            review.Text != null ? new DisplayNameDto(review.Text, review.LanguageCode ?? "tr") : null,
            new AuthorAttributionDto(review.AuthorDisplayName, "", review.AuthorPhotoUri ?? ""),
            review.PublishTime
        );
    }
}