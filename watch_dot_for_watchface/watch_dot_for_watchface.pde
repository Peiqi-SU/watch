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

int sketch_w = 0, sketch_h = 0; 
int outR = 0;

// every dot size
float[] bornR = {60, 60, 34, 26, 15, 10, 37, 21, 10, 8, 15, 31, 37, 10, 15, 31, 37, 7, 10, 21, 15, 31, 37, 10, 9, 31, 37, 21, 10, 15, 15, 11, 21, 10, 15, 31, 15, 21, 10, 12, 15, 31, 37, 10, 15, 31, 37, 21, 10, 13, 15, 31, 37, 10, 15, 31, 37, 11, 10, 10};
float[] setminR ={ 37, 26, 15, 10, 7, 4, 23, 17, 6, 4, 10, 19, 15, 10, 7, 4, 29, 5, 6, 10, 10, 22, 15, 8, 7, 4, 18, 17, 6, 10, 10, 8, 15, 10, 7, 4, 29, 17, 6, 7, 10, 26, 15, 10, 7, 4, 18, 17, 6, 9, 10, 23, 15, 10, 7, 4, 29, 9, 6, 10};
float dot_dist_sqr = 0, r_sqr = 0;

Box2DProcessing box2d;
ArrayList<Dot> dots;
Boundary boundary;

// test
int min = 0;
int countDotTouch = 0, countBoundaryTouch = 0;

boolean display_control_bar = true;


void setup() {
  //size(360, 360);
  fullScreen();
  //smooth(3);

  frameRate(30);
  background(255);
  sketch_w = 360;
  sketch_h = 360;
  outR = int(sketch_h*0.95/2);

  min = minute();

  // Initialize and create the Box2D world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, 0);
  dots = new ArrayList<Dot>();
  boundary = new Boundary(sketch_w/2, sketch_h/2, outR);

  for (int i = 0; i<min; i++) {
    Dot p = new Dot(i+1);
    dots.add(p);
  }
}

void draw () {
  if (!wearAmbient()) {
    background(255);
    box2d.step();


    // add dot
    if ((min != minute())) {
      min = minute();
      println(min);
      if (min ==0) {// reset every hour
        reset_all();
      } else {
        Dot p = new Dot(min);
        dots.add(p);
        //println(min);
        countDotTouch = 0;
      }
    }

    // display dot
    for (Dot b : dots) {
      b.calculateSize();
      b.bodyResize();
      b.attract();
      b.display();
    }
    check_full();
  }
}

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
        //println("++", countDotTouch);
      }
    }
  }
  if (min>22 && countDotTouch>(dots.size()*(dots.size()-1)/2*10+900)) { // *3 bigger number = harder shrink
    for (Dot b : dots) {
      //println("sssssss");
      b.shrink();
      countDotTouch = 0;
    }
  }
}

void reset_all() {
  for (Dot b : dots) {
    b.killBody();
  }
  dots.clear();
  //println(dots);
}