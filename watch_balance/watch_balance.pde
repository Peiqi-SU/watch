/**
 * line looks not sharp: hint(ENABLE_STROKE_PURE);
 * 122min = a round clock 360dgr, 12:12 to 1:01 is a exception.
 */
final int sketch_w = 1000; 
final int sketch_h = 800;

// line
int x0 = sketch_w/2, y0 = sketch_h/2;
float x1 = 0, y1 = 0, x2 = 0, y2 = 0, x3 = 0, y3 = 0, x4 = 0, y4 = 0;
int r = int(sketch_h*0.76/2);
int line_thickness = 1;

// time
float previous_millis = 0;
float delta_sec = 0, controled_delta_sec = 0;
float sec = 3660.0;
int display_sec = 0, min = 0, hour = 0;
int speed = 200; // fast forward speed 
int k = 0, i = 0; 
float angle_per_sec = 0;

// control bar
PShape control_bar;
PFont my_font;
int btn_pressed = 5;
int flag_btn_display = 5; // display for x frame
boolean display_control_bar = true;
boolean thickness_vary = false;


void setup() {
  size(1000, 800);
  frameRate(60);
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
  // sec should not be <0, or >= 12h (43200)
  if(sec >=43200) {
    sec -= 43200;
  }
  if(sec <0) {
    sec += 43200;
  }
  
 
  //println(k + " --- "+delta_sec + "  |  delta: " + controled_delta_sec + "   | sec: " + sec);

  display_sec = int(sec%60); // 0-59
  if (display_sec <0) {
    display_sec = 60+display_sec;
  }

  min = int((sec/60)%60); // 0-59
  if (min < 0) {
    min = 60+min;
  }
  hour = (int)floor((sec/3600)%12); // 0-11

  if (hour <0) {
    hour = 12+hour;
  }

  // draw bg and watch face
  my_draw_bg();

  my_draw_control_bar(display_control_bar, btn_pressed);

  my_draw_clock_lines(hour, min, sec);
}

void my_draw_bg() {
  background(0);
  fill(255);

  hint(DISABLE_STROKE_PURE);
  ellipseMode(CENTER);
  ellipse(sketch_w/2, sketch_h/2, r*2, r*2);
}

void my_draw_clock_lines(int hour, int min, float sec) {
  stroke(0);
  strokeWeight(line_thickness);
  strokeCap(SQUARE);
  hint(ENABLE_STROKE_PURE);

  // if time btw 0:12 to 1:01
  float to_radians;
  
  float modded_second = sec%43200;
  if (modded_second<0) modded_second+=43200;
  
  println(sec,modded_second);
  if ((modded_second)>720 && (modded_second)<3660 ) {
    float mapped_angle = map(modded_second,720,3660,0,180);
    to_radians = radians(360-mapped_angle);
  } else {
    angle_per_sec = 360.0/7320.0; // 7320s(122m) a round
    if (modded_second<=720) modded_second+=43200;
    to_radians = radians(360-(angle_per_sec*modded_second)%360);
  }
  
  //println(sec + " * " + angle_per_sec + " = " +angle_per_sec*sec + " -- " + to_radians);
  x1 = x0 + cos(to_radians)*r*0.73;
  y1 = y0 - sin(to_radians)*r*0.73;
  x2 = x0 - cos(to_radians)*r*0.73;
  y2 = y0 + sin(to_radians)*r*0.73;
  line(x0, y0, x1, y1);
  line(x0, y0, x2, y2);

  // text
  x3 = x0 + cos(to_radians)*r*0.85;
  y3 = y0 - sin(to_radians)*r*0.85;
  x4 = x0 - cos(to_radians)*r*0.85;
  y4 = y0 + sin(to_radians)*r*0.85;
  fill(0);
  textFont(my_font, 40);
  textAlign(CENTER, CENTER);
  text(min, x3, y3);
  text((hour==0)?12:hour, x4, y4);
}

void my_draw_control_bar (boolean display_control_bar, int index) {
  // whether display control bar
  if (display_control_bar) {
    shape(control_bar, (sketch_w/2-180), (sketch_h-80));
    fill(127);
    textAlign(LEFT, BASELINE);
    textFont(my_font, 28);
    text("time is " + hour + "h " + min + "m " + display_sec +"s", (sketch_w/2+200), (sketch_h-40));
    textFont(my_font, 14);
    text("1. Press \" h \" to hide or show this control panel", 5, (sketch_h-60));
    text("2. Press \" p \" to pause", 5, (sketch_h-30));
    textFont(my_font, 11);
    text("hour-1    | fast backward |    normal    |    pause    | fast forward |    hour+1", (sketch_w/2-180), (sketch_h-6));
    stroke(127);
    line(0, sketch_h-80, sketch_w, sketch_h-80);

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
}

// control bar interaction
void mouseClicked() {
  if (mouseY > (sketch_h-80)) {
    btn_pressed = 0;
    if (display_control_bar) {
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
}

// hide keyboard
void keyPressed() {
  if (key == 'h' || key == 'H') {
    display_control_bar = !display_control_bar;
  }
  if (key == 'p' || key == 'P') {
    btn_pressed = 4;
  }
}