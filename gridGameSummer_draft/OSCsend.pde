class OSCSend {
  //void sendPosition(int row, int col, int index) {

  //  //checks if current cell is glitching
  //  boolean isOnGlitchingTile = grid.cells[row][col].isGlitching;
  //  boolean isOnCell = grid.cells[row][col].isUserHere;


  //  OscMessage msg = new OscMessage("/userPosition");
  //  msg.add(row);  // Add the row information
  //  msg.add(col);  // Add the column informatioN


  //  for (int i = 0; i < gridRows; i++) {
  //    for (int j = 0; j < gridCols; j++) {
  //      msg.add(grid.cells[i][j].isUserHere ? 1 : 0);
  //    }
  //  }

  //  //THIS DOESN'T work because it is not updateting it 0 on MAX when I leave the cell
  //  //msg.add(isOnCell ? 1 : 0);  //send 1 if the user is on the cell, 0 if not

  //  msg.add(index);  // Add the cell index information
  //  //msg.add(isOnGlitchingTile ? 1 : 0);  //send 1 if glitching, 0 if not

  //  oscP5.send(msg, remoteAddress);  // Send the OSC message
  //  println("OSC message sent: row=" + row + ", col=" + col + ", index=" + index + ", glitching=" + isOnGlitchingTile);
  //}



  void sendOSC() {
    OscMessage msg = new OscMessage("/cells");
    for (int i = 0; i < grid.rows; i++) {
      for (int j = 0; j < grid.cols; j++) {
        Cell c = grid.cells[i][j];
        msg.add(c.number);                     // index
        msg.add(c.col);                        // col
        msg.add(c.row);                        // row
        msg.add(c.isUserHere ? 1 : 0);         // isUserHere as int
        msg.add(c.isGlitching ? 1 : 0);        // isGlitching as int
      }
    }
    oscP5.send(msg, remoteAddress);
  }
}
