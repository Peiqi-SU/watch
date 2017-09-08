/**
 * line looks not sharp: hint(ENABLE_STROKE_PURE);
 * 122min = a round clock 360dgr, 12:12 to 1:01 is an exception.
 */
int sketch_w = 0, sketch_h = 0; 

// line
int x0 = 0, y0 = 0;
float x1 = 0, y1 = 0, x2 = 0, y2 = 0, x3 = 0, y3 = 0, x4 = 0, y4 = 0;
int r = 0;
float r_line = 0, r_text = 0;

// time
float delta_radians = 0, delta_radians1 = 0, delta_radians2 = 0;
float current_radians = 0;
boolean calculate_pos_fisttime = true;
int sec_begin = 0, sec_end = 0;
int accum_sec = 0, my_sec =0, my_min = 0, my_hour = 0;

PFont my_font;

void setup() {
  fullScreen();
  smooth(3);
  //size(230, 230);
  frameRate(1);
  background(0);
  sketch_w = width;
  sketch_h = height;
  //sketch_w = 230;
  //sketch_h = 230;
  x0 = sketch_w/2;
  y0 = sketch_h/2;
  r = sketch_h/2;
  r_line = r*0.7; // line length
  r_text = r*0.85;

  sec_begin = 12*60*60 + 12*60;
  sec_end = 1*60*60 + 1*60;

  delta_radians1 = TWO_PI/(122*60);
  delta_radians2 = PI/(48*60+58);

  my_font = loadFont("Roboto-Regular-32.vlw");
  calculate_pos_fisttime = true;
  calculate_pos();
}

void draw() {
  if (!wearAmbient()) {
    calculate_pos();
    my_draw_bg();
    my_draw_clock_lines(my_hour, my_min);
  }
}

void my_draw_bg() {
  background(255);
}

void calculate_pos() {
  my_sec = second();
  my_min = minute();
  my_hour = hour(); // 0-23
  if (my_hour>12) {
    my_hour = my_hour-12; // 1-12
  }
  if (my_hour==0) {
    my_hour = 12; // 1-12
  }

  accum_sec = my_hour*60*60 + my_min*60 + my_sec;

  if (accum_sec >sec_begin || accum_sec < sec_end) {//12:12 - 12:59
    delta_radians = delta_radians2;
  } else {
    delta_radians = delta_radians1;
  }

  if (calculate_pos_fisttime) {
    // calculate initial position
    if (accum_sec >sec_begin) {
      current_radians = (accum_sec-sec_begin) * delta_radians2+PI;
    } else if (accum_sec < sec_end) {//12:12 - 12:59
      current_radians = (accum_sec-sec_end) * delta_radians2;
    } else {
      current_radians = (accum_sec-sec_end) * delta_radians1;
    }

    calculate_pos_fisttime = false;
  } else {
    current_radians = current_radians + delta_radians;
  }

  if (my_hour==my_min && my_sec ==0) {//balence time
    if (my_hour%2 ==0) {// 180 degree
      current_radians = PI;
    } else {//0 degree
      current_radians = 0;
    }
  }
}

void my_draw_clock_lines(int hour, int min) {
  stroke(0);
  strokeWeight(2);
  //hint(ENABLE_STROKE_PURE);

  x1 = x0 + cos(current_radians)*r_line;
  y1 = y0 + sin(current_radians)*r_line;
  x2 = x0 - cos(current_radians)*r_line;
  y2 = y0 - sin(current_radians)*r_line;
  line(x0, y0, x1, y1);
  line(x0, y0, x2, y2);

  // text
  x3 = x0 + cos(current_radians)*r_text;
  y3 = y0 + sin(current_radians)*r_text;
  x4 = x0 - cos(current_radians)*r_text;
  y4 = y0 - sin(current_radians)*r_text;
  fill(0);
  textFont(my_font, 32);
  textAlign(CENTER, CENTER);
  text(hour, x3, y3);
  text(min, x4, y4);
}