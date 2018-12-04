import dynamixel.*;
import processing.serial.*;

Serial port;

// default servo position: move up
int position = 2047;
// servo IDs to control
int[] servoIDs = {21, 22, 23, 24, 25, 26};    //{9, 10, 11, 12, 13, 14},{21, 22, 23, 24, 25, 26}

ArrayList<Stick> sticks = new ArrayList<Stick>();
int num = 6;
float space = 50;  // for x
float offset = (width+space*(num-1))/2;  // initialise x
float minAngle = radians(-105);
float maxAngle = radians(-75);


void setup() {
  size(600, 600);
  // try open to open serial port 
  try {
    // print serial ports
    println(Serial.list());
    // initialize the serial port using the port name (e.g. /dev/tty.usbserial* on OSX, COM# on Windows, etc.) 
    // and baud rate (1M in this case)
    port  = new Serial(this, "/dev/tty.usbserial-FT2H2ZCB", 1000000);  // FT2GZFM6,FT2H2ZCB(90dg)
  }
  // handle any error (e.g. port is not connected to computer, busy (used by another software), etc.
  catch(Exception e) {
    println("error opening serial port: " + e.getMessage());
    // print the error details
    e.printStackTrace();
  }


  for (int i=0; i<num; i++) {
    float startAngle = maxAngle;
    if (i%2==1) {
      startAngle = minAngle;
    }
    sticks.add(new Stick(new PVector(offset+i*space, height/2), startAngle, servoIDs[i]));
  }
}


void draw() {
  background(255);
  stroke(0);
  
  for (Stick s : sticks) {
    s.update();
    s.draw();
  }
}

class Stick {
  PVector pos;
  float angle;
  float vel = 0.01;
  float len = 50;
  int step;
  
  XH430 servo;

  Stick(PVector pos, float angle, int _servoID) {
    this.pos = pos;
    this.angle = angle;
    servo = new XH430(port, _servoID);
    // enable torque
    servo.setTorque(true);
    // set default position
    servo.setGoalPosition(position);
  }

  void update() {
    if (angle<=minAngle || angle>=maxAngle) {
      vel = -vel;
    }
    angle += vel;
    
    angle = constrain(angle, minAngle, maxAngle);
    step = int(map(degrees(-angle), 0, 180, 1024, 3072));
    servo.setGoalPosition(step);
  }

  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    fill(0);
    text(step, -20, 50);
    rotate(angle-PI*0.5);
    line(0, 0, 0, len);
    popMatrix();
  }
}
