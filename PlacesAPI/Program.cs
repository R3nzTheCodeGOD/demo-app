using Microsoft.EntityFrameworkCore;
using Npgsql;
using PlacesApi.Data;
using PlacesApi.Services;


var builder = WebApplication.CreateBuilder(args);

// servis konfigürasyonu
builder.Services.AddScoped<IPlaceService, PlaceService>();
builder.Services.AddScoped<IGooglePlacesApiService, GooglePlacesApiService>();
builder.Services.AddHttpClient<IGooglePlacesApiService, GooglePlacesApiService>();

// veritabanı bağlantı yapılandırması.
var connectionString = builder.Configuration.GetConnectionString("PostgreSql");

// Postgis extensionunu aktif et (extension yüklü olmalı)
var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionString);
dataSourceBuilder.UseNetTopologySuite();
var dataSource = dataSourceBuilder.Build();


builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(dataSource, o => o.UseNetTopologySuite())
);


builder.Services.AddControllers()
    .AddNewtonsoftJson(options =>
    {
        options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<AppDbContext>();
        context.Database.Migrate(); // Mevcut tüğm migration'ları veritabanına uygular.
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Veritabanı migration sonrasında bir hata oluştu.");
    }
}

app.Run();