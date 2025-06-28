//file: GameConfig.pde
class GameConfig {
  int gridSize = 5; //num of tiles per row/column
  int fps = 30; //target frames per second
  int roundDuration = 300000; //duration of each round in ms, currently 5 mins
  int maxRounds = 3; // max num of rounds
  int tileSize = 80; //size of each tile in pixels
  ArrayList<PVector> milestoneTiles = new ArrayList<PVector>(); //goal tiles
  int centerX; 
  int centerY;
  String[] attributeNames = { "Service", "Research", "Teaching" }; //can change these names down the line
  color[] attributeColors = {
    color(0, 200, 0),   // Service is green
    color(0, 100, 255), // Research is blue
    color(150, 0, 200)  // Teaching is purple
  };

  GameConfig() {
    milestoneTiles.add(new PVector(1, 1));
    milestoneTiles.add(new PVector(4, 2)); //adjust to size of grid
    centerX = gridSize / 2;
    centerY = gridSize / 2;
  }
}
