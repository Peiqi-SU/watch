// For Yumi, Project Watch: Line, balance blue, dot

var myGlobalDef = {
  dia: 0,
  watchY: 0,
  h: 0,
  m: 0,
  s: 0,
  nightMode: true,
};

var myDefLine = {
  px: 0,
  thickness_vary: true,
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
  x1: 0,
  x2: 0,
  x3: 0,
  x4: 0,
  y1: 0,
  y2: 0,
  y3: 0,
  y4: 0,
  diaText: 0,
  myFont: 0,

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
  moffset: 0,
  mnew_offset: 0,
  hoffset: 0,
  hnew_offset: 0,
  mnear_x: 0.0,
  mnear_y: 0.0,
  hnear_x: 0.0,
  hnear_y: 0.0,
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
  var myTextSize = (windowWidth / 32);
  textSize(myTextSize);
  textAlign(LEFT);
  var DisplayH = myGlobalDef.h % 12 + 1;
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

  // line watch
  myDefLine.lineDist = myGlobalDef.dia / 61.0;

  // balance watch
  myDefBalance.x0 = myDefBalance.px;
  myDefBalance.y0 = myGlobalDef.watchY;
  myDefBalance.diaText = myGlobalDef.dia * 0.85;

  myDefBalance.delta_radians1 = TWO_PI / (122 * 60);
  myDefBalance.delta_radians2 = PI / (48 * 60 + 58);

  myDefBalance.pg = createGraphics(windowWidth, windowHeight);
  myDefBalance.moffset = createVector(1000.0, 1000.0, 1000.0);
  myDefBalance.mnew_offset = createVector(1000.0, 1000.0, 1000.0);
  myDefBalance.hoffset = createVector(1000.0, 1000.0, 1000.0);
  myDefBalance.hnew_offset = createVector(1000.0, 1000.0, 1000.0);

  calculate_pos_balance_watch();
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
      var thickness = (myDefLine.thickness_end - myDefLine.thickness_begin) / 60.0 * i + 0.5;
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

  //console.log("drawLineWatch");
}

function drawBalanceWatch() {
  noStroke();

  calculate_pos_balance_watch();
  my_draw_clock_lines_balance_watch(myDefBalance.h, myDefBalance.m);

  //image(myDefBalance.pg,0,0);

  // reset variables
  myDefBalance.moffset.set(1000.0, 1000.0, 1000.0);
  myDefBalance.mnew_offset.set(1000.0, 1000.0, 1000.0);
  myDefBalance.mnear_x = 0.0;
  myDefBalance.mnear_y = 0.0;
  myDefBalance.hoffset.set(1000.0, 1000.0, 1000.0);
  myDefBalance.hnew_offset.set(1000.0, 1000.0, 1000.0);
  myDefBalance.hnear_x = 0.0;
  myDefBalance.hnear_y = 0.0;

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
  calculatePG_balance_watch(myDefBalance.current_radians, myGlobalDef.dia / 2, myGlobalDef.dia / 2 * 0.85);

  myDefBalance.x3 = myDefBalance.x3 + (myDefBalance.hoffset.x - myDefBalance.hnear_x);
  myDefBalance.y3 = myDefBalance.y3 + (myDefBalance.hoffset.y - myDefBalance.hnear_y);
  myDefBalance.x4 = myDefBalance.x4 + (myDefBalance.moffset.x - myDefBalance.mnear_x);
  myDefBalance.y4 = myDefBalance.y4 + (myDefBalance.moffset.y - myDefBalance.mnear_y);

  if (myGlobalDef.nightMode) {
    fill(0);
  } else {
    fill(255);
  }

  textFont(myFont, 32);
  textAlign(CENTER, CENTER);
  text(myHour, myDefBalance.x3, myDefBalance.y3);
  text(myMin, myDefBalance.x4, myDefBalance.y4);
  fill(255, 0, 0);
  // text(myHour, myDefBalance.x3 - 10000, myDefBalance.y3 - 10000);
  // text(myMin, myDefBalance.x4 + 100, myDefBalance.y4 + 500);


}

function calculatePG_balance_watch(to_radians, r, r_text) {
  var mbx1, mby1, mbx2, mby2; // min box barder
  var hbx1, hby1, hbx2, hby2; // hour box barder

  myDefBalance.pg.background(20, 0, 0);

  // line (x1, y1, x2, y2)
  myDefBalance.x1 = myDefBalance.x0 + cos(to_radians) * r;
  myDefBalance.y1 = myDefBalance.y0 + sin(to_radians) * r;
  myDefBalance.x2 = myDefBalance.x0 - cos(to_radians) * r;
  myDefBalance.y2 = myDefBalance.y0 - sin(to_radians) * r;

  // min (x4, y4) hour(x3, y3)
  myDefBalance.x3 = myDefBalance.x0 + cos(to_radians + PI / 18) * r_text;
  myDefBalance.y3 = myDefBalance.y0 + sin(to_radians + PI / 18) * r_text;
  myDefBalance.x4 = myDefBalance.x0 - cos(to_radians - PI / 18) * r_text;
  myDefBalance.y4 = myDefBalance.y0 - sin(to_radians - PI / 18) * r_text;

  // line
  myDefBalance.pg.fill(255, 0, 0);
  myDefBalance.pg.noStroke();
  myDefBalance.pg.arc(myDefBalance.x0, myDefBalance.y0, r * 2, r * 2, (myDefBalance.current_radians - PI), (myDefBalance.current_radians), PIE);

  // text
  myDefBalance.pg.textFont(myFont, 32);
  myDefBalance.pg.textAlign(CENTER, CENTER);
  myDefBalance.pg.fill(0, 255, 0);
  myDefBalance.pg.text(myDefBalance.h, myDefBalance.x3, myDefBalance.y3);
  myDefBalance.pg.text(myDefBalance.m, myDefBalance.x4, myDefBalance.y4);

  // box of the text
  var hcw = int(myDefBalance.pg.textWidth(str(myDefBalance.h)));
  var mcw = int(myDefBalance.pg.textWidth(str(myDefBalance.m)));

  myDefBalance.pg.noFill();
  myDefBalance.pg.stroke(255);
  hbx1 = int(myDefBalance.x3 - hcw / 2);
  hby1 = int(myDefBalance.y3 - 18);
  hbx2 = int(myDefBalance.x3 + hcw / 2);
  hby2 = int(myDefBalance.y3 + 18);
  mbx1 = int(myDefBalance.x4 - mcw / 2);
  mby1 = int(myDefBalance.y4 - 18);
  mbx2 = int(myDefBalance.x4 + mcw / 2);
  mby2 = int(myDefBalance.y4 + 18);

  // debug
  myDefBalance.pg.rectMode(CORNERS);
  myDefBalance.pg.noFill();
  myDefBalance.pg.stroke(255);
  myDefBalance.pg.strokeWeight(1);
  myDefBalance.pg.rect(hbx1, hby1, hbx2, hby2);
  myDefBalance.pg.stroke(125);
  myDefBalance.pg.rect(mbx1, mby1, mbx2, mby2);
console.log((hbx2-hbx1) + ":"+(hby2-hby1) + "-----"+ (mbx2-mbx1) + ":"+(mby2-mby1));
console.log(mbx1 + "-" +mbx2);

// console.log(mbx1 +" -- "+mbx2 );
  // get every pixel color for min
  for (var i = mbx1; i < mbx2; i+=6) {
    for (var j = mby1; j < mby2; j+=6) {
      var c = myDefBalance.pg.get(i, j);
      // if it's a black pixel
      if (green(c) > 125) {
        // calculate the dist
        myDefBalance.mnew_offset = getDistance_balance_watch(myDefBalance.x1, myDefBalance.y1, myDefBalance.x2, myDefBalance.y2, i, j);
        //println("new_offset ", new_offset.z, "---offset", offset.z);

        // if the dist is smaller than saved one, replace it
        if (myDefBalance.mnew_offset.z < myDefBalance.moffset.z) {
          myDefBalance.moffset = myDefBalance.mnew_offset.copy();
          myDefBalance.mnear_x = i;
          myDefBalance.mnear_y = j;
          //println(i, j);
        }
      }
    }
  }
  
  // get every pixel color for hour
  for (var k = hbx1; k < hbx2; k+=6) {
    for (var l = hby1; l < hby2; l+=6) {
      var c2 = myDefBalance.pg.get(k, l);
      // if it's a black pixel
      if (green(c2) > 125) {
        // calculate the dist
        myDefBalance.hnew_offset = getDistance_balance_watch(myDefBalance.x1, myDefBalance.y1, myDefBalance.x2, myDefBalance.y2, k, l);
        //println("new_offset ", new_offset.z, "---offset", offset.z);

        // if the dist is smaller than saved one, replace it
        if (myDefBalance.hnew_offset.z < myDefBalance.hoffset.z) {
          myDefBalance.hoffset = myDefBalance.hnew_offset.copy();
          myDefBalance.hnear_x = k;
          myDefBalance.hnear_y = l;
          //println(i, j);
        }
      }
    }
  }
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