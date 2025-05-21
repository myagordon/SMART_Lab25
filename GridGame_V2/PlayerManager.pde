//file: PlayerManager.pde
class PlayerManager {
  GameConfig config;
  InputHandler inputHandler;
  Player[] players; //array of players, currently supports 1 player, this can be adjusted

  PlayerManager(GameConfig config, InputHandler inputHandler) {
    this.config = config;
    this.inputHandler = inputHandler;
    resetPlayers();
  }

  //create/reset players
  void resetPlayers() {
    // For now, only one player
    players = new Player[1];
    players[0] = new Player(0, config.gridSize / 2, config.gridSize - 1, 'w', 'a', 's', 'd');
  }

  //update all players
  void update(BoardManager board) {
    for (Player p : players) p.move(inputHandler, board);
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

}
