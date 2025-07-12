class User {
  int currentRow = 0;
  int currentCol = 0;

  User() {
    grid.cells[currentRow][currentCol].isUserHere = true;  // Initialize the starting cell's user status
  }

  void move(int dx, int dy) {
    int newRow = currentRow + dy;
    int newCol = currentCol + dx;

    // Check boundaries
    if (newRow >= 0 && newRow < gridRows && newCol >= 0 && newCol < gridCols) {
      grid.cells[currentRow][currentCol].isUserHere = false;  // Set current cell to false
      currentRow = newRow;
      currentCol = newCol;
      grid.cells[currentRow][currentCol].isUserHere = true;  // Set new cell to true
      printCurrentPosition();
      //sendOSCMessage();
    }
  }

  void display() {
    float x = grid.cells[currentRow][currentCol].x + cellSize / 2;
    float y = grid.cells[currentRow][currentCol].y + cellSize / 2;
    fill(255, 0, 0, 10);  // Red fill for the user circle
    stroke(255, 0, 0);
    ellipse(x, y, cellSize / 2, cellSize / 2);
  }

  void printCurrentPosition() {
    int cellIndex = grid.cells[currentRow][currentCol].number;
    println("User is on cell at row " + currentRow + ", column " + currentCol + " (" + cellIndex + ") ");
  }


  
  //  void sendOSCMessage() {
  //  int cellIndex = grid.cells[currentRow][currentCol].number;
  //  sendingOSC.sendPosition(currentRow, currentCol, cellIndex);
  //}
}
