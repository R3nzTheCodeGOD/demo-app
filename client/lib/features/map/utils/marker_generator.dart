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
  static Future<BitmapDescriptor> createCustomMarkerBitmapWithIcon({
    required String title,
    required String? iconUrl,
    required String? hexColor,
    double width = 125,
    double textSize = 12.5,
    double iconHeight = 12.5,
    double iconWidth = 12.5,
    double iconCircleDiameter = 25,
  }) async {
    // Google renkleri Alpha değeri olmadan gönderiyor.
    final Color markerColor = hexColor != null && hexColor.isNotEmpty ? Color(int.parse('FF${hexColor.replaceAll('#', '')}', radix: 16)) : Color(0xffff961f);
    const Color paint = Colors.black;

    Widget iconWidget = Icon(Icons.store, size: iconHeight, color: paint);
    if (iconUrl != null && iconUrl.isNotEmpty) {
      try {
        final String fullIconUrl = "$iconUrl.svg"; // .svg olarak indir.
        final response = await http.get(Uri.parse(fullIconUrl));
        if (response.statusCode == 200) {
          iconWidget = SvgPicture.string(response.body, height: iconHeight, width: iconWidth,
            // sadece içini boya
            colorFilter: ColorFilter.mode(paint, BlendMode.srcIn),
          );
        }
      } catch (e) {}
    }

    final markerWidget = RepaintBoundary(
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
                        ..strokeWidth = 2
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
          Container(
            height: iconCircleDiameter,
            width: iconCircleDiameter,
            decoration: BoxDecoration(border: Border.all(color: paint), color: markerColor, shape: BoxShape.circle),
            child: Center(child: iconWidget),
          ),
        ],
      ),
    );

    // Widget'ı Bitmape dönüştür.
    return _widgetToBitmap(markerWidget, width);
  }

  /// Widget'ı BitmapDescriptor'a dönüştürür.
  static Future<BitmapDescriptor> _widgetToBitmap(Widget widget, double logicalWidth) async {
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

    final ui.Image image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) throw Exception("Marker resmi oluşturulurken hata oluştu.");

    return BitmapDescriptor.bytes(byteData.buffer.asUint8List(), imagePixelRatio: pixelRatio);
  }
}
