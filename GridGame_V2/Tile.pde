//file: Tile.pde
class Tile {
  int x, y; //tile posn
  boolean hole = false; //is tile a hole/trap
  boolean milestone = false; //is tile a milestone
  boolean visited = false; //has player visited tile

  Tile(int x, int y, boolean hole) {
    this.x = x; this.y = y; this.hole = hole; 
  }

  //draw tile
  void draw(ProjectionMapper map, int tileSize) {
    PVector pos = map.tileToScreen(x, y);
    if (hole) fill(30); // trap is indicated by dark color
    else if (milestone) fill(240, 200, 0); //milestone is yellow
    else fill(200); //normal tile is grey
    rect(pos.x, pos.y, tileSize, tileSize);
  }
}
