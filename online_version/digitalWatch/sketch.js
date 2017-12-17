// For Yumi, Project Watch: Line, balance blue, dot

var myLineWatch; //obj
var previousSec = 0; // timer
var myFont;

function preload() {
  myFont = loadFont('assets/RobotoRegular.ttf');
}

function setup() {
  frameRate(30); // TOD0: CHANGE TO 30
  createCanvas(windowWidth, windowHeight);
  previousSec = second();

  myLineWatch = new LineWatch(false); //obj LineWatch(_thickness_vary)
  myBalanceWatch = new BalanceWatch(windowWidth, windowHeight); //obj BalanceWatch(_windowWidth, _windowHeight)

  sizeChanged(); // init parameters with current size
}

function draw() {
  // update every second
  var currentSec = second();
  if (previousSec != currentSec) {
    var tempNightMode = basicUi(); // bg and top left text "current time"

    myLineWatch.updateMe(tempNightMode, minute()); //function(_nightMode, _min)
    myLineWatch.drawMe();

    myBalanceWatch.updateMe(tempNightMode, hour(), minute(), second()); //function(_nightMode, _myHour, _myMin, _mySec) 
    myBalanceWatch.drawMe();
  }

  // update every frame

  // update timer
  previousSec = currentSec;
}

function mousePressed() {
  // change line thickness of line watch
  myLineWatch.thickness_vary = !myLineWatch.thickness_vary;
}

function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
  sizeChanged();
}

function sizeChanged() {
  // update watch size and position
  var tempDia = windowWidth / 6;
  var tempWatchY = windowHeight / 2;
  var tempScaleK = windowWidth / 1000;

  myLineWatch.updateParameters(tempScaleK, tempDia, windowWidth / 6, tempWatchY); //function(_scaleK, _dia, _watchX, _watchY)
  myBalanceWatch.updateParameters(tempScaleK, tempDia, windowWidth / 2, tempWatchY, windowWidth, windowHeight); //function(_scaleK, _dia, _watchX, _watchY)
}

function basicUi() {
  // night mode
  var temptH = hour();
  var returnValue = false;
  if (temptH > 6 && temptH < 18) { // daytime
    background(255);
    fill(0);
    returnValue = false;
  } else { // nighttime
    background(0);
    fill(255);
    returnValue = true;
  }

  // display time
  var tempScaleK = windowWidth / 1000;
  textFont(myFont);
  textSize(32 * tempScaleK);
  textAlign(LEFT);
  var DisplayH = temptH % 12;
  DisplayH = ("0" + DisplayH).slice(-2);
  var DisplayM = ("0" + minute()).slice(-2);
  var DisplayS = ("0" + second()).slice(-2);
  text(DisplayH + ":" + DisplayM + ":" + DisplayS, (windowWidth / 12), (windowHeight / 6));

  return returnValue;
}