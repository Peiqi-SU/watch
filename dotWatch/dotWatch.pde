/**
 * need to install Box2D
 */
import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.dynamics.*;

final int sketch_w = 1000; 
final int sketch_h = 800;
int outR = int(sketch_h*0.76/2);

Box2DProcessing box2d;
ArrayList<Box> boxes;
Boundary boundary;


// test
int min = 1;
int flag = 360;
int speed = 3600/flag;


void setup() {
  size(1000, 800);

  // Initialize and create the Box2D world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, 0);
  boxes = new ArrayList<Box>();
  boundary = new Boundary(sketch_w/2, sketch_h/2, outR);
}

void draw () {
  background(0);
  for (int i=0; i<speed; i++) {
    box2d.step();
  }

  // draw watchface
  fill(255);
  noStroke();
  ellipse(sketch_w/2, sketch_h/2, outR*2, outR*2);


  // test

  if (flag ==360) {
    // add dot
    Box p = new Box(min);
    boxes.add(p);
    //println(min);
    
    min ++;
    // calculate other dot size
    for (Box b : boxes) {
      b.calculateSize();
    }
  }
  flag --;
  if (flag ==0) {
    flag = 360;
  }

  // display dot
  for (Box b : boxes) {
    b.bodyResize(b.body);
    b.attract();
    b.display();
    //println(b.previousR);
  }

  if (min == 61) {
    min = 1;
    boxes.clear();
    for (Box b : boxes) {
      b.killBody();
    }
  }
}