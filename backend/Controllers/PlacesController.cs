namespace PlacesApi.Controllers;

using Microsoft.AspNetCore.Mvc;
using PlacesApi.Services;
using PlacesAPI.Dtos;

[ApiController]
[Route("api")]
public class PlacesController : ControllerBase
{
    private readonly IPlaceService _placeService;
    private readonly ILogger<PlacesController> _logger;

    public PlacesController(IPlaceService placeService, ILogger<PlacesController> logger)
    {
        _placeService = placeService;
        _logger = logger;
    }


    [HttpPost("getPlaces")]
    public async Task<IActionResult> GetPlaces([FromBody] PlacesRequestDto request)
    {
        if (request == null)
        {
            return BadRequest("İstek gövdesi boş olamaz.");
        }

        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        if (request.Latitude == 0.0 && request.Longitude == 0.0)
        {
            return BadRequest("Latitude ve Longitude değerleri 0,0 olamaz. Lütfen geçerli bir konum belirtin.");
        }

        try
        {
            var result = await _placeService.GetPlacesAsync(
                request.Latitude,
                request.Longitude,
                request.Radius,
                request.LanguageCode,
                request.MaxResults,
                request.WithGoogle
            );
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "GetPlaces endpointinde hata oluştu.");
            return StatusCode(500, "Sunucuda beklenmedik bir hata oluştu.");
        }
    }
}