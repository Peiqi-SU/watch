class Dot {
  Body body;
  float r;
  float minR;
  float nextStepR;
  float preR, newR;
  int myIndex;
  int growSpeed = 3; // 0.1s
  int shrinkSpeed = 180; // 1s
  int attractForce = 20; // bigger number = stronger
  float _friction = 0;
  float _restitution = 0.5;
  boolean needResize;
  color _color;

  Dot(int myIndex_) {
    myIndex = myIndex_;
    nextStepR = bornR[myIndex-1];
    r = 1.0;
    minR = setminR[myIndex-1];
    _color = color(0);

    // Build body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    //bd.bullet = true;
    bd.position.set(box2d.coordPixelsToWorld(random(350, 650), random(250, 550)));
    body = box2d.createBody(bd);

    // Build shape
    CircleShape dot = new CircleShape();
    dot.m_radius = box2d.scalarPixelsToWorld(r);

    // fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = dot;
    fd.density = 1;
    fd.friction = _friction;
    fd.restitution = _restitution;
    body.createFixture(fd);
    
    body.setUserData(this);  
  }

  void calculateSize() {
    if ((abs(r-nextStepR)<1) || (abs(r-minR)<1)) {
      needResize = false;
    } else {
      needResize = true;
      // go bigger
      if (r < nextStepR) {
        r = r + ((nextStepR-r)/growSpeed);
        if (r>=nextStepR) {
          r=nextStepR;
        }
      }
      // go smaller
      if (r > nextStepR) {
        r = r - ((r-nextStepR)/shrinkSpeed);
        if (r<=nextStepR) {
          r=nextStepR;
        }
      }
      if (nextStepR<minR) {
        nextStepR=minR;
      }
    }
  }

  void bodyResize() {
    if (needResize) {
      // re-draw fixture
      body.destroyFixture(body.getFixtureList());
      CircleShape dot = new CircleShape();
      dot.m_radius= box2d.scalarPixelsToWorld(r);

      FixtureDef fd = new FixtureDef();
      fd.shape = dot;
      fd.density = 1;
      fd.friction = _friction;
      fd.restitution = _restitution;

      body.createFixture(fd);
    }
  }

  void attract () {
    // attract to center
    Vec2 center = new Vec2(0, 0);
    Vec2 boxpos = body.getWorldCenter();
    Vec2 distance = center.sub(boxpos);
    distance = distance.mul(attractForce);
    body.applyForce(distance, boxpos);
  }


  void display () {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    pushMatrix();
    translate(pos.x, pos.y);
    fill(_color);
    noStroke();
    ellipse(0, 0, r*2, r*2);
    popMatrix();
  }

  void killBody() {
    box2d.destroyBody(body);
  }
  
  void shrink() {
    //_color = color(0, 255, 0);
    nextStepR = nextStepR *0.9;
  }
}