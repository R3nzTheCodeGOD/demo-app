import 'dart:async';
import 'package:client/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:client/core/services/location_service.dart';
import 'package:client/core/services/places_api_service.dart';
import 'package:client/core/utils/snackbar_helper.dart';
import 'package:client/features/map/models/place_data.dart';
import 'package:client/features/map/utils/marker_generator.dart';
import 'package:client/features/map/widgets/location_action_bottom_sheet.dart';
import 'package:client/features/map/widgets/place_details_bottom_sheet.dart';

enum MapScreenState { idle, loadingLocation, loadingPlaces }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final Set<Marker> _markers = {};

  final LocationService _locationService = LocationService();
  final PlacesApiService _placesApiService = PlacesApiService();

  MapScreenState _screenState = MapScreenState.idle;

  // FSM Köprüsü
  static const CameraPosition _initialCameraPosition = CameraPosition(target: LatLng(41.091150, 29.061505), zoom: 10.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getCurrentLocation());
  }

  Future<void> _setScreenState(MapScreenState state) async {
    if (mounted) setState(() => _screenState = state);
  }

  Future<void> _getCurrentLocation() async {
    if (_screenState == MapScreenState.loadingLocation) return;
    _setScreenState(MapScreenState.loadingLocation);

    try {
      final position = await _locationService.determinePosition();
      final currentLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _updateSimpleMarker(
          id: "currentLocation",
          location: currentLocation,
          title: "Konumunuz",
          hue: BitmapDescriptor.hueAzure,
          onTapAction: () => _showLocationActionBottomSheet(currentLocation, "current"),
        );
      });

      _animateToLocation(currentLocation);
      SnackbarHelper.show(context, "Konumunuza yakınlaşıldı.", SnackBarType.success);
    } catch (e) {
      SnackbarHelper.show(context, "Konum alınamadı: $e", SnackBarType.error);
    } finally {
      _setScreenState(MapScreenState.idle);
    }
  }

  Future<void> _onMapLongPress(LatLng latLng) async {
    setState(() {
      _updateSimpleMarker(
        id: "selectedLocation",
        location: latLng,
        title: "Seçilen Konum",
        hue: BitmapDescriptor.hueViolet,
        onTapAction: () => _showLocationActionBottomSheet(latLng, "selected"),
      );
    });
    SnackbarHelper.show(context, "Konum seçildi.", SnackBarType.info);
  }

  Future<void> _fetchPlacesNearby(LatLng location) async {
    if (_screenState == MapScreenState.loadingPlaces) return;
    _setScreenState(MapScreenState.loadingPlaces);

    try {
      final placeResponse = await _placesApiService.fetchPlaces(location);
      await _updatePlaceMarkers(placeResponse.places);
      SnackbarHelper.show(context, "${placeResponse.places.length} yer bulundu.", SnackBarType.success);
      final controller = await _controller.future;
      if (await controller.getZoomLevel() > 14.5) controller.animateCamera(CameraUpdate.zoomTo(14.5));
    } catch (e) {
      SnackbarHelper.show(context, "Yerler yüklenemedi: ${e.toString()}", SnackBarType.error);
    } finally {
      _setScreenState(MapScreenState.idle);
    }
  }

  Future<void> _updateSimpleMarker({
    required String id,
    required LatLng location,
    required String title,
    required double hue,
    VoidCallback? onTapAction,
  }) async {
    final markerId = MarkerId(id);
    _markers.removeWhere((m) => m.markerId == markerId);
    _markers.add(
      Marker(
        markerId: markerId,
        position: location,
        infoWindow: InfoWindow(title: title, snippet: "Enlem: ${location.latitude}, Boylam: ${location.longitude}"),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        onTap: onTapAction,
      ),
    );
  }

  Future<void> _updatePlaceMarkers(List<Place> places) async {
    _markers.removeWhere((m) => m.markerId.value != "currentLocation" && m.markerId.value != "selectedLocation");

    for (final place in places) {
      try {
        final bitmap = await MarkerGenerator.createCustomMarkerBitmapWithIcon(
          title: place.displayName.text,
          iconUrl: place.iconMaskBaseUri,
          hexColor: place.iconBackgroundColor,
        );
        _markers.add(
          Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.location.latitude, place.location.longitude),
            icon: bitmap,
            onTap: () => _showPlaceDetailsBottomSheet(place),
          ),
        );
      } catch (e) {
        _markers.add(
          Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.location.latitude, place.location.longitude),
            onTap: () => _showPlaceDetailsBottomSheet(place),
          ),
        );
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _animateToLocation(LatLng location) async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: location, zoom: 15.0)));
  }

  Future<void> _showLocationActionBottomSheet(LatLng location, String type) async {
    showModalBottomSheet(context: context, useSafeArea: true, builder: (ctx) => LocationActionBottomSheet(location: location, type: type, onFetchPlaces: _fetchPlacesNearby));
  }

  Future<void> _showPlaceDetailsBottomSheet(Place place) async {
    showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, builder: (ctx) => PlaceDetailsBottomSheet(place: place));
  }

  String get _loadingMessage {
    switch (_screenState) {
      case MapScreenState.loadingLocation:
        return "Konum Alınıyor...";
      case MapScreenState.loadingPlaces:
        return "Yerler Yükleniyor...";
      case MapScreenState.idle:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Harita")),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              style: (Theme.of(context).brightness == Brightness.dark) ? darkMap : lightMap,
              indoorViewEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (controller) => _controller.complete(controller),
              markers: _markers,
              onLongPress: _onMapLongPress,
            ),
            if (_screenState != MapScreenState.idle)
              Container(
                color: Theme.of(context).scaffoldBackgroundColor.withAlpha(200),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(_loadingMessage, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(label: const Icon(Icons.my_location), onPressed: _getCurrentLocation),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
