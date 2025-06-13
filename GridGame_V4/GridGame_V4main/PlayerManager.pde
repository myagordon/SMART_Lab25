//file: PlayerManager.pde

UDPSocketReceiver udp; //udp socket for reading in player position (x,y) 
int lastTileX = 0, lastTileY = 0;
int lastUpdateTime = 0;
int updateInterval = 2000; // updates player posn every 2 secs


class PlayerManager {
  GameConfig config;
  InputHandler inputHandler;
  Player[] players; //array of players, currently supports 1 player, this can be adjusted

  PlayerManager(GameConfig config, InputHandler inputHandler) {
    this.config = config;
    this.inputHandler = inputHandler;
    resetPlayers();
    udp = new UDPSocketReceiver(); //new udp socket obj
    udp.start();
  }

  //create/reset players
  void resetPlayers() {
    // For now, only one player
    players = new Player[1];
    players[0] = new Player(0, config.gridSize / 2, config.gridSize - 1, 'w', 'a', 's', 'd');
  }

  //update all players
  void update(BoardManager board) {
    handleUDPInput(board); // call UDP update logic
    for (Player p : players) p.move(inputHandler, board); //still accepts keyboard input, can remove this 
  }

  //draw all players
  void draw(ProjectionMapper map, int tileSize) {
    for (Player p : players) p.draw(map, tileSize);
  }
  
  //check if all milestones are visited and player is at center
  boolean allObjectivesCompleted(BoardManager board, GameConfig config) {
  for (Tile[] col : board.board) {
    for (Tile t : col) {
      if (t.milestone && !t.visited) return false;
    }
  }
  Player p = players[0];
  return p.x == config.centerX && p.y == config.centerY;
}

  void handleUDPInput(BoardManager board) { //receives and formats incoming udp posn data
    if (millis() - lastUpdateTime < updateInterval) return;
  
    String message = udp.getLatestMessage();
    if (message == null || message.equals(" no data ")) return;
  
    String[] coords = split(trim(message), ",");
    if (coords.length != 2) return;
  
    try {
      int tileX = int(coords[0]); //left right movement
      int tileY = int(coords[1]); //forwards backwards movement
  
      if (tileX != lastTileX || tileY != lastTileY) {
        Player p = players[0];
        p.x = constrain(tileX, 0, config.gridSize - 1); //constrain player to the dimensions of the grid
        p.y = constrain(tileY, 0, config.gridSize - 1);
        lastTileX = tileX;
        lastTileY = tileY;
        if (board.board[p.x][p.y].milestone) {
          board.board[p.x][p.y].visited = true;
        }
      }
  
      lastUpdateTime = millis();
    } catch (Exception e) {
      println("Invalid UDP data: " + message);
    }
  }


}
