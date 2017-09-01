/**
 * for LG W270, width 360, height 360, (0,0) 
 * touch screen to switch line thickness
 */
int sketch_w = 0, sketch_h = 0; 
float thickness_begin = 1;
float thickness_end = 5;
int d = 0;
float dist = 0;
int my_minute = 0;
int x0 = 0, x1 = 0;
float y0 = 0, y1 = 0;
boolean thickness_vary = false;



void setup() {
  fullScreen();
  frameRate(1);
  background(0);
  sketch_w = width;
  sketch_h = height;
  d = sketch_h;
  dist = d/61.0;
}

void draw() {
  //translate(0, +wearInsets().bottom/2);
  if (!wearAmbient()) {
    my_draw_bg();
    my_draw_clock_lines();
  }
}

void my_draw_bg() {
  //println(hour());
  if (hour() >=6 && hour() <= 18) {
    background(255);
  } else {
    background(0);
  } 
  hint(DISABLE_STROKE_PURE); // smooth line
}

void my_draw_clock_lines() {
  
  if (hour() >=6 && hour() <=18) {
    stroke(0);
  } else {
    stroke(255);
  } 
  hint(ENABLE_STROKE_PURE); // smooth line
  my_minute = minute();
  if (my_minute == 0) {
    my_minute = 24;
  }
  //println("-----", my_minute);
  for (int i = 0; i < my_minute; i++) {
    if (thickness_vary) {
      float thickness = (thickness_end-thickness_begin)/60.0*i;
      strokeWeight(thickness);
    } else {
      strokeWeight(thickness_begin);
    }

    int x0 = 0;
    //float y0 = (sketch_h + d)/2-dist*(i+1)-(thickness_begin%2)*0.5;
    float y0 = sketch_h-dist*(i+1);
    int x1 = sketch_w;
    float y1 = y0;
    line(x0, y0, x1, y1);
  }
}

void mousePressed() {
  thickness_vary = !thickness_vary;
}