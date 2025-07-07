class Grid {
  int rows;
  int cols;
  int cellSize;
  int offsetX;
  int offsetY;
  Cell[][] cells;

  Grid(int r, int c, int cs) {
    rows = r;
    cols = c;
    cellSize = cs;
    cells = new Cell[rows][cols];

    offsetX = (width - cols * cellSize) / 2;  // X offset to center grid
    offsetY = (height - rows * cellSize) / 2; // Y offset to center grid

    int currentNumber = 0;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        float x = offsetX + j * cellSize;
        float y = offsetY + i * cellSize;
        cells[i][j] = new Cell(x, y, cellSize, currentNumber++, i, j);
      }
    }

    // Randomly select two unique cells to "glitch"
    int glitchCount = 0;
    while (glitchCount < 2) {
      int randomRow = (int) random(rows);
      int randomCol = (int) random(cols);
      Cell cell = cells[randomRow][randomCol];
      if (!cell.isGlitching) {
        cell.enableGlitching();
        println("Cell at row " + randomRow + " and column " + randomCol + " is glitching");
        glitchCount++;
      }
    }
  }

  void display() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        cells[i][j].display();
      }
    }
  }
}
