//file: Tile.pde
class Tile {
  int x, y; //tile posn
  boolean hole = false; //is tile a hole/trap
  boolean milestone = false; //is tile a milestone
  boolean visited = false; //has player visited tile
  int objectiveType = -1; // -1 = normal tile, 0 = service, 1 = research, 2 = teaching

  Tile(int x, int y, boolean hole) {
    this.x = x; this.y = y; this.hole = hole;
    if (!hole && random(1) < 0.1) { // 10% chance of being an objective
      objectiveType = int(random(3)); // 0, 1, or 2
    }
  }

  //draw tile
  void draw(int tileSize) {
    if (hole) {
      fill(30); //fill grey
    } else if (objectiveType >= 0) { //color blocks
      fill(game.config.attributeColors[objectiveType]);
    } else {
      fill(200);
    }
    float tileW = width / float(game.config.gridSize);
    float tileH = height / float(game.config.gridSize);
    rect(x * tileW, y * tileH, tileW, tileH); 
  }
}
