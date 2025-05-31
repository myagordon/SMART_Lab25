//file: CameraCapture.pde
class CameraCapture {
  GameConfig config;
  PApplet parent;
  Capture cam;
  OpenCV cv;
  Rectangle lastFace; //most recently detected face

  CameraCapture(GameConfig config, PApplet parent) {
    this.config = config;
    this.parent = parent;
  }

  //init camera and face detection
  void initCamera() {
    cam = new Capture(parent, parent.width, parent.height);
    cv = new OpenCV(parent, parent.width, parent.height);
    cv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
    cam.start();
  }

  //update camera and face detection
  void update() {
    if (cam.available()) {
      cam.read();
      cv.loadImage(cam);
      Rectangle[] faces = cv.detect();
      if (faces.length > 0) {
        lastFace = faces[0]; //keep largest face
        for (Rectangle f : faces) {
          if (f.width * f.height > lastFace.width * lastFace.height) lastFace = f;
        }
      } else { //if no face detected
        lastFace = null;
      }
    }
  }

  //draw camera feed and face rectangle
  void drawCamera() {
    if (cam != null) {
      image(cam, 0, 0, 160, 120);
      if (lastFace != null) {
        noFill();
        stroke(0, 255, 0);
        rect(map(lastFace.x, 0, cam.width, 0, 160),
             map(lastFace.y, 0, cam.height, 0, 120),
             map(lastFace.width, 0, cam.width, 0, 160),
             map(lastFace.height, 0, cam.height, 0, 120));
      }
    }
  }
}
