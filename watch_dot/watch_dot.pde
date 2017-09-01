/**
 * need to install Box2D: http://box2d.org/manual.pdf
 */
import shiffman.box2d.*;  //http://natureofcode.com/book/chapter-5-physics-libraries/
import org.jbox2d.common.*; //http://trentcoder.github.io/JBox2D_JavaDoc/apidocs/
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;



final int sketch_w = 1000; 
final int sketch_h = 800;
int outR = int(sketch_h*0.76/2);

// every dot size
float[] bornR = {140, 80, 66, 50, 30, 20, 70, 40, 20, 40, 30, 60, 70, 20, 30, 60, 70, 40, 20, 40, 30, 60, 70, 20, 30, 60, 70, 40, 20, 40, 30, 60, 70, 20, 30, 60, 70, 40, 20, 40, 30, 60, 70, 20, 30, 60, 70, 40, 20, 40, 30, 60, 70, 20, 30, 60, 70, 40, 20, 20, };
float[] setminR ={80, 50, 30, 20, 14, 8, 55, 33, 13, 20, 20, 36, 30, 20, 14, 8, 55, 33, 13, 20, 20, 42, 30, 20, 14, 8, 55, 33, 13, 20, 20, 40, 30, 20, 14, 8, 55, 33, 13, 20, 20, 50, 30, 20, 14, 8, 55, 33, 13, 20, 20, 45, 30, 20, 14, 8, 55, 33, 13, 20, };
float dot_dist_sqr = 0, r_sqr = 0;

Box2DProcessing box2d;
ArrayList<Dot> dots;
Boundary boundary;


// test
int min = 1;
int flag = 180, _flag = 180;  // bigger, slower
int speed = 3600/flag;

int countDotTouch = 0, countBoundaryTouch = 0;


void setup() {
  size(1000, 800);
  frameRate(30);

  // Initialize and create the Box2D world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.listenForCollisions();
  box2d.setGravity(0, 0);
  dots = new ArrayList<Dot>();
  boundary = new Boundary(sketch_w/2, sketch_h/2, outR);
}

void draw () {
  background(0);
  //for (int i=0; i<speed; i++) {
  //  box2d.step();
  //}
  box2d.step();

  // draw watchface
  fill(255);
  noStroke();
  ellipse(sketch_w/2, sketch_h/2, outR*2, outR*2);


  // test

  if (flag ==_flag) {
    // add dot
    Dot p = new Dot(min);
    dots.add(p);
    //println(min);

    min ++;
    //countDotTouch=0;
    //countBoundaryTouch = 0;
  }
  countDotTouch=0;
  countBoundaryTouch = 0;



  flag --;
  if (flag ==0) {
    flag = _flag;
  }

  // display dot
  for (Dot b : dots) {
    b.calculateSize();
    b.bodyResize();
    b.attract();
    b.display();
  }

  if (min == 61) {
    min = 1;
    dots.clear();
    for (Dot b : dots) {
      b.killBody();
    }
    for (int i = 0; i<bornR.length; i++) {
      bornR[i] =  bornR[i] * random(0.8, 1.2);
    }
  }
}

// Collision begins
void beginContact(Contact cp) {
  //println("beginContact");
}

// Objects stop touching each other
void endContact(Contact cp) {
  //println("------------endContact");

  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();

  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();


  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if ((o1.getClass() == Boundary.class || o2.getClass() == Boundary.class)) {
    countBoundaryTouch ++;
    println("---", countBoundaryTouch);
  }

  if (o1.getClass() == Dot.class && o2.getClass() == Dot.class) {
    Dot d1 = (Dot) o1;
    Dot d2 = (Dot) o2;
    //Vec2 d1pos = d1.body.getWorldCenter();
    //Vec2 d2pos = d2.body.getWorldCenter();
    Vec2 d1pos = box2d.getBodyPixelCoord(d1.body);
    Vec2 d2pos = box2d.getBodyPixelCoord(d2.body);
    dot_dist_sqr = (d1pos.x - d2pos.x)*(d1pos.x - d2pos.x) + (d1pos.y - d2pos.y)*(d1pos.y - d2pos.y);
    r_sqr = (d1.r + d2.r)*(d1.r + d2.r);
    //println(d1pos, " ---- ", d2pos, "     |     ", dot_dist_sqr, r_sqr);

    if ((r_sqr - dot_dist_sqr) >100) {
      countDotTouch ++;
    }
    println(countDotTouch);

    if ((countDotTouch > 10) || (countBoundaryTouch >10)) {
      println("shrinkkkkkk");
      d1.shrink();
      // d2.shrink();
    }
  }
}