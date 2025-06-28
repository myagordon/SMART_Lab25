//file: Player.pde
class Player {
  int id, x, y; //player ID and position
  color col; //player color
  char U, L, D, R; //movement keys (WASD)
  int Ku, Kl, Kd, Kr; //special movement keys (e.g. arrow keys), currently not used
  int[] attributes = new int[3]; // Service, Research, Teaching, adapt this
  float health = 1; 
  float confidence = 1;
  float ammo = 1;
  
  void applyObjective(int type) {
    if (type >= 0 && type <= 2) {
      attributes[type]++;
      //updateDerivedStats();
    }
  }

  /* uncomment this once we iron out the game logic
  void updateDerivedStats() {
    int total = attributes[0] + attributes[1] + attributes[2] + 1;
    health = constrain((attributes[0] + attributes[1]) / float(total), 0, 1);
    confidence = constrain((attributes[2] + attributes[1]) / float(total), 0, 1);
    ammo = constrain((attributes[0] + attributes[2]) / float(total), 0, 1);
  }
  */

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
  void move(MyInputHandler input, BoardManager board) {
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
      Tile t = board.board[x][y];
      if (t.objectiveType >= 0 && !t.visited) {
        t.visited = true;
        applyObjective(t.objectiveType);
      }
    if (board.board[x][y].milestone) board.board[x][y].visited = true; //milestone achieved
    }
  }

  //draw tile 
  void draw(int tileSize, GameConfig config) {
    float tileW = width / float(config.gridSize);
    float tileH = height / float(config.gridSize);
    float px = x * tileW + tileW / 2;
    float py = y * tileH + tileH / 2;
    fill(col);
    ellipse(px, py, tileW * 0.6, tileH * 0.6);
  }

}
