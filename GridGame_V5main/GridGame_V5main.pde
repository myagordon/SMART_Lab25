//file: main.pde

//main game manager instance
GameManager game;

//helper to get current game state
State getState() {
  return game != null ? game.state : State.INTRO;
}

//setup initializes the game
void setup() {
  fullScreen();
  game = new GameManager(this); //create new GameManager object
  game.setup();
}

void draw() {
  game.update(); //update game logic
  game.render(); //update game visuals
}

//handles key pressed input
void keyPressed() {
  game.handleKey(key, keyCode);
}


//handles key released input
void keyReleased() {
  game.handleKeyRelease(key, keyCode);
}
