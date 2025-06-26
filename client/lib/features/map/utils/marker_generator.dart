import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Flutter widget'larını Google Haritalar için özel marker'lara dönüştüren yardımcı sınıf.
class MarkerGenerator {
  /// Verilen bilgilere göre özel bir marker widget'ı oluşturur ve bunu
  /// bir BitmapDescriptor'a dönüştürür.
  static Future<BitmapDescriptor> createCustomMarkerBitmapWithIcon({
    required String title,
    required String? iconUrl,
    required String? hexColor,
    // Marker'ın toplam genişliğini belirler
    double width = 50,
    // Marker metin boyutu
    double textSize = 4,
    // İkonun yüksekliği
    double iconHeight = 5,
    // İkonun genişliği
    double iconWidth = 5,
    // İkon arka plan dairesinin çapı
    double iconCircleDiameter = 10,
    // İkon arka plan dairesinin işletme adına olan dikey ofseti
    double iconBottomOffset = 0,
  }) async {
    // API'den gelen hex rengini Flutter'ın anladığı Color'a çeviriyoruz.
    final Color markerColor = hexColor != null && hexColor.isNotEmpty
        ? Color(int.parse('FF${hexColor.replaceAll('#', '')}', radix: 16))
        : Colors.red; // Varsayılan renk

    // İkonu oluşturacak olan widget.
    Widget iconWidget;
    if (iconUrl != null && iconUrl.isNotEmpty) {
      try {
        // SVG ikonunu indirip renklendiriyoruz.
        final String fullIconUrl = '$iconUrl.svg'; // .svg uzantısını ekliyoruz
        final response = await http.get(Uri.parse(fullIconUrl));
        if (response.statusCode == 200) {
          iconWidget = SvgPicture.string(
            response.body,
            height: iconHeight,
            width: iconWidth,
            // İkon maskesini beyaz renkle dolduruyoruz.
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          );
        } else {
          // İndirme başarısız olursa varsayılan bir ikon göster.
          iconWidget = Icon(
            Icons.store,
            size: iconHeight,
            color: Colors.white,
          );
        }
      } catch (e) {
        iconWidget = Icon(
          Icons.business,
          size: iconHeight,
          color: Colors.white,
        );
      }
    } else {
      // URL yoksa varsayılan ikon.
      iconWidget = Icon(Icons.business, size: iconHeight, color: Colors.white);
    }

    // Komple marker'ı oluşturan widget ağacı.
    final markerWidget = RepaintBoundary(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // İşletme adı
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color: Color(0xff212121).withAlpha(200),
                  borderRadius: BorderRadius.circular(16),
                  // boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))],
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: iconCircleDiameter + iconBottomOffset),
            ],
          ),
          // İkon ve renkli arka planı
          Positioned(
            bottom: iconBottomOffset, // İkonu metnin üzerine konumlandır
            child: Container(
              height: iconCircleDiameter,
              width: iconCircleDiameter,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                // boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: Center(child: iconWidget),
            ),
          ),
        ],
      ),
    );

    // Widget'ı Bitmap'e dönüştürmek için daha güvenilir bir yöntem.
    return _widgetToBitmap(markerWidget, logicalWidth: width);
  }

  /// widget'ı BitmapDescriptor'a dönüştürür.
  static Future<BitmapDescriptor> _widgetToBitmap(
    Widget widget, {
    double logicalWidth = 300,
  }) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    final RenderView renderView = RenderView(
      view: ui.PlatformDispatcher.instance.views.first,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints(maxWidth: logicalWidth),
        devicePixelRatio:
            ui.PlatformDispatcher.instance.views.first.devicePixelRatio,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement rootElement = RenderObjectToWidgetAdapter(
      container: repaintBoundary,
      child: Directionality(textDirection: TextDirection.ltr, child: widget),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(
      pixelRatio: ui.PlatformDispatcher.instance.views.first.devicePixelRatio,
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('Marker resmi oluşturulurken hata oluştu.');
    }

    return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
  }
}
