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
  static final Map<String, ui.Image> _baseIconImageCache = {};

  static Future<BitmapDescriptor> createCustomMarkerBitmapWithIcon({
    required String title,
    required String? iconUrl,
    required String? hexColor,
    double width = 120,
    double textSize = 11,
    double iconHeight = 10,
    double iconWidth = 10,
    double iconCircleDiameter = 20,
  }) async {
    // Google renkleri Alpha değeri olmadan gönderiyor.
    final Color markerColor = hexColor != null && hexColor.isNotEmpty ? Color(int.parse('FF${hexColor.replaceAll('#', '')}', radix: 16)) : const Color(0xffff961f);
    const Color paint = Colors.black;

    // Önbellek anahtarı sadece iconUrl ve hexColor'a bağlı
    final String cacheKey = "${iconUrl ?? ''}_${hexColor ?? ''}";
    ui.Image? baseIconImage = _baseIconImageCache[cacheKey];

    if (baseIconImage == null) {
      // Eğer önbellekte yoksa, temel ikonu oluştur ve önbelleğe al
      Widget iconWidget = Icon(Icons.store, size: iconHeight, color: paint);
      if (iconUrl != null && iconUrl.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse("$iconUrl.svg"));
          if (response.statusCode == 200) {
            iconWidget = SvgPicture.string(response.body, height: iconHeight, width: iconWidth,
              colorFilter: const ColorFilter.mode(paint, BlendMode.srcIn),
            );
          }
        } catch (e) {
          // Hata durumunda varsayılan ikonu kullanmaya devam et
        }
      }

      // Sadece ikonu içeren widget
      final baseIconContent = Container(
        height: iconCircleDiameter,
        width: iconCircleDiameter,
        decoration: BoxDecoration(border: Border.all(color: paint), color: markerColor, shape: BoxShape.circle),
        child: Center(child: iconWidget),
      );

      // Temel ikonu bir ui.Image'a dönüştür ve önbelleğe al
      baseIconImage = await _widgetToImage(baseIconContent, iconCircleDiameter); // Genişliği ikon çapı kadar ayarla
      _baseIconImageCache[cacheKey] = baseIconImage;
    }

    final finalMarkerWidget = RepaintBoundary(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  // Text dış hat (border)
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: textSize,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1
                        ..color = paint,
                    ),
                  ),
                  // Ön plan metni
                  Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: textSize, color: markerColor)),
                ],
              ),
              SizedBox(height: iconCircleDiameter),
            ],
          ),
          // Önbellekten alınan ikonu kullan
          RawImage(image: baseIconImage, width: iconCircleDiameter, height: iconCircleDiameter),
        ],
      ),
    );

    return _widgetToBitmap(finalMarkerWidget, width);
  }

  /// Widget'ı doğrudan ui.Image'a dönüştüren yardımcı metod
  static Future<ui.Image> _widgetToImage(Widget widget, double logicalWidth) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final pixelRatio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;

    final RenderView renderView = RenderView(
      view: ui.PlatformDispatcher.instance.views.first,
      child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(logicalConstraints: BoxConstraints(maxWidth: logicalWidth), devicePixelRatio: pixelRatio),
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

    return await repaintBoundary.toImage(pixelRatio: pixelRatio);
  }


  /// Widget'ı BitmapDescriptor'a dönüştürür.
  static Future<BitmapDescriptor> _widgetToBitmap(Widget widget, double logicalWidth) async {
    final ui.Image image = await _widgetToImage(widget, logicalWidth);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) throw Exception("Marker resmi oluşturulurken hata oluştu.");

    final pixelRatio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    return BitmapDescriptor.bytes(byteData.buffer.asUint8List(), imagePixelRatio: pixelRatio);
  }
}