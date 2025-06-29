import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Konum bazlı işlemler için alt sayfa (bottom sheet).
/// Haritadaki bir konum markerına ('current' veya 'selected') tıklandığında açılır.
class LocationActionBottomSheet extends StatelessWidget {
  final LatLng location;
  final String type;

  /// "Etraftaki İşletmeleri Getir" butonuna basıldığında çağrılacak fonksiyon.
  final Function(LatLng location) onFetchPlaces;

  const LocationActionBottomSheet({
    super.key,
    required this.location,
    required this.type,
    required this.onFetchPlaces,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(type == "current" ? "Mevcut Konumunuz" : "Seçilen Konum", style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: 10),
          Text("Enlem: ${location.latitude}\nBoylam: ${location.longitude}", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.store, color: colorScheme.onPrimary),
            label: Text("Etraftaki Yerleri Getir", style: TextStyle(color: colorScheme.onPrimary)),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pop(context);
              onFetchPlaces(location);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
