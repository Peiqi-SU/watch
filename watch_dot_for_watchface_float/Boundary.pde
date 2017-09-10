class Boundary {
  Vec2[] surface = new Vec2[360];
  Vec2[] box2dsurface = new Vec2[360];
  float x, y;
  float r;
  Body b;

  Boundary(float x_, float y_, float r_) {
    x = x_;
    y = y_;
    r = r_;

    // Build Body
    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    bd.type = BodyType.STATIC;
    b = box2d.createBody(bd);

    // shape
    for (int angle = 0; angle<360; angle++) {
      float vec2x = x + cos(radians(angle))*r;
      float vec2y = y + sin(radians(angle))*r;
      box2dsurface[angle] = new Vec2(vec2x, vec2y);
    }
    for (int i=0; i<box2dsurface.length; i++) {
      surface[i] = box2d.coordPixelsToWorld(box2dsurface[i]);
    }

    ChainShape cs = new ChainShape();
    cs.createLoop(surface, surface.length);

    // fixture
    b.createFixture(cs, 1);
    
    b.setUserData(this); 
  }
}