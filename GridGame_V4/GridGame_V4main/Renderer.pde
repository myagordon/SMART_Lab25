// file; Renderer.pde 
class Renderer {
  GameConfig config;
  BoardManager board;
  PlayerManager players;
  ProjectionMapper map;

  //render updated confi, updated board, updated player posn and updated map (for projection mapping)
  Renderer(GameConfig config, BoardManager board, PlayerManager players, ProjectionMapper map) {
    this.config = config;
    this.board = board;
    this.players = players;
    this.map = map;
  }

  //draw board and players
  void draw() {
    board.draw(map, config.tileSize);
    players.draw(map, config.tileSize);
  }
}
