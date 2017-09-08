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
float[] bornR = {74, 42, 34, 26, 15, 10, 37, 21, 10, 21, 15, 31, 37, 10, 15, 31, 37, 21, 10, 21, 15, 31, 37, 10, 15, 31, 37, 21, 10, 15, 15, 26, 21, 10, 15, 31, 15, 21, 10, 21, 15, 31, 37, 10, 15, 31, 37, 21, 10, 21, 15, 31, 37, 10, 15, 31, 37, 21, 10, 10};
float[] setminR ={37, 26, 15, 10, 7, 4, 23, 17, 6, 10, 10, 19, 15, 10, 7, 4, 29, 17, 6, 10, 10, 22, 15, 10, 7, 4, 18, 17, 6, 10, 10, 21, 15, 10, 7, 4, 29, 17, 6, 10, 10, 26, 15, 10, 7, 4, 18, 17, 6, 10, 10, 23, 15, 10, 7, 4, 29, 17, 6, 10};
float dot_dist_sqr = 0, r_sqr = 0;

Box2DProcessing box2d;
ArrayList<Dot> dots;
Boundary boundary;

// test
int min = 0;
int countDotTouch = 0, countBoundaryTouch = 0;

boolean display_control_bar = true;
boolean btn_add = false;


void setup() {
  //size(1000, 800);
  fullScreen();
  smooth(3);
  frameRate(30);
  background(255);
  sketch_w = width;
  sketch_h = height;
  outR = int(sketch_h*0.95/2);

  min = minute()+1;

  // Initialize and create the Box2D world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  //box2d.listenForCollisions();
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
    if ((min != minute()+1) || btn_add) {
      min = minute()+1;
      Dot p = new Dot(min);
      dots.add(p);
      //println(min);
      btn_add = false;
      countDotTouch = 0;
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
        //println("sssssss");
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
        bornR[i] =  bornR[i] * random(0.9, 1.1);
      }
    }
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
}

void mouseClicked() {
  btn_add = true;
}