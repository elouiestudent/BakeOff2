import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done
boolean closeDist = false;
boolean closeRotation = false;
boolean closeZ = false;
float targetX;
float targetY;

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

boolean isDragging = false;
boolean isRotating = false;
//boolean isResizing = false;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}


void draw() {
  checkForSuccess();

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i) {
      targetX = d.x;
      targetY = d.y;
      if (!checkForSuccess())
        stroke(255, 0, 0, 192); //set color to semi translucent
      else stroke(32, 190, 21); 
    }
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }
  
  //========== DRAW ARROW =====================
  strokeWeight(3);
  float d = dist(targetX, targetY, logoX, logoY);
  float angle = atan2(targetY - logoY, targetX - logoX) * 180/PI;
  if (checkForSuccess()) {
    stroke(32, 190, 21); 
  }
  else {
    stroke(255,0,0);
    drawArrow(int(logoX),int(logoY),int(d), angle);
  }
  

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center of the logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  if (!checkForSuccess()) {
    fill(60, 60, 192, 192);
    rect(0, 0, logoZ, logoZ);
  }
  else  {
    fill(32, 190, 21); 
    rect(0, 0, logoZ, logoZ);
    fill(255);
    rotate(-radians(logoRotation));
    text("submit", 0, 0);
  }
  
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  
  scaffoldControlLogic(); 
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, 80, inchToPix(.8f));
  
  // code for indicators
  if (closeDist) fill(60, 148, 56); 
  else fill(244, 60, 20);
  rect(40, 100, 170, 50, 20); //location
  
  if (closeRotation) fill(60, 148, 56); 
  else fill(244, 60, 20);
  rect(40, 160, 170, 50, 20); //rotation
  
  if (closeZ) fill(60, 148, 56); 
  else fill(244, 60, 20);
  rect(40, 220, 170, 50, 20); //size
  
  fill(255, 255, 255);
  text("location", 75, 105);
  text("rotation", 75, 165);
  text("size", 61, 225);
  
  //float lbotcx = -logoZ / 2;
  //float lbotcy = logoZ / 2;
  //float ltopcx = -logoZ / 2;
  //float ltopcy = -logoZ / 2;
  //float rbotcx = logoZ / 2;
  //float rbotcy = logoZ / 2;
  //float rtopcx = logoZ / 2;
  //float rtopcy = -logoZ / 2;
  
  //float rotlbotcx = lbotcx * cos(logoRotation) - lbotcy * sin(logoRotation);
  //float rotlbotcy = lbotcx * sin(logoRotation) - lbotcy * cos(logoRotation);
  //float rotltopcx = ltopcx * cos(logoRotation) - ltopcy * sin(logoRotation);
  //float rotltopcy = ltopcx * sin(logoRotation) - ltopcy * cos(logoRotation);
  //float rotrbotcx = rbotcx * cos(logoRotation) - rbotcy * sin(logoRotation);
  //float rotrbotcy = rbotcx * sin(logoRotation) - rbotcy * cos(logoRotation);
  //float rotrtopcx = rtopcx * cos(logoRotation) - rtopcy * sin(logoRotation);
  //float rotrtopcy = rtopcx * sin(logoRotation) - rtopcy * cos(logoRotation);

  //lbotcx = rotlbotcx + logoX;
  //lbotcy = rotlbotcy + logoY;
  //ltopcx = rotltopcx + logoX;
  //ltopcy = rotltopcy + logoY;
  //rbotcx = rotrbotcx + logoX;
  //rbotcy = rotrbotcy + logoY;
  //rtopcx = rotrtopcx + logoX;
  //rtopcy = rotrtopcy + logoY;
  
  //float margin = inchToPix(.1f);
  //if (dist(lbotcx, lbotcy, mouseX, mouseY) < margin) {
  //  fill(244, 60, 20);
  //  circle(lbotcx, lbotcy, 2 * margin);
  //}
  //else if (dist(ltopcx, ltopcy, mouseX, mouseY) < margin) {
  //  fill(244, 60, 20);
  //  circle(ltopcx, ltopcy, 2 * margin);
  //}
  //else if (dist(rbotcx, rbotcy, mouseX, mouseY) < margin) {
  //  fill(244, 60, 20);
  //  circle(rbotcx, rbotcy, 2 * margin);
  //}
  //else if (dist(rtopcx, rtopcy, mouseX, mouseY) < margin) {
  //  fill(244, 60, 20);
  //  circle(rtopcx, rtopcy, 2 * margin);
  //}
}

void drawArrow(int cx, int cy, int len, float angle){
  pushMatrix();
  translate(cx, cy);
  rotate(radians(angle));
  line(0,0,len, 0);
  line(len, 0, len - 8, -8);
  line(len, 0, len - 8, 8);
  popMatrix();
}

void scaffoldControlLogic()
{
  fill(255);
  //upper left corner, rotate counterclockwise
  //text("CCW", inchToPix(.4f), inchToPix(.4f));
  //if (mousePressed && dist(0, 0, mouseX, mouseY)<inchToPix(.8f))
  //  logoRotation--;

  //upper right corner, rotate clockwise
  //text("CW", width-inchToPix(.4f), inchToPix(.4f));
  //if (mousePressed && dist(width, 0, mouseX, mouseY)<inchToPix(.8f))
  //  logoRotation++;

  //decrease Z
  //fill(100);
  //rect(width-100, 45, 35, 35, 20);
  //fill(255);
  //text("-", width-100, 50);
  //if (mousePressed && dist(width-100, 45, mouseX, mouseY)<inchToPix(.5f))
  //  logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!

  //increase Z
  //fill(100);
  //rect(width-50, 45, 35, 35, 20);
  //fill(255);
  //text("+", width-50, 53);
  //if (mousePressed && dist(width-50, 48, mouseX, mouseY)<inchToPix(.5f))
  //  logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone! 
  
  //submit button
  //fill(60, 148, 56); 
  //rect(width/2, inchToPix(.4f)-7, 115, 65, 20);
  //fill(255);
  //text("submit", width/2, inchToPix(.4f));
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  color c = get(mouseX, mouseY);
  //println(red(c));
  //println(blue(c));
  //println(green(c));
  if (red(c) == blue(c) && blue(c) == green(c)) {
    isRotating = true;
  //} else if (red(c) == 244 && green(c) == 60 && blue(c) == 20) {
  //  isResizing = true;
  } else {
    isDragging = true;
  }
}

void mouseReleased()
{
  //check to see if user clicked submit button
  //if (dist(width/2, inchToPix(.4f), mouseX, mouseY) < inchToPix(0.7f))
  if (checkForSuccess() && dist(targetX, targetY, mouseX, mouseY) < inchToPix(0.5f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
  isDragging = false;
  isRotating = false;
  //isResizing = false;
}

void mouseDragged() {
  if (isDragging) {
    logoX += mouseX - pmouseX; 
    logoY += mouseY - pmouseY;
  //} else if (isResizing) {
  //  float diff = dist(mouseX, mouseY, logoX, logoY) - dist(pmouseX, pmouseY, logoX, logoY);
  //  logoZ = constrain(logoZ + diff, .01, inchToPix(4f));
  } else if (isRotating) {
    float x1 = pmouseX - logoX;
    float y1 = pmouseY - logoY;
    float x2 = mouseX - logoX;
    float y2 = mouseY - logoY;
    float d1 = sqrt(x1 * x1 + y1 * y1);
    float d2 = sqrt(x2 * x2 + y2 * y2);
    float rot = asin((x1 / d1) * (y2 / d2) - (y1 / d1) * (x2 / d2));
    logoRotation += rot * 50;
    
    // change size
    float d = dist(mouseX, mouseY, logoX, logoY);
    logoZ = d;
  }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  if (trialIndex < destinations.size()) {
    Destination d = destinations.get(trialIndex);  
    closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
    closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
    closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"  
  
    //println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
    //println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
    //println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
    //println("Close enough all: " + (closeDist && closeRotation && closeZ));
  }

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
