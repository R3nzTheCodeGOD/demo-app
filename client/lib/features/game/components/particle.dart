import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Oyundaki her bir parçacığı temsil eder.
class MyParticle extends BodyComponent {
  final Vector2 initialPosition;
  final double radius;

  MyParticle({required this.initialPosition, required this.radius});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await game.loadSprite("haha.png"); // dosyanın olduğuna eminim try-catch'e gerek yok
    add(SpriteComponent(sprite: sprite, size: Vector2.all(radius * 2), anchor: Anchor.center));
  }

  @override
  Body createBody() {
    final shape = CircleShape(radius: radius);

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.4, // esneklik
      friction: 0.1, // sürtünme
    );

    final bodyDef = BodyDef(
      userData: this,
      position: initialPosition,
      type: BodyType.dynamic,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
