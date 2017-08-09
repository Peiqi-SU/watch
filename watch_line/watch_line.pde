/**
 * ? line looks not sharp
 */
final int sketch_w = 1000; 
final int sketch_h = 800;
float thickness_begin = 1;
float thickness_end = 4;
int d = int(sketch_h*0.8/61)*61;
int dist = d/61;

// time
float previous_millis = 0;
float delta_sec = 0, controled_delta_sec = 0;
float sec = 0;
int display_sec = 0, min = 0, hour = 0;
int speed = 200; // fast forward speed 
int k = 0, i = 0; 


PShape control_bar;
PFont my_font;
int btn_pressed = 5;
int flag_btn_display = 5; // display for x frame

boolean display_control_bar = true;


void setup() {
  size(1000, 800);
  frameRate(30);
  background(0);

  // create control bar
  control_bar = loadShape("control_bar.svg");
  my_font = loadFont("Roboto-Regular-32.vlw");
}

void draw() {
  // get input, key press, mouse click, num input

  // get display time
  delta_sec = (millis() - previous_millis)/1000;
  previous_millis = millis();
  controled_delta_sec = delta_sec*k + i;
  i = 0;
  sec += controled_delta_sec;
  println(k + " --- "+delta_sec + "  |  delta: " + controled_delta_sec + "   | sec: " + sec);

  display_sec = int(sec%60); // 0-59
  if (display_sec <0) {
    display_sec = 60+display_sec;
  }

  min = int((sec/60)%60); // 0-59
  if (min < 0) {
    min = 60+min;
  }
  hour = int((sec/3600)%24); // 0-23
  if (hour <0) {
    hour = 24+hour;
  }

  //hour =  (((millis()%86400000)*k)/3600000)%24; // 0-23
  //min = (((millis()%3600000)*k)/60000)%60; //0-59

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
  strokeWeight(thickness_begin);
  strokeCap(SQUARE);
  hint(ENABLE_STROKE_PURE);
  for (int i = 0; i < min; i++) {
    int x0 = 0;
    float y0 = (sketch_h + d)/2-dist*(i+1)-(thickness_begin%2)*0.5;
    int x1 = sketch_w;
    float y1 = y0;
    //println(x0, y0, x1, y1);

    line(x0, y0, x1, y1);
  }
}

void my_draw_control_bar (boolean display_control_bar, int index) {
  // whether display control bar
  if (display_control_bar) {
    shape(control_bar, (sketch_w/2-180), (sketch_h-80));
    fill(127);
    textFont(my_font, 28);
    text("time is " + hour + ":" + min + ":" + display_sec, (sketch_w/2+200), (sketch_h-40));
    textFont(my_font, 14);
    text("Press \"h\" to hide or show this control panel", 5, (sketch_h-60));
    textFont(my_font, 11);
    text("hour-1    | fast backward |    normal    |    pause    | fast forward |    hour+1", (sketch_w/2-180), (sketch_h-6));
    stroke(127);
    line(0, sketch_h-80, sketch_w, sketch_h-80);
  }

  // click
  fill(255, 100); 
  switch (index) {
    // last hour
  case 1:
    if (flag_btn_display>0) {
      rect((sketch_w/2-180), (sketch_h-80), 60, 60);
      flag_btn_display --;
    }
    break;

    // backward
  case 2:
    rect((sketch_w/2-120), (sketch_h-80), 60, 60);
    k = -speed;
    break;

    // play
  case 3:
    rect((sketch_w/2-60), (sketch_h-80), 60, 60);
    k = 1;
    break;

    // pause
  case 4:
    rect(sketch_w/2, (sketch_h-80), 60, 60);
    k = 0;
    break;

    // forward
  case 5:
    rect((sketch_w/2+60), (sketch_h-80), 60, 60);
    k = speed;
    break;

    // next hour
  case 6:
    if (flag_btn_display>0) {
      rect((sketch_w/2+120), (sketch_h-80), 60, 60);
      flag_btn_display --;
    }
    break;
  }
}

// control bar interaction
void mouseClicked() {
  if (mouseY > (sketch_h-80)) {
    btn_pressed = 0;
    // last hour
    if (mouseX > (sketch_w/2-180) && mouseX < (sketch_w/2-120)) {
      btn_pressed = 1;
      flag_btn_display = 30;
      i = - 3600;
    }

    // backward
    if (mouseX > (sketch_w/2-120) && mouseX < (sketch_w/2-60)) {
      btn_pressed = 2;
    }

    // play
    if (mouseX > (sketch_w/2-60) && mouseX < sketch_w/2) {
      btn_pressed = 3;
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
      flag_btn_display = 30;
      i = 3600;
    }
  }
}

// hide keyboard
void keyPressed() {
  if (key == 'h' || key == 'H') {
    display_control_bar = !display_control_bar;
  }
}