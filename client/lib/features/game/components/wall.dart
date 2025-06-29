import 'package:flame_forge2d/flame_forge2d.dart';

/// Oyun dünyasının sınırlarını oluşturan statik bir cisim.
class Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  Wall(this.start, this.end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.3, // Duvar sürtünmesi
      restitution: 0.1, // Duvar esnekliği
    );

    final bodyDef = BodyDef(
      userData: this,
      position: Vector2.zero(),
      type: BodyType.static,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  static List<Wall> createBoundaries(Vector2 size) {
    final topLeft = Vector2.zero();
    final topRight = Vector2(size.x, 0);
    final bottomRight = Vector2(size.x, size.y);
    final bottomLeft = Vector2(0, size.y);

    return [
      Wall(topLeft, topRight), // Üst
      Wall(topRight, bottomRight), // Sağ
      Wall(bottomRight, bottomLeft), // Alt
      Wall(bottomLeft, topLeft), // Sol
    ];
  }
}
