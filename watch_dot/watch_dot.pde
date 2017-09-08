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
int outR = int(sketch_h*0.85/2);

// every dot size
float[] bornR = {140, 80, 66, 50, 30, 20, 70, 40, 20, 40, 30, 60, 70, 20, 30, 60, 70, 40, 20, 40, 30, 60, 70, 20, 30, 60, 70, 40, 20, 30, 30, 50, 40, 20, 30, 60, 30, 40, 20, 40, 30, 60, 70, 20, 30, 60, 70, 40, 20, 40, 30, 60, 70, 20, 30, 60, 70, 40, 20, 20, };
float[] setminR ={70, 50, 30, 20, 14, 8, 45, 33, 13, 20, 20, 36, 30, 20, 14, 8, 55, 33, 13, 20, 20, 42, 30, 20, 14, 8, 35, 33, 13, 20, 20, 40, 30, 20, 14, 8, 55, 33, 13, 20, 20, 50, 30, 20, 14, 8, 35, 33, 13, 20, 20, 45, 30, 20, 14, 8, 55, 33, 13, 20, };
float dot_dist_sqr = 0, r_sqr = 0;

Box2DProcessing box2d;
ArrayList<Dot> dots;
Boundary boundary;

// test
int min = 1;
int speed = 60*30, _speed = 60*30; // 30 framerate
int countDotTouch = 0, countBoundaryTouch = 0;

boolean display_control_bar = true;
boolean btn_add = false;
PFont my_font;


void setup() {
  size(1000, 800);
  frameRate(30);
  my_font = loadFont("Roboto-Regular-32.vlw");

  // Initialize and create the Box2D world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  //box2d.listenForCollisions();
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

  // add dot
  if (btn_add || speed == _speed) {
    Dot p = new Dot(min);
    dots.add(p);
    //println(min);
    min ++;
    btn_add = false;
    countDotTouch = 0;
  }
  //countDotTouch=0;
  //countBoundaryTouch = 0;



  speed --;
  if (speed < 0) {
    speed = _speed;
  }

  // display dot
  for (Dot b : dots) {
    b.calculateSize();
    b.bodyResize();
    b.attract();
    b.display();
  }

  check_full();

  if (min>22 && countDotTouch>(dots.size()*(dots.size()-1)/2*10+900)) { // *3 bigger number = harder shrink
    for (Dot b : dots) {
      println("sssssss");
      b.shrink();
      countDotTouch = 0;
    }
  }

  // reset every hour
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

  if (display_control_bar) {
    fill(0);
    stroke(255);
    strokeWeight(2);
    rectMode(CORNERS);
    rect((sketch_w/2-100), (sketch_h-60), (sketch_w/2+100), (sketch_h-5));
    fill(255);
    textFont(my_font, 24);
    text("click to add a dot", sketch_w/2-90, sketch_h-20);
    text("press 'h' to hide/show the button", sketch_w/2+130, sketch_h-20);
  }
}

// Collision begins
//void beginContact(Contact cp) {
//  //println("beginContact");
//}
void check_full() {
  for (int i=0; i<dots.size(); i++) {
    for (int j=0; j<i; j++) {
      Dot di = dots.get(i);
      Dot dj = dots.get(j);
      Vec2 pos_di = box2d.getBodyPixelCoord(di.body);
      Vec2 pos_dj = box2d.getBodyPixelCoord(dj.body);
      float ri = di.r, rj = dj.r, rij = (ri+rj)*(ri+rj);
      float dist_ij = (pos_di.x-pos_dj.x)*(pos_di.x-pos_dj.x) + (pos_di.y-pos_dj.y)*(pos_di.y-pos_dj.y);
      if ((rij - dist_ij)>30) {
        countDotTouch ++;
        println("++",countDotTouch);
      }
    }
  }
  
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

// hide keyboard
void keyPressed() {
  if (key == 'h' || key == 'H') {
    display_control_bar = !display_control_bar;
  }
  if (key == 'a' || key == 'A') {
    btn_add = true;
  }
}

void mouseClicked() {
  if (mouseX>(sketch_w/2-100) && mouseX<(sketch_w/2+100) && mouseY>(sketch_h-60)) {
    // add a dot
    btn_add = true;
  }
}