import 'package:flutter/material.dart';
import 'package:client/features/map/models/place_data.dart';

/// İşletme detaylarını gösteren alt sayfa widget'ı.
class PlaceDetailsBottomSheet extends StatelessWidget {
  final Place place;

  const PlaceDetailsBottomSheet({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(15),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // İşletme adı
              Text(
                place.displayName.text,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // işletme türü
              if (place.primaryTypeDisplayName != null)
                Text(
                  place.primaryTypeDisplayName!.text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 10),
              // Formatlanmış adres
              if (place.formattedAddress != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.formattedAddress!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 15),
              // Puan ve yorum sayısı
              Row(
                children: [
                  Icon(Icons.star, color: colorScheme.tertiary, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    '${place.rating ?? 'N/A'} (${place.userRatingCount ?? '0'} yorum)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Yorumlar başlığı
              Text(
                'Yorumlar:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              // Yorum listesi
              if (place.reviews.isNotEmpty)
                ...place.reviews.map(
                  (review) => buildReviewCard(context, review),
                )
              else
                Text(
                  'Bu işletme için yorum bulunmamaktadır.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 15),
              // Kapat butonu
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Kapat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tek bir yorum kartı oluşturan yardımcı metot.
  Widget buildReviewCard(BuildContext context, Review review) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      review.authorAttribution.photoUri,
                    ),
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      review.authorAttribution.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      review.rating.toInt(),
                      (index) => Icon(
                        Icons.star,
                        size: 18,
                        color: colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Yorum metni null olabilir
              if (review.text?.text.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    review.text!.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                review.relativePublishTimeDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
