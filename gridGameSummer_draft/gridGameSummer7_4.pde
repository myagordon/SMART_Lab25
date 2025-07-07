import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress remoteAddress;

int gridRows = 2;
int gridCols = 2;
int cellSize = 40;
Grid grid;
User user;
OSCSend sendingOSC; // Declare OSCSend for handling OSC messages
OSCReceiveClass receivingOSC; //NEW

void setup() {
  size(400, 400);
  grid = new Grid(gridRows, gridCols, cellSize);
  user = new User();
  
  // Initialize OSC for receiving and remote address for sending
  oscP5 = new OscP5(this, 6800); // Set up OSC to listen on port 6800
  remoteAddress = new NetAddress("127.0.0.1", 8100); // Target address for OSC messages
  
  sendingOSC = new OSCSend(); // Initialize the OSCSend instance
  receivingOSC = new OSCReceiveClass(); // NEW
}

void draw() {
  background(255);
  grid.display();
  user.display();
}

void keyPressed() {
  if (key == 'w' || key == 'W') {
    user.move(0, -1);  // Move up
  } else if (key == 's' || key == 'S') {
    user.move(0, 1);   // Move down
  } else if (key == 'a' || key == 'A') {
    user.move(-1, 0);  // Move left
  } else if (key == 'd' || key == 'D') {
    user.move(1, 0);   // Move right
  }
  
  sendingOSC.sendOSC();  
}
