// automatically called when OSC message is received
void oscEvent(OscMessage msg) {
  receivingOSC.handleOSC(msg);
}

// Global variable for tile length, will need to adjust this based on physical tile size
float tileLength = 1.0; //assuming tile length = tile height
boolean needsCalibration = false; //wait for new round to start

class OSCReceiveClass {
  float sensorX, sensorY;
  
  //convert user (x,y) posn in mm to tile coordinates
  void handleOSC(OscMessage msg) {
    if (msg.checkAddrPattern("/position")) {
      if (msg.checkTypetag("ff")) {
        sensorX = msg.get(0).floatValue();
        sensorY = msg.get(1).floatValue();
        
        // Check if we need to calibrate, mnust do this at start of each new round
        if (needsCalibration) {
          calibrate_to_zero();
          needsCalibration = false;
          println("Player is now at grid corner (0,0) SENSOR CALIBRATED");
        }
        
        // Convert from mm to m, then divide by physical tile length
        //pos x direction is forwards, pos y direction is right from perspective of user
        float posX = (sensorX / 1000.0) / tileLength;
        float posY = (sensorY / 1000.0) / tileLength;
        posX = constrain(posX, 0, gridRows);
        posY = constrain(posY, 0, gridCols);
        int currentTileX = (int)floor(posX);
        int currentTileY = (int)floor(posY);
        
        // Print raw sensor data and converted tile coordinates
        println("Raw sensor (mm): X= " + sensorX + ", Y= " + sensorY);
        println("Tile coordinates: X=" + currentTileX + ", Y=" + currentTileY);
      }
    }
  }
  
  void calibrate_to_zero() {
    //test out grid calibration method here
  }
  
}
