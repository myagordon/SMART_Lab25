// file: InputHandler.pde 
//we can eventually remove the keyboard input functionality when we implement the sensors
class MyInputHandler {
  boolean[] keys = new boolean[256]; //tracks regular keys
  boolean[] specials = new boolean[512]; //tracks special keys like arrow keys
  int lastMoveTime = 0; //time last key was allowed to move
  //I added 150ms delay between inputs to decrease keyboard sensitivity

  //update key pressed state
  void handleKey(int keyCode, boolean pressed) {
  if (keyCode >= 'A' && keyCode <= 'Z') {
    keys[Character.toLowerCase((char) keyCode)] = pressed;
  } else if (keyCode < specials.length) {
    specials[keyCode] = pressed;
  }
}

  //check if key is pressed and apply delay
  boolean isPressed(int keyCode) {
    int now = millis();
    if (now - lastMoveTime < 150) return false;
    //referenced https://processing.org/reference/key.html
    boolean pressed = false;
    if (keyCode < 256) {
      pressed = keys[keyCode];
    } else if (keyCode < specials.length) {
      pressed = specials[keyCode];
    }

    //update time of most recent keyboard input
    if (pressed) {
      lastMoveTime = now;
      return true;
    }

    return false;
  }
}
