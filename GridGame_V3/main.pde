//file: PlayerManager.pde

class PlayerManager {
  GameConfig config;
  InputHandler inputHandler;
  Player[] players; //array of players, currently supports 1 player, this can be adjusted
  
  int score = 0;
  int gainThreshold = 5; //initial amount of points gained for completing an objective
  int lossThreshold = 5; //initial amount of points lost for hitting an off-limits tile
  
  ThresholdGenerator thresholdGenerator = new ThresholdGenerator(); 

  PlayerManager(GameConfig config, InputHandler inputHandler) {
    this.config = config;
    this.inputHandler = inputHandler;
    resetPlayers();
  }
  

  void updateThresholds(int round) {
    gainThreshold = thresholdGenerator.getGainThreshold(score, round);
    lossThreshold = thresholdGenerator.getLossThreshold(score, round);
    println("Updated thresholds — gain: " + gainThreshold + ", loss: " + lossThreshold);
  }

  //create/reset players
  void resetPlayers() {
    // For now, only one player
    players = new Player[1];
    players[0] = new Player(0, config.gridSize / 2, config.gridSize - 1, 'w', 'a', 's', 'd');
  }

  //update all players
  void update(BoardManager board) {
    for (Player p : players) p.move(inputHandler, board, this);
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
