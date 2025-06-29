import 'package:flutter/material.dart';
import 'package:client/features/map/models/place_data.dart';

/// Yer detaylarını gösteren alt sayfa widget'ı.
class PlaceDetailsBottomSheet extends StatelessWidget {
  final Place place;

  const PlaceDetailsBottomSheet({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(15),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Yer adı
            Text(place.displayName.text, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            // Yer türü
            if (place.primaryTypeDisplayName != null)
              Text(place.primaryTypeDisplayName!.text, style: textTheme.titleMedium?.copyWith(color: colorScheme.secondary, fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            // Formatlanmış adres
            if (place.formattedAddress != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined, color: colorScheme.onSurfaceVariant, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(place.formattedAddress!, style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant))),
                ],
              ),
            const SizedBox(height: 16),
            // Puan ve yorum sayısı
            Row(
              children: [
                Icon(Icons.star, color: colorScheme.tertiary, size: 20),
                const SizedBox(width: 8),
                Text("${place.rating ?? "N/A"} (${place.userRatingCount ?? "0"} yorum)", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 16),
            // Yorumlar başlığı
            Text("Yorumlar:", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 10),
            // Yorum listesi
            if (place.reviews.isNotEmpty)
              ...place.reviews.map((review) => buildReviewCard(context, review))
            else
              Text("Bu yer için yorum bulunmamaktadır.", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            // Kapat butonu
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tek bir yorum kartı oluşturan yardımcı metot.
  Widget buildReviewCard(BuildContext context, Review review) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        shadowColor: colorScheme.surfaceContainerHighest,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundImage: NetworkImage(review.authorAttribution.photoUri), radius: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      review.authorAttribution.displayName,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                  ),
                  Row(children: List.generate(review.rating.toInt(), (index) => Icon(Icons.star, size: 20, color: colorScheme.tertiary))),
                ],
              ),
              const SizedBox(height: 8),
              // Yorum metni null olabilir
              if (review.text?.text.isNotEmpty == true)
                Text(review.text!.text, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Text(review.relativePublishTimeDescription, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withAlpha(180))),
            ],
          ),
        ),
      ),
    );
  }
}
