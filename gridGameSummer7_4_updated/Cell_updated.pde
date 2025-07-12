class Cell {
  float x, y;
  int size;
  int number;
  int row, col;
  boolean isGlitching = false;
  boolean isUserHere = false;  // Variable to check if the user is on this cell

  Cell(float x, float y, int size, int number, int row, int col) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.number = number;
    this.row = row;
    this.col = col;
  }

  void enableGlitching() {
    isGlitching = true;
  }

  void display() {
    if (isGlitching) {
      fill(random(255), random(255), random(255)); // Random color for glitching effect
    } else {
      fill(255);  // White fill for non-glitching cells
    }
    stroke(0);  // Black stroke for grid lines
    rect(x, y, size, size);

    // Draw the number and whether the user is here
    fill(0);  // Black text color for number and status
    textAlign(CENTER, CENTER);
    text(number + "\n" + (isUserHere ? "1" : "0"), x + size / 2, y + size / 2); // Display number and user presence
  }
}
