// For Yumi, Project Watch: Line, balance blue, dot

var myGlobalDef = {
  dia: 0,
  watchY: 0,
  h: 0,
  m: 0,
  s: 0,
  nightMode: true,
  scaleK: 0.0,
};

var myDefLine = {
  px: 0,
  thickness_vary: false,
  thickness_begin: 1,
  thickness_end: 5,
  lineDist: 0,
};

var myDefBalance = {
  px: 0,
  h: 0,
  m: 0,
  s: 0,
  x0: 0,
  y0: 0,
  diaText: 0,
  myFont: 0,
  myFontSize: 22,
  myFontSizeToTop: 7, // myFontSize * 0.3
  myFontSizeToBtm: 12, // myFontSize * 0.5

  current_radians: 0,
  delta_radians: 0,
  delta_radians1: 0,
  delta_radians2: 0,
  calculate_pos_fisttime: true,
  sec_begin: 12 * 60 * 60 + 12 * 60,
  sec_end: 1 * 60 * 60 + 1 * 60,
  accum_sec: 0,

  // tangent
  pg: 0,

};

var myDefDot = {
  px: 0,
};

function preload() {
  myFont = loadFont('assets/RobotoRegular.ttf');
}

function setup() {
  frameRate(1);
  createCanvas(windowWidth, windowHeight);
  uiUpdate();
}

function draw() {
  myGetTime();
  basicUi();
  drawLineWatch();
  drawBalanceWatch();
  drawDotWatch();
}

function myGetTime() {
  myGlobalDef.h = hour();
  myGlobalDef.m = minute();
  myGlobalDef.s = second();
  if (myGlobalDef.h > 6 && myGlobalDef.h < 18) {
    myGlobalDef.nightMode = false;
  } else {
    myGlobalDef.nightMode = true;
  }

  // setup balance watch local time
  myDefBalance.h = hour();
  myDefBalance.m = minute();
  myDefBalance.s = second();
}

function basicUi() {
  if (myGlobalDef.nightMode === true) {
    background(0);
    fill(255);
  } else {
    background(255);
    fill(0);
  }

  // draw 3 watch face
  ellipse(myDefLine.px, myGlobalDef.watchY, myGlobalDef.dia);
  ellipse(myDefBalance.px, myGlobalDef.watchY, myGlobalDef.dia);
  ellipse(myDefDot.px, myGlobalDef.watchY, myGlobalDef.dia);

  // display time
  textSize(32 * myGlobalDef.scaleK);
  textAlign(LEFT);
  var DisplayH = myGlobalDef.h % 12;
  DisplayH = ("0" + DisplayH).slice(-2);
  var DisplayM = ("0" + myGlobalDef.m).slice(-2);
  var DisplayS = ("0" + myGlobalDef.s).slice(-2);
  text(DisplayH + ":" + DisplayM + ":" + DisplayS, (windowWidth / 12), (windowHeight / 6));
}



function uiUpdate() {
  // update watch size and position
  myGlobalDef.dia = windowWidth / 6;
  myGlobalDef.watchY = windowHeight / 2;
  myDefLine.px = windowWidth / 6;
  myDefBalance.px = windowWidth / 2;
  myDefDot.px = windowWidth / 6 * 5;

  // update scale k
  myGlobalDef.scaleK = windowWidth / 1000;

  // line watch
  myDefLine.lineDist = myGlobalDef.dia / 61.0;
  myDefLine.thickness_begin = 1 * myGlobalDef.scaleK;
  myDefLine.thickness_end = 4 * myGlobalDef.scaleK;

  // balance watch
  myDefBalance.x0 = myDefBalance.px;
  myDefBalance.y0 = myGlobalDef.watchY;
  myDefBalance.diaText = myGlobalDef.dia * 0.8;

  myDefBalance.delta_radians1 = TWO_PI / (122 * 60);
  myDefBalance.delta_radians2 = PI / (48 * 60 + 58);

  myDefBalance.pg = createGraphics(windowWidth, windowHeight);
  myDefBalance.moffset = createVector(1000.0, 1000.0, 1000.0);
  myDefBalance.mnew_offset = createVector(1000.0, 1000.0, 1000.0);
  myDefBalance.hoffset = createVector(1000.0, 1000.0, 1000.0);
  myDefBalance.hnew_offset = createVector(1000.0, 1000.0, 1000.0);
}

function drawLineWatch() {
  // daytime and nighttime
  if (myGlobalDef.nightMode === true) {
    stroke(0);
  } else {
    stroke(255);
  }

  for (var i = 0; i <= myGlobalDef.m; i++) {
    if (myDefLine.thickness_vary) {
      var thickness = (myDefLine.thickness_end - myDefLine.thickness_begin) / 60.0 * i + 0.2 * myGlobalDef.scaleK;
      strokeWeight(thickness);
    } else {
      strokeWeight(myDefLine.thickness_begin);
    }

    var x0 = myDefLine.px - myGlobalDef.dia / 2.0;
    var y0 = myGlobalDef.watchY + myGlobalDef.dia / 2.0 - myDefLine.lineDist * (i + 1);
    var x1 = myDefLine.px + myGlobalDef.dia / 2.0;
    var y1 = y0;
    line(x0, y0, x1, y1);
  }
}

function drawBalanceWatch() {
  noStroke();

  calculate_pos_balance_watch();
  my_draw_clock_lines_balance_watch(myDefBalance.h, myDefBalance.m);

  // for debug ///////////////////////////////////////////////////////////////////////////////
  //image(myDefBalance.pg, 0, 0);
}

function drawDotWatch() {
  noStroke();

}

function calculate_pos_balance_watch() {
  myGlobalDef.h = myGlobalDef.h % 12 + 1; // from 0-23 to 1-12

  myDefBalance.accum_sec = myDefBalance.h * 60 * 60 + myDefBalance.m * 60 + myDefBalance.s;

  if (myDefBalance.accum_sec > myDefBalance.sec_begin || myDefBalance.accum_sec < myDefBalance.sec_end) { //12:12 - 12:59
    myDefBalance.delta_radians = myDefBalance.delta_radians2;
  } else {
    myDefBalance.delta_radians = myDefBalance.delta_radians1;
  }

  if (myDefBalance.calculate_pos_fisttime) {
    // calculate initial position
    if (myDefBalance.accum_sec > myDefBalance.sec_begin) { //12:12 - 12:59
      myDefBalance.current_radians = (myDefBalance.accum_sec - myDefBalance.sec_begin) * myDefBalance.delta_radians2 + PI;
    } else if (myDefBalance.accum_sec < myDefBalance.sec_end) { // 1:00-1:00:59
      myDefBalance.current_radians = (myDefBalance.accum_sec - myDefBalance.sec_end) * myDefBalance.delta_radians2;

    } else {
      myDefBalance.current_radians = (myDefBalance.accum_sec - myDefBalance.sec_end) * myDefBalance.delta_radians1;
    }

    myDefBalance.calculate_pos_fisttime = false;
  } else {
    myDefBalance.current_radians = myDefBalance.current_radians + myDefBalance.delta_radians;
  }

  if (myDefBalance.h === myDefBalance.m && myDefBalance.s === 0) { //balence time
    if (myDefBalance.h % 2 === 0) { // 180 degree
      myDefBalance.current_radians = PI;
    } else { //0 degree
      myDefBalance.current_radians = 0;
    }
  }
}


function my_draw_clock_lines_balance_watch(myHour, myMin) {
  // draw blue arc
  noStroke();
  fill(0, 0, 255);
  arc(myDefBalance.x0, myDefBalance.y0, myGlobalDef.dia, myGlobalDef.dia, (myDefBalance.current_radians - PI), (myDefBalance.current_radians), PIE);

  // text is alway on white part

  // calculate text position on pgraphic
  var calculatedHourMinCoord = calculatePG_balance_watch(myDefBalance.current_radians, myGlobalDef.dia / 2, myGlobalDef.dia / 2 * 0.8, myHour, myMin);

  if (myGlobalDef.nightMode) {
    fill(0);
  } else {
    fill(255);
  }
  textFont(myFont);
  var textSizeTempt = myDefBalance.myFontSize * myGlobalDef.scaleK;
  textSize(textSizeTempt);
  textAlign(CENTER, CENTER);
  text(myHour, calculatedHourMinCoord[0], calculatedHourMinCoord[1]);
  text(myMin, calculatedHourMinCoord[2], calculatedHourMinCoord[3]);
}

function calculatePG_balance_watch(to_radians, r, r_text, myHour, myMin) {
  var mbx1, mby1, mbx2, mby2; // min box border
  var hbx1, hby1, hbx2, hby2; // hour box border
  var linex1, liney1, linex2, liney2; // line (x1, y1, x2, y2)
  var hourMinCoord = [0.0, 0.0, 0.0, 0.0]; // (hourX, hourY, minX, minY) replace previous: hour(x3, y3) min (x4, y4)

  // min and hour offset
  var moffset = createVector(1000.0, 1000.0, 1000.0);
  var mnew_offset = createVector(1000.0, 1000.0, 1000.0);
  var hoffset = createVector(1000.0, 1000.0, 1000.0);
  var hnew_offset = createVector(1000.0, 1000.0, 1000.0);

  // min and hour nearest distance
  var mnear_x = 0.0;
  var mnear_y = 0.0;
  var hnear_x = 0.0;
  var hnear_y = 0.0;

  myDefBalance.pg.background(20, 0, 0);

  // line (x1, y1, x2, y2)
  linex1 = myDefBalance.x0 + cos(to_radians) * r;
  liney1 = myDefBalance.y0 + sin(to_radians) * r;
  linex2 = myDefBalance.x0 - cos(to_radians) * r;
  liney2 = myDefBalance.y0 - sin(to_radians) * r;

  // min (x4, y4) hour(x3, y3)
  hourMinCoord[0] = myDefBalance.x0 + cos(to_radians + PI / 15) * r_text;
  hourMinCoord[1] = myDefBalance.y0 + sin(to_radians + PI / 15) * r_text;
  hourMinCoord[2] = myDefBalance.x0 - cos(to_radians - PI / 15) * r_text;
  hourMinCoord[3] = myDefBalance.y0 - sin(to_radians - PI / 15) * r_text;

  // line
  myDefBalance.pg.fill(255, 0, 0);
  myDefBalance.pg.noStroke();
  myDefBalance.pg.arc(myDefBalance.x0, myDefBalance.y0, r * 2, r * 2, (myDefBalance.current_radians - PI), (myDefBalance.current_radians), PIE);

  // text
  var textSizeTempt = myDefBalance.myFontSize * myGlobalDef.scaleK;
  myDefBalance.pg.textFont(myFont, textSizeTempt);
  myDefBalance.pg.textAlign(CENTER, CENTER);
  myDefBalance.pg.fill(0, 255, 0);
  myDefBalance.pg.text(myHour, hourMinCoord[0], hourMinCoord[1]);
  myDefBalance.pg.text(myMin, hourMinCoord[2], hourMinCoord[3]);

  // box of the text
  var hcw = int(myDefBalance.pg.textWidth(str(myHour)));
  var mcw = int(myDefBalance.pg.textWidth(str(myMin)));

  myDefBalance.pg.noFill();
  myDefBalance.pg.stroke(255);
  hbx1 = int(hourMinCoord[0] - hcw / 2);
  hby1 = int(hourMinCoord[1] - myDefBalance.myFontSizeToTop * myGlobalDef.scaleK);
  hbx2 = int(hourMinCoord[0] + hcw / 2);
  hby2 = int(hourMinCoord[1] + myDefBalance.myFontSizeToBtm * myGlobalDef.scaleK);
  mbx1 = int(hourMinCoord[2] - mcw / 2);
  mby1 = int(hourMinCoord[3] - myDefBalance.myFontSizeToTop * myGlobalDef.scaleK);
  mbx2 = int(hourMinCoord[2] + mcw / 2);
  mby2 = int(hourMinCoord[3] + myDefBalance.myFontSizeToBtm * myGlobalDef.scaleK);

  // debug
  myDefBalance.pg.rectMode(CORNERS);
  myDefBalance.pg.noFill();
  myDefBalance.pg.stroke(125);
  myDefBalance.pg.strokeWeight(1);
  myDefBalance.pg.rect(hbx1, hby1, hbx2, hby2);
  myDefBalance.pg.stroke(125);
  myDefBalance.pg.rect(mbx1, mby1, mbx2, mby2);

  // get a image of current pg
  myDefBalance.pg.loadPixels();
  var d = pixelDensity();

  // get every pixel color for min
  for (var i = mbx1; i < mbx2; i++) {
    for (var j = mby1; j < mby2; j++) {
      // var c = myDefBalance.pg.get(i, j);
      for (var k = 0; k < d; k++) {
        for (var l = 0; l < d; l++) {
          // loop over
          var idx = 4 * ((j * d + l) * width * d + (i * d + k));
          var myGreen = myDefBalance.pg.pixels[idx + 1]; //green()
          // if it's a green pixel
          if (myGreen > 200) {
            // calculate the dist
            mnew_offset = getDistance_balance_watch(linex1, liney1, linex2, liney2, i, j);
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
    }
  }

  // get every pixel color for hour
  for (var i = hbx1; i < hbx2; i++) {
    for (var j = hby1; j < hby2; j++) {
      // var c = myDefBalance.pg.get(i, j);
      for (var k = 0; k < d; k++) {
        for (var l = 0; l < d; l++) {
          // loop over
          var idx = 4 * ((j * d + l) * width * d + (i * d + k));
          var myGreen = myDefBalance.pg.pixels[idx + 1]; //green()
          // if it's a green pixel
          if (myGreen > 200) {
            // calculate the dist
            hnew_offset = getDistance_balance_watch(linex1, liney1, linex2, liney2, i, j);
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
    }
  }

  hourMinCoord[0] = hourMinCoord[0] + (hoffset.x - hnear_x);
  hourMinCoord[1] = hourMinCoord[1] + (hoffset.y - hnear_y);
  hourMinCoord[2] = hourMinCoord[2] + (moffset.x - mnear_x);
  hourMinCoord[3] = hourMinCoord[3] + (moffset.y - mnear_y);

  return hourMinCoord;
}

function getDistance_balance_watch(lx1, ly1, lx2, ly2, dotx, doty) {
  var result = createVector(0.0, 0.0, 0.0);
  var my_return = createVector(0.0, 0.0);
  var dx, dy, d, ca, sa, mx, dx2, dy2;

  dx = lx2 - lx1;
  dy = ly2 - ly1;
  d = sqrt(dx * dx + dy * dy);
  ca = dx / d; // cosine
  sa = dy / d; // sine

  mx = (-lx1 + dotx) * ca + (-ly1 + doty) * sa;

  if (mx <= 0) {
    result.x = lx1;
    result.y = ly1;
  } else if (mx >= d) {
    result.x = lx2;
    result.y = ly2;
  } else {
    result.x = lx1 + mx * ca;
    result.y = ly1 + mx * sa;
  }

  dx2 = dotx - result.x;
  dy2 = doty - result.y;
  my_return.x = dx2;
  my_return.y = dy2;
  result.z = sqrt(dx2 * dx2 + dy2 * dy2);

  return result;
}


// when press mouse
// change line thickness of line watch
function mousePressed() {
  myDefLine.thickness_vary = !myDefLine.thickness_vary;
}


// when window resized
function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
  uiUpdate();
}