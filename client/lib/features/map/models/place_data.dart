class PlaceResponse {
  final List<Place> places;

  PlaceResponse({required this.places});

  factory PlaceResponse.fromJson(Map<String, dynamic> json) {
    return PlaceResponse(
      places: (json['places'] as List<dynamic>?)?.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

class Place {
  final String id;
  final PlaceLocation location;
  final double? rating;
  final int? userRatingCount;
  final DisplayName displayName;
  final String? formattedAddress;
  final DisplayName? primaryTypeDisplayName;
  final List<Review> reviews;
  final String? iconMaskBaseUri;
  final String? iconBackgroundColor;

  Place({
    required this.id,
    required this.location,
    this.rating,
    this.userRatingCount,
    required this.displayName,
    this.formattedAddress,
    this.primaryTypeDisplayName,
    required this.reviews,
    this.iconMaskBaseUri,
    this.iconBackgroundColor,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      location: PlaceLocation.fromJson(json['location'] as Map<String, dynamic>),
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingCount: json['userRatingCount'] as int?,
      displayName: DisplayName.fromJson(json['displayName'] as Map<String, dynamic>),
      formattedAddress: json['formattedAddress'] as String?,
      primaryTypeDisplayName: json['primaryTypeDisplayName'] != null
          ? DisplayName.fromJson(json['primaryTypeDisplayName'] as Map<String, dynamic>) : null,
      reviews: (json['reviews'] as List<dynamic>?)?.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      iconMaskBaseUri: json['iconMaskBaseUri'] as String?,
      iconBackgroundColor: json['iconBackgroundColor'] as String?
    );
  }
}

class PlaceLocation {
  final double latitude;
  final double longitude;

  PlaceLocation({required this.latitude, required this.longitude});

  factory PlaceLocation.fromJson(Map<String, dynamic> json) {
    return PlaceLocation(latitude: (json['latitude'] as num).toDouble(), longitude: (json['longitude'] as num).toDouble());
  }
}

class DisplayName {
  final String text;
  final String languageCode;

  DisplayName({required this.text, required this.languageCode});

  factory DisplayName.fromJson(Map<String, dynamic> json) {
    return DisplayName(text: json['text'] as String, languageCode: json['languageCode'] as String);
  }
}

class Review {
  final String name;
  final String relativePublishTimeDescription;
  final double rating;
  final DisplayName? text;
  final AuthorAttribution authorAttribution;
  final String publishTime;

  Review({
    required this.name,
    required this.relativePublishTimeDescription,
    required this.rating,
    this.text,
    required this.authorAttribution,
    required this.publishTime,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      name: json['name'] as String,
      relativePublishTimeDescription: json['relativePublishTimeDescription'] as String,
      rating: (json['rating'] as num).toDouble(),
      text: json['text'] != null
          ? DisplayName.fromJson(json['text'] as Map<String, dynamic>) : null,
      authorAttribution: AuthorAttribution.fromJson(json['authorAttribution'] as Map<String, dynamic>),
      publishTime: json['publishTime'] as String
    );
  }
}

class AuthorAttribution {
  final String displayName;
  final String uri;
  final String photoUri;

  AuthorAttribution({
    required this.displayName,
    required this.uri,
    required this.photoUri,
  });

  factory AuthorAttribution.fromJson(Map<String, dynamic> json) {
    return AuthorAttribution(
      displayName: json['displayName'] as String,
      uri: json['uri'] as String,
      photoUri: json['photoUri'] as String,
    );
  }
}
