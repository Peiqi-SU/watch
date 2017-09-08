/**
 * line looks not sharp: hint(ENABLE_STROKE_PURE);
 * 122min = a round clock 360dgr, 12:12 to 1:01 is an exception.
 */
int sketch_w = 0, sketch_h = 0, x0 = 0, y0 = 0; // center
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

// tangent
PGraphics pg;
PVector moffset, mnew_offset; // min
PVector hoffset, hnew_offset; // hour
float mnear_x = 0.0, mnear_y = 0.0; // min 
float hnear_x = 0.0, hnear_y = 0.0; // hour

void setup() {
  //size(300, 300);
  //sketch_w = 300;
  //sketch_h = 300;

  fullScreen();
  smooth(3);
  sketch_w = width;
  sketch_h = height;

  frameRate(1);
  background(0);

  x0 = sketch_w/2;
  y0 = sketch_h/2;
  r = sketch_h/2;
  r_text = r*0.85;

  sec_begin = 12*60*60 + 12*60;
  sec_end = 1*60*60 + 1*60;

  delta_radians1 = TWO_PI/(122*60);
  delta_radians2 = PI/(48*60+58);

  // for pgraphic
  pg = createGraphics(sketch_w, sketch_h);
  moffset = new PVector(1000.0, 1000.0, 1000.0);
  mnew_offset = new PVector(1000.0, 1000.0, 1000.0);
  hoffset = new PVector(1000.0, 1000.0, 1000.0);
  hnew_offset = new PVector(1000.0, 1000.0, 1000.0);

  my_font = loadFont("Roboto-Regular-32.vlw");

  calculate_pos_fisttime = true;
  calculate_pos();
}

void draw() {
  if (!wearAmbient()) {
  calculate_pos();
  my_draw_bg();
  my_draw_clock_lines(my_hour, my_min);
  
  //image(pg,0,0);

  // reset variables
  moffset.set(1000.0, 1000.0, 1000.0);
  mnew_offset.set(1000.0, 1000.0, 1000.0);
  mnear_x = 0.0;
  mnear_y = 0.0;
  hoffset.set(1000.0, 1000.0, 1000.0);
  hnew_offset.set(1000.0, 1000.0, 1000.0);
  hnear_x = 0.0;
  hnear_y = 0.0;
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
    if (accum_sec >sec_begin) {//12:12 - 12:59
      current_radians = (accum_sec-sec_begin) * delta_radians2+PI;
    } else if (accum_sec < sec_end) { // 1:00-1:00:59
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
  // draw blue arc
  noStroke();
  //hint(ENABLE_STROKE_PURE);
  fill(#0000ff);
  arc(x0, y0, r*2, r*2, (current_radians-PI), (current_radians), PIE);

  // text is alway on white part

  // calculate text position on pgraphic
  calculatePG(current_radians);

  x3 = x3 + (hoffset.x - hnear_x);
  y3 = y3 + (hoffset.y - hnear_y);
  x4 = x4 + (moffset.x - mnear_x);
  y4 = y4 + (moffset.y - mnear_y);
  fill(0);
  textFont(my_font, 32);
  textAlign(CENTER, CENTER);
  text(hour, x3, y3);
  text(min, x4, y4);
}

void calculatePG(float to_radians) {

  int mbx1, mby1, mbx2, mby2; // min box barder
  int hbx1, hby1, hbx2, hby2; // hour box barder

  pg.beginDraw();
  pg.background(0);

  // line (x1, y1, x2, y2)
  x1 = x0 + cos(to_radians)*r;
  y1 = y0 + sin(to_radians)*r;
  x2 = x0 - cos(to_radians)*r;
  y2 = y0 - sin(to_radians)*r;

  // min (x4, y4) hour(x3, y3)
  x3 = x0 + cos(to_radians+PI/18)*r_text;
  y3 = y0 + sin(to_radians+PI/18)*r_text;
  x4 = x0 - cos(to_radians-PI/18)*r_text;
  y4 = y0 - sin(to_radians-PI/18)*r_text;

  // line
  pg.fill(#ff0000);
  pg.noStroke();
  pg.arc(x0, y0, r*2, r*2, (current_radians-PI), (current_radians), PIE);

  // text
  pg.textFont(my_font, 32);
  pg.textAlign(CENTER, CENTER);
  pg.fill(#00ff00);
  pg.text(my_hour, x3, y3);
  pg.text(my_min, x4, y4);

  // box of the text
  int hcw = int(pg.textWidth(str(my_hour)));
  int mcw = int(pg.textWidth(str(my_min)));
  pg.noFill();
  pg.stroke(255);   
  hbx1 = int(x3-hcw/2);
  hby1 = int(y3-16);
  hbx2 = int(x3+hcw/2);
  hby2 = int(y3+16);
  mbx1 = int(x4-mcw/2);
  mby1 = int(y4-16);
  mbx2 = int(x4+mcw/2);
  mby2 = int(y4+16);
  
  // debug
  //pg.rectMode(CORNERS);
  //pg.noFill();
  //pg.stroke(255);
  //pg.strokeWeight(2);
  //pg.rect(hbx1, hby1, hbx2,hby2);
  //pg.stroke(125);
  //pg.rect(mbx1, mby1, mbx2,mby2);

  // get every pixel color for min
  for (int i=mbx1; i<mbx2; i++) {
    for (int j=mby1; j<mby2; j++) {
      color c = pg.get(i, j);
      // if it's a black pixel
      if (green(c) > 125) {
        // calculate the dist
        mnew_offset = getDistance(x1, y1, x2, y2, i, j);
        //println("new_offset ", new_offset.z, "---offset", offset.z);

        // if the dist is smaller than saved one, replace it
        if (mnew_offset.z < moffset.z) {
          moffset = mnew_offset.copy();
          mnear_x = i;
          mnear_y = j;
          //println(i, j);
        }
      }
    }
  }
  // get every pixel color for hour
  for (int i=hbx1; i<hbx2; i++) {
    for (int j=hby1; j<hby2; j++) {
      color c = pg.get(i, j);
      // if it's a black pixel
      if (green(c) > 125) {
        // calculate the dist
        hnew_offset = getDistance(x1, y1, x2, y2, i, j);
        //println("new_offset ", new_offset.z, "---offset", offset.z);

        // if the dist is smaller than saved one, replace it
        if (hnew_offset.z < hoffset.z) {
          hoffset = hnew_offset.copy();
          hnear_x = i;
          hnear_y = j;
          //println(i, j);
        }
      }
    }
  }
  pg.endDraw();
}



// line: dx1, dy1, dx2, dy2; dot: dx, dy
PVector getDistance( float lx1, float ly1, float lx2, float ly2, float dotx, float doty ) {
  PVector result = new PVector(0, 0);
  PVector my_return = new PVector(0, 0);
  float dx, dy, d, ca, sa, mx, dx2, dy2;

  dx = lx2 - lx1; 
  dy = ly2 - ly1; 
  d = sqrt( dx*dx + dy*dy ); 
  ca = dx/d; // cosine
  sa = dy/d; // sine

  mx = (-lx1+dotx)*ca + (-ly1+doty)*sa;

  if ( mx <= 0 ) {
    result.x = lx1; 
    result.y = ly1;
  } else if ( mx >= d ) {
    result.x = lx2; 
    result.y = ly2;
  } else {
    result.x = lx1 + mx*ca; 
    result.y = ly1 + mx*sa;
  }

  dx2 = dotx - result.x; 
  dy2 = doty - result.y; 
  my_return.x = dx2;
  my_return.y = dy2;
  result.z = sqrt( dx2*dx2 + dy2*dy2 ); 

  return result;
}