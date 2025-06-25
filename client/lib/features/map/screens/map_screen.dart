import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:client/core/services/location_service.dart';
import 'package:client/core/utils/snackbar_helper.dart';

// Ekranın durumlarını yönetmek için bir enum.
enum MapScreenState { idle, loadingLocation, loadingPlaces }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};

  // Servisleri dışarıdan alıyoruz.
  final LocationService _locationService = LocationService();

  MapScreenState _screenState = MapScreenState.idle;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(41.0054, 28.8473), // İstanbul
    zoom: 9.0,
  );

  @override
  void initState() {
    super.initState();
    // Harita oluşturulduğunda ilk konumu al.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  void _setScreenState(MapScreenState state) {
    if (mounted) {
      setState(() {
        _screenState = state;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_screenState == MapScreenState.loadingLocation) return;
    _setScreenState(MapScreenState.loadingLocation);

    try {
      final position = await _locationService.determinePosition();
      final currentLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _updateMarker(
          id: 'currentLocation',
          location: currentLocation,
          title: 'Konumunuz',
          hue: BitmapDescriptor.hueAzure,
          type: 'current',
        );
      });

      _animateToLocation(currentLocation);
      SnackbarHelper.show(
        // ignore: use_build_context_synchronously
        context,
        'Konumunuza yakınlaşıldı.',
        SnackBarType.success,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      SnackbarHelper.show(context, 'Konum alınamadı: $e', SnackBarType.error);
    } finally {
      _setScreenState(MapScreenState.idle);
    }
  }

  void _onMapLongPress(LatLng latLng) {
    setState(() {
      _updateMarker(
        id: 'selectedLocation',
        location: latLng,
        title: 'Seçilen Konum',
        hue: BitmapDescriptor.hueOrange,
        type: 'selected',
      );
    });
    SnackbarHelper.show(context, 'Konum seçildi.', SnackBarType.info);
  }

  void _updateMarker({
    required String id,
    required LatLng location,
    required String title,
    required double hue,
    required String type,
  }) {
    _markers.removeWhere((marker) => marker.markerId.value == id);
    _markers.add(
      Marker(
        markerId: MarkerId(id),
        position: location,
        infoWindow: InfoWindow(
          title: title,
          snippet:
              'Enlem: ${location.latitude.toStringAsFixed(4)}, Boylam: ${location.longitude.toStringAsFixed(4)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      ),
    );
  }

  Future<void> _animateToLocation(LatLng location) async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 17.0),
      ),
    );
  }

  String get _loadingMessage {
    switch (_screenState) {
      case MapScreenState.loadingLocation:
        return 'Konum Alınıyor...';
      case MapScreenState.loadingPlaces:
        return 'İşletmeler Yükleniyor...';
      case MapScreenState.idle:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NarPOS Haritalar')),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (controller) => _controller.complete(controller),
              markers: _markers,
              onLongPress: _onMapLongPress,
            ),
            if (_screenState != MapScreenState.idle)
              Container(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _loadingMessage,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getCurrentLocation,
        label: const Text('Konumumu Bul'),
        icon: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
