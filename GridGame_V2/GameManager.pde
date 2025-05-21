//file: GameManager.pde

enum State { INTRO, PLAYING, WIN, LOSE } //enum for current game state

class GameManager {
  State state = State.INTRO; //init game to intro state
  GameConfig config;
  PlayerManager playerManager;
  BoardManager boardManager;
  InputHandler inputHandler;
  Renderer renderer;
  ProjectionMapper projectionMapper;
  CameraCapture camera;

  int round = 1; //init round number
  int roundStart; //time round started
  PApplet parent;

  GameManager(PApplet parent) {
    this.parent = parent;
    config = new GameConfig();
    boardManager = new BoardManager(config);
    inputHandler = new InputHandler();
    playerManager = new PlayerManager(config, inputHandler);
    projectionMapper = new ProjectionMapper(config);
    renderer = new Renderer(config, boardManager, playerManager, projectionMapper);
    camera = new CameraCapture(config, parent);
  }

  //setup game paramters
  void setup() {
    camera.initCamera();
    frameRate(config.fps);
    textAlign(CENTER, CENTER);
    roundStart = millis();
  }

  //update game logic each frame
  void update() {
    camera.update();
    if (state != State.PLAYING) return;

    if (playerManager.allObjectivesCompleted(boardManager, config)) {
      state = State.WIN;
      return;
    }

    if (millis() - roundStart > config.roundDuration) {
      nextRound();
    }

    playerManager.update(boardManager);
  }

  //render game elements each frame
  void render() {
    switch (state) {
      case INTRO:
        drawIntro(); return;
      case WIN:
        drawWin(); return;
      case LOSE:
        drawLose(); return;
    }

    background(25);
    renderer.draw();
    drawHUD(); //display time left in round and current level
    camera.drawCamera();
  }

  //handle key press
  void handleKey(char key, int keyCode) {
    if (state == State.INTRO && key == ' ') {
      round = 1;
      roundStart = millis();
      boardManager.generateBoard();
      playerManager.resetPlayers();
      state = State.PLAYING;
      return;
    }

    if (state == State.WIN || state == State.LOSE) return;

    inputHandler.handleKey(keyCode, true);
  }

  //handle key release
  void handleKeyRelease(char key, int keyCode) {
    inputHandler.handleKey(keyCode, false);
  }

  //move to next round or lose logic
  void nextRound() {
    round++;
    if (round > config.maxRounds) {
      state = State.LOSE;
      return;
    }
    roundStart = millis();
    boardManager.generateBoard();
    playerManager.resetPlayers();
  }

  //draw HUD info in top right corner, may have to adjust size of text down the road
  void drawHUD() {
    fill(255);
    textSize(40);
    textAlign(RIGHT, TOP);
    text("Round: " + round + " / " + config.maxRounds, width - 40, 40);
    int timeLeft = max(0, config.roundDuration - (millis() - roundStart)) / 1000;
    text("Time Left: " + timeLeft + "s", width - 40, 100);
  }

  //draw intro slide
  void drawIntro() {
    background(0);
    fill(255);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("Welcome to the Grid Game", width / 2, height * 0.3);
    textSize(24);
    text("Use WASD to move. Avoid the traps.", width / 2, height * 0.4);
    text("There are 3 rounds. The goal of each round is to visit all milestones before reaching the center tile (bell).", width / 2, height * 0.45);
    text("Press SPACE to begin", width / 2, height * 0.6);
  }

  //draw win slide
  void drawWin() {
    background(0);
    fill(0, 255, 0);
    textSize(40);
    textAlign(CENTER, CENTER);
    text("You Win!", width / 2, height / 2);
  }

  //draw lose slide
  void drawLose() {
    background(0);
    fill(255, 0, 0);
    textSize(40);
    textAlign(CENTER, CENTER);
    text("Game Over. Try Again!", width / 2, height / 2);
  }
}
