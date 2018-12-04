import dynamixel.*;
import processing.serial.*;

Serial port;

// default servo position: move up
int position = 2047;
// servo IDs to control
int[] servoIDs = {21, 22, 23, 24, 25, 26};

ArrayList<Stick> sticks = new ArrayList<Stick>();
int num = 6;

void setup() {
  size(600, 600);
  // try open to open serial port 
  try {
    // print serial ports
    println(Serial.list());
    // initialize the serial port using the port name (e.g. /dev/tty.usbserial* on OSX, COM# on Windows, etc.) 
    // and baud rate (1M in this case)
    port  = new Serial(this, "/dev/tty.usbserial-FT2GZFM6", 1000000);
  }
  // handle any error (e.g. port is not connected to computer, busy (used by another software), etc.
  catch(Exception e) {
    println("error opening serial port: " + e.getMessage());
    // print the error details
    e.printStackTrace();
  }


  for (int i=0; i<num; i++) {
    sticks.add(new Stick(new PVector(width/num*i+40, height/2), servoIDs[i]));
  }
}


void draw() {
  background(255);
  stroke(0);

  for (Stick s : sticks) {
    s.update(mouseX, mouseY);
    s.draw();
  }
}

class Stick {
  PVector pos, vel;
  float angle;
  float len = 50;
  float lmt = radians(30);
  int step;

  XH430 servo;

  Stick(PVector pos, int _servoID) {
    this.pos = pos;
    servo = new XH430(port, _servoID);
    // enable torque
    servo.setTorque(true);
    // set default position
    servo.setGoalPosition(position);
  }

  void update(float mx, float my) {
    // follow mouse
    angle = atan2(my-pos.y, mx-pos.x);

    angle = constrain(angle, radians(-125), radians(-55));
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
