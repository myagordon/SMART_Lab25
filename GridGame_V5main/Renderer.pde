// file; Renderer.pde 
class Renderer {
  GameConfig config;
  BoardManager board;
  PlayerManager players;

  //render updated confi, updated board, updated player posn and updated map (for projection mapping)
  Renderer(GameConfig config, BoardManager board, PlayerManager players) {
    this.config = config;
    this.board = board;
    this.players = players;
  }

  //draw board and players
  void draw() {
    board.draw(config.tileSize);
    players.draw(config.tileSize);
    drawGridLines();
    drawPlayerBars(players.players[0]); //draw progress bars
  }
  
  void drawGridLines() {
    stroke(80); // or whatever color you want for the grid
    strokeWeight(1);
    
    float tileW = width / float(config.gridSize);
    float tileH = height / float(config.gridSize);
  
    // Vertical lines
    for (int i = 1; i < config.gridSize; i++) {
      float x = i * tileW;
      line(x, 0, x, height);
    }
  
    // Horizontal lines
    for (int j = 1; j < config.gridSize; j++) {
      float y = j * tileH;
      line(0, y, width, y);
    }
  
    noStroke(); // turn off stroke after drawing lines
}

  //draw 6 progress bars
  void drawPlayerBars(Player p) {
    int margin = 10;
    int barWidth = 20;
    int barLength = 150;
    int spacing = 10;
  
    // Draw attribute bars on left for now
    for (int i = 0; i < 3; i++) {
      float val = p.attributes[i] / 10.0;
      float x = margin;
      float y = margin + i * (barWidth + spacing);
      String label = config.attributeNames[i] + ": " + p.attributes[i];
      drawBar(x, y, val, barLength, barWidth, config.attributeColors[i], label, true);
    }
  
    // Draw derived stat bars on right for now
    String[] derivedNames = { "Health", "Confidence", "Ammo" };
    float[] derivedVals = { p.health, p.confidence, p.ammo };
    color[] derivedColors = { color(255, 0, 0), color(255, 200, 0), color(0, 255, 255) };
  
    for (int i = 0; i < 3; i++) {
      float val = derivedVals[i];
      float x = width - margin - barLength;
      float y = margin + i * (barWidth + spacing);
      String label = derivedNames[i] + ": " + int(val * 100) + "%";
      drawBar(x, y, val, barLength, barWidth, derivedColors[i], label, false);
    }
  }

  //draw bar helper function
  void drawBar(float x, float y, float value, float length, float height, color barColor, String label, boolean labelLeft) {
    fill(barColor);
    rect(x, y, value * length, height);
    fill(255);
    textAlign(LEFT, CENTER);
    float labelX = x + length + 10;
    if (!labelLeft) labelX = x + length + 10; // adjust here if needed
    text(label, labelX, y + height / 2);
  }

}
