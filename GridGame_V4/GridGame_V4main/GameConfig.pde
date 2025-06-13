//file: GameConfig.pde
class GameConfig {
  int gridSize = 8; //num of tiles per row/column
  int fps = 30; //target frames per second
  int roundDuration = 20000; //duration of each round
  int maxRounds = 3; // max num of rounds
  int tileSize = 80; //size of each tile in pixels
  ArrayList<PVector> milestoneTiles = new ArrayList<PVector>(); //goal tiles
  int centerX; 
  int centerY;

  GameConfig() {
    milestoneTiles.add(new PVector(1, 1));
    milestoneTiles.add(new PVector(5, 2));
    centerX = gridSize / 2;
    centerY = gridSize / 2;
  }
}
