/**
 * ? line looks not sharp
 */
final int sketch_w = 1000; 
final int sketch_h = 800;
float thickness = 3;
float thickness_alt = 2;
int d = int(sketch_h*0.8/61)*61;
int dist = d/61;
int min = 0, delta_min = 0, base_min = 0; // min = base_min + delta_min
int hour = 0, delta_hour = 0, base_hour = 0; // hour = base_hour + delta_hour
int k = 200; // fast forward speed 


PShape control_bar;
int btn_pressed = 5;

boolean display_control_bar = true;


void setup() {
  size(1000, 800);
  frameRate(30);
  background(0);

  // create control bar
  control_bar = loadShape("control_bar.svg");
}

void draw() {
  // get display time
  hour =  (((millis()%86400000)*k)/3600000)%24; // 0-23
  min = (((millis()%3600000)*k)/60000)%60; //0-59

  // draw bg and watch face
  my_draw_bg(hour);

  my_draw_control_bar(display_control_bar, btn_pressed);

  my_draw_clock_lines(hour);
}

void my_draw_bg(int hour) {
  if (hour >=6 && hour <= 18) {
    background(0);
    fill(255);
  } else {
    background(255);
    fill(0);
  } 
  hint(DISABLE_STROKE_PURE);
  ellipseMode(CENTER);
  ellipse(sketch_w/2, sketch_h/2, d, d);
}

void my_draw_clock_lines(int hour) {
  if (hour >=6 && hour <=18) {
    stroke(0);
  } else {
    stroke(255);
  } 
  strokeWeight(thickness);
  strokeCap(SQUARE);
  hint(ENABLE_STROKE_PURE);
  for (int i = 0; i < min; i++) {
    int x0 = 0;
    float y0 = (sketch_h + d)/2-dist*(i+1)-(thickness%2)*0.5;
    int x1 = sketch_w;
    float y1 = y0;
    //println(x0, y0, x1, y1);

    line(x0, y0, x1, y1);
  }
}

void my_draw_control_bar (boolean display_control_bar, int index) {
  // whether display control bar
  if (display_control_bar) {
    shape(control_bar, (sketch_w/2-180), (sketch_h-60));
    fill(127);
    textSize(28);
    text("time is " + hour + ":" + min, (sketch_w/2+200), (sketch_h-20));
    textSize(14);
    text("Press h to hide or show this control panel", 5, (sketch_h-20));
    stroke(127);
    line(0, sketch_h-60, sketch_w, sketch_h-60);
  }

  // click
  fill(255, 100); 
  switch (index) {
  case 1:
    rect((sketch_w/2-180), (sketch_h-60), 60, 60);
    hour--;
    break;

  case 3:
    rect((sketch_w/2-60), (sketch_h-60), 60, 60);
    k = 1;
    break;

  case 4:
    rect(sketch_w/2, (sketch_h-60), 60, 60);
    break;

  case 5:
    rect((sketch_w/2+60), (sketch_h-60), 60, 60);
    k = 200;
    break;

  case 6:
    rect((sketch_w/2+120), (sketch_h-60), 60, 60);
    hour++;
    break;
  }
}

// hide keyboard
void keyPressed() {
  if (key == 'h' || key == 'H') {
    display_control_bar = !display_control_bar;
  }
}

// control bar interaction
void mouseClicked() {
  if (mouseY > (sketch_h-60)) {
    btn_pressed = 0;
    // last hour
    if (mouseX > (sketch_w/2-180) && mouseX < (sketch_w/2-120)) {
      btn_pressed = 1;
      k = 200;
    }

    // play
    if (mouseX > (sketch_w/2-60) && mouseX < sketch_w/2) {
      btn_pressed = 3;
      k = 1;
    }

    // pause
    if (mouseX > sketch_w/2 && mouseX < (sketch_w/2+60)) {
      btn_pressed = 4;
    }

    // fast forward
    if (mouseX > (sketch_w/2+60) && mouseX < (sketch_w/2+120)) {
      btn_pressed = 5;
    }

    // next hour
    if (mouseX > (sketch_w/2+120) && mouseX < (sketch_w/2+180)) {
      btn_pressed = 6;
    }
  }
}