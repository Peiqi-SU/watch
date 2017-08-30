class Box {
  Body body;
  float r;
  float minR;
  float nextStepR;
  float preR, newR;
  int myIndex;


  Box(int myIndex_) {

    myIndex = myIndex_;
    r = 140/myIndex +40;
    
    minR = random(10,50);

    // Build body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(random(450, 550), random(350, 450)));
    body = box2d.createBody(bd);

    // Build shape
    CircleShape dot = new CircleShape();
    dot.m_radius = box2d.scalarPixelsToWorld(r);

    // fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = dot;
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    body.createFixture(fd);
  }

  void calculateSize() {
    nextStepR = r * 0.8;
    if (nextStepR<minR) {
      nextStepR=minR;
    }
  }

  void bodyResize(Body body) {
    body.destroyFixture(body.getFixtureList());
    CircleShape dot = new CircleShape();
    r -= (r-nextStepR)/60.0;
    if (r<nextStepR){
      r=nextStepR;
    }
    dot.m_radius= box2d.scalarPixelsToWorld(r);

    FixtureDef fd = new FixtureDef();
    fd.shape = dot;
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    body.createFixture(fd);
  }

  void attract () {
    // attract to center
    Vec2 center = new Vec2(0, 0);
    Vec2 boxpos = body.getWorldCenter();
    Vec2 distance = center.sub(boxpos);
    distance = distance.mul(5);
    body.applyForce(distance, boxpos);
  }



  void display () {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    //float a = body.getAngle();

    pushMatrix();
    translate(pos.x, pos.y);
    //rotate(-a);
    fill(0);
    noStroke();
    ellipse(0, 0, r*2, r*2);
    popMatrix();
  }

  void killBody() {
    box2d.destroyBody(body);
  }
}