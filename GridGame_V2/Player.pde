class Player {
  int id, x, y; //player ID and position
  color col; //player color
  char U, L, D, R; //movement keys (WASD)
  int Ku, Kl, Kd, Kr; //special movement keys (e.g. arrow keys), currently not used

  //ctor using WASD keys
  Player(int id, int x, int y, char U, char L, char D, char R) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.U = U; this.L = L; this.D = D; this.R = R;
    this.col = id == 0 ? color(0, 200, 255) : color(255, 100, 100);
  }

  //ctor using keyCodes
  Player(int id, int x, int y, int Ku, int Kl, int Kd, int Kr) {
    this(id, x, y, ' ', ' ', ' ', ' ');
    this.Ku = Ku; this.Kl = Kl; this.Kd = Kd; this.Kr = Kr;
  }

  //move player based on input
  void move(InputHandler input, BoardManager board) {
    int dx = 0, dy = 0;
    if (id == 0) { //WASD keys
      if (input.isPressed((int) Character.toLowerCase(U))) dy = -1;
      if (input.isPressed((int) Character.toLowerCase(D))) dy = 1;
      if (input.isPressed((int) Character.toLowerCase(L))) dx = -1;
      if (input.isPressed((int) Character.toLowerCase(R))) dx = 1;
    } else { //arrow keys or other
      if (input.isPressed(Ku)) dy = -1;
      if (input.isPressed(Kd)) dy = 1;
      if (input.isPressed(Kl)) dx = -1;
      if (input.isPressed(Kr)) dx = 1;
    }
    //constrain player to defined grid
    int nx = constrain(x + dx, 0, board.board.length - 1);
    int ny = constrain(y + dy, 0, board.board[0].length - 1);
    if (!board.board[nx][ny].hole) {
      x = nx;
      y = ny;
    if (board.board[x][y].milestone) board.board[x][y].visited = true; //milestone achieved
    }
  }

  //draw tile 
  void draw(ProjectionMapper map, int tileSize) {
    PVector pos = map.tileToScreen(x, y);
    fill(col);
    ellipse(pos.x + tileSize / 2, pos.y + tileSize / 2, tileSize * 0.6, tileSize * 0.6);
  }
}
