//file: ProjectionMapper.pde
//I included this in case we end up using projection mapping to display/update grid
class ProjectionMapper {
  GameConfig config;

  ProjectionMapper(GameConfig config) {
    this.config = config;
  }

  //convert tile position to screen coordinates
  PVector tileToScreen(int x, int y) {
    float tileW = width / float(config.gridSize);
    float tileH = height / float(config.gridSize);
    return new PVector(x * tileW, y * tileH); //project PVector
  }
}
