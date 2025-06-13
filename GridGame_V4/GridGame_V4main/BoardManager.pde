//file BoardManager.pde
class BoardManager {
  GameConfig config; //game config
  Tile[][] board; //2D array of tiles

  BoardManager(GameConfig config) {
    this.config = config;
    generateBoard(); //create init board
  }

  //generate tiles and assign random holes and milestones
  //we can change this down the road if we decide not to make milestones random 
  void generateBoard() {
    board = new Tile[config.gridSize][config.gridSize];
    for (int x = 0; x < config.gridSize; x++) {
      for (int y = 0; y < config.gridSize; y++) {
        board[x][y] = new Tile(x, y, random(1) < 0.1); //10% chance of hole, can adjust difficulty
      }
    }
    for (PVector m : config.milestoneTiles) {
      board[int(m.x)][int(m.y)].milestone = true; //set milestone tiles
    }
  }

  //draw each tile
  void draw(ProjectionMapper map, int tileSize) {
    for (Tile[] col : board) for (Tile t : col) t.draw(map, tileSize);
  }
}
