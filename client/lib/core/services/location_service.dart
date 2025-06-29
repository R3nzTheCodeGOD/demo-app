import 'package:geolocator/geolocator.dart';

/// Cihaz konum servislerini yöneten sınıf.
class LocationService {
  /// Cihazın mevcut konumunu, izinleri kontrol ederek alır.
  Future<Position> determinePosition() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Konum servisleri devre dışı.");
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Konum izinleri reddedildi.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Konum izinleri kalıcı olarak reddedildi. Lütfen uygulama ayarlarından izin verin.");
    }

    return await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best));
  }
}
