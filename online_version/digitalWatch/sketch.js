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
};

var myDefDot = {
  px: 0,
};

function setup() {
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
}

function basicUi() {
  if (myGlobalDef.nightMode === true) {
    background(0);
    fill(255);
  } else {
    background(255);
    fill(0);
  }

  // display time
  var myTextSize = (windowWidth / 32);
  textSize(myTextSize);
  textAlign(LEFT);
  myGlobalDef.h = ("0" + myGlobalDef.h).slice(-2);
  myGlobalDef.m = ("0" + myGlobalDef.m).slice(-2);
  myGlobalDef.s = ("0" + myGlobalDef.s).slice(-2);
  text(myGlobalDef.h + ":" + myGlobalDef.m + ":" + myGlobalDef.s, (windowWidth / 12), (windowHeight / 6));

}

function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
  uiUpdate();
}

function uiUpdate() {
  // update watch size and position
  myGlobalDef.dia = windowWidth / 6;
  myGlobalDef.watchY = windowHeight / 2;
  myDefLine.px = windowWidth / 6;
  myDefBalance.px = windowWidth / 2;
  myDefDot.px = windowWidth / 6 * 5;

  myDefLine.lineDist = myGlobalDef.dia / 61.0;


  console.log("uiUpdate");
}

function drawLineWatch() {
  // daytime and nighttime
  if (myGlobalDef.nightMode === true) {
    fill(255);
    stroke(0);
  } else {
    fill(0);
    stroke(255);
  }
  ellipse(myDefLine.px, myGlobalDef.watchY, myGlobalDef.dia);

  for (var i = 0; i <= myGlobalDef.m; i++) {
    if (myDefLine.thickness_vary) {
      var thickness = (myDefLine.thickness_end - myDefLine.thickness_begin) / 60.0 * i+1;
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

  console.log("drawLineWatch");
}

function drawBalanceWatch() {
  fill(255);
  ellipse(myDefBalance.px, myGlobalDef.watchY, myGlobalDef.dia);
}

function drawDotWatch() {
  fill(255);
  ellipse(myDefDot.px, myGlobalDef.watchY, myGlobalDef.dia);
}

// when press mouse
// change line thickness of line watch
function mousePressed() {
  myDefLine.thickness_vary = !myDefLine.thickness_vary;
}