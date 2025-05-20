import gab.opencv.*;
import processing.video.*;
import java.awt.*;

final int GRID=8, FPS=30, COUNTDOWN=2, SLIDE_MS=3000, ROUND_MS=20000;
final float MAX_HOLE = 0.4;
final int CENTER_X = 3;
final int CENTER_Y = 3;

Capture cam; OpenCV cv;
PImage[] face=new PImage[2];

int phase=0, round=1, maxRounds=3;
String[] role=new String[2]; int[] pts={0,0};

Tile[][] board; Player[] ply;
int tile, slideStart, roundStart, nextShuffle, nextSetback;
boolean showLines=true;

/* capture FSM */
int capState, stable,lost,tStart; Rectangle lastF;
final int NEED=6, GRACE=4;

/* ───────── setup ───────── */
void setup(){
  fullScreen(); frameRate(FPS); tile=height/GRID;
  cam=new Capture(this,width,height);
  cv=new OpenCV(this,width,height); cv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  cam.start();
  textAlign(CENTER,CENTER); textSize(24);
  newBoard(); newPlayers();
}

/* ───────── main loop ───────── */
void draw(){
  background(25);
  if     (phase==0) capture();
  else if(phase==1) introSlide();
  else if(phase==2) play();
  else              finalSlide();
}

/* ───────── capture phase ───────── */
void capture(){
  if(cam.available()) cam.read();
  cv.loadImage(cam); image(cam,0,0);

  Rectangle f=biggest(cv.detect());
  if(f!=null){ lastF=f; stable++; lost=0; } else { stable=0; if(capState==1) lost++; }

  fill(255); text("Capture – Player "+(face[0]==null?1:2),width/2,40);

  switch(capState){
    case 0:
      if(stable>=NEED){ tStart=millis(); capState=1; }
      else text("Stand in view",width/2,80);
      break;
    case 1:
      if(lost>GRACE){ capState=0; break; }
      noFill(); stroke(0,255,0); strokeWeight(3);
      rect(lastF.x,lastF.y,lastF.width,lastF.height);
      int s=COUNTDOWN-(millis()-tStart)/1000;
      textSize(64); text(s+1,width/2,height/2); textSize(24);
      if(s<0){
        face[face[0]==null?0:1]=cam.get(lastF.x,lastF.y,lastF.width,lastF.height);
        capState=2;
      }
      break;
    case 2:
      text("Photo saved – step away",width/2,height-60);
      if(f==null){
        if(face[1]!=null){ assignRoles(); slideStart=millis(); phase=1; }
        else capState=0;
      }
  }
}
Rectangle biggest(Rectangle[] a){ if(a.length==0)return null; Rectangle b=a[0];
  for(Rectangle r:a) if(r.width*r.height>b.width*b.height) b=r; return b; }

/* ───────── intro slide ───────── */
void introSlide(){
  background(20); fill(255);
  textSize(36); text("ROUND "+round+" / "+maxRounds,width/2,height*0.12);
  image(face[0],width*0.25-40,height*0.30,80,80);
  image(face[1],width*0.75-40,height*0.30,80,80);
  textSize(28); text("P1 is "+role[0],width*0.25,height*0.30+110);
  text("P2 is "+role[1],width*0.75,height*0.30+110);
  textSize(24);
  text("Reach the center tile (3,3) to win!", width/2, height*0.65);
  text("Pawn – 1 square forward  |  King – 1 square any dir.",width/2,height*0.72);
  text("SPACE or wait…",width/2,height*0.85);
  if(millis()-slideStart>SLIDE_MS) startRound();
}
void keyPressed(){ if(phase==1&&key==' ') startRound();
                   else if(phase==2) for(Player p:ply)
                     if(p.move(key,keyCode,role[p.id])) checkGoal(p); }

void startRound(){
  phase=2; roundStart=millis();
  nextShuffle=millis()+1000; nextSetback=millis()+3000;
}

/* ───────── gameplay ───────── */
void play(){
  if(millis()-roundStart>ROUND_MS){ autoAdvance(); return; }

  if(millis()>nextShuffle){
    shuffle(); nextShuffle=millis()+max(300,1000-200*round);
  }

  if(millis()>nextSetback){
    for(int i=0;i<2;i++) if(role[i].equals("Pawn") && random(1)<0.3) ply[i].forceBack();
    nextSetback=millis()+3000;
  }

  drawBoard(); for(Player p:ply) p.draw(); hud();
}

void autoAdvance(){
  round++; if(round>maxRounds){ phase=3; slideStart=millis(); return; }
  newBoard(); newPlayers(); assignRoles(); slideStart=millis(); phase=1;
}

/* no longer care about top/bottom row for winning
void checkGoal(Player p){
  if((p.id==0&&p.y==0)||(p.id==1&&p.y==GRID-1)){
    pts[p.id]+= role[p.id].equals("King")?3:5;
    round++; if(round>maxRounds){ phase=3; slideStart=millis(); }
    else{ newBoard(); newPlayers(); assignRoles(); slideStart=millis(); phase=1; }
  }
}
*/
boolean allMilestonesDone(int playerID) {
  for(int xx=0; xx<GRID; xx++){
    for(int yy=0; yy<GRID; yy++){
      // If it's a milestone and not completed by this player
      if (board[xx][yy].milestone && !board[xx][yy].completed[playerID]) {
        return false;
      }
    }
  }
  return true;
} 

void checkGoal(Player p) {
  // If the player stands on the center tile
  if (p.x == CENTER_X && p.y == CENTER_Y) {

    // Check if they've done all milestones
    if (!allMilestonesDone(p.id)) {
      // They haven't completed their required tasks, so block them
      println("Player "+(p.id+1)+" hasn't completed all milestones yet!");
      return; 
    }

    // Otherwise, they can win
    if (role[p.id].equals("King")) pts[p.id] += 3;
    else                           pts[p.id] += 5;

    // End game
    phase = 3;        
    slideStart = millis();
  }
}


/* ───────── final slide ───────── */
void finalSlide(){
  background(10); fill(255);
  textSize(40); text("GAME OVER",width/2,height*0.2);
  textSize(28);
  text("Player 1 score: "+pts[0],width/2,height*0.4);
  text("Player 2 score: "+pts[1],width/2,height*0.48);
  String w = pts[0]==pts[1] ? "It's a tie!" : (pts[0]>pts[1]?"Player 1 wins!":"Player 2 wins!");
  textSize(36); text(w,width/2,height*0.65);
}

/* ───────── board helpers ───────── */
void newBoard(){
  board = new Tile[GRID][GRID];
  float pr = min(0.07*round, MAX_HOLE);

  // Create normal tiles
  for(int x=0; x<GRID; x++){
    for(int y=0; y<GRID; y++){
      board[x][y] = new Tile(x, y, random(1) < pr);
    }
  }
  showLines = true;

  // EXAMPLE: define 2 milestone tiles (could randomize these as well)
  board[1][1].milestone = true;
  board[5][2].milestone = true;
}

void shuffle(){
  int x=int(random(GRID)), y=int(random(GRID));
  board[x][y].hole=!board[x][y].hole;
  showLines = random(1)<0.6;
}
void newPlayers(){
  ply=new Player[2];
  ply[0]=new Player(0,GRID/2,GRID-1,'w','a','s','d');
  ply[1]=new Player(1,GRID/2,0,   UP,LEFT,DOWN,RIGHT);
}
void assignRoles(){ if(random(1)<0.5){role[0]="King";role[1]="Pawn";}
                    else              {role[0]="Pawn";role[1]="King";} }

/* ───────── drawing ───────── */
void drawBoard(){
  if(showLines) stroke(80); else noStroke();
  for(Tile[] col:board) for(Tile t:col) t.draw();
}
void hud(){
  fill(255); textAlign(LEFT,CENTER);
  image(face[0],width-220,20,70,70);   text("P1 "+role[0]+": "+pts[0],width-140,55);
  image(face[1],width-220,110,70,70);  text("P2 "+role[1]+": "+pts[1],width-140,145);
}

/* ───────── classes ───────── */
class Tile {
  int x, y;
  boolean hole;
  
  // NEW: milestone info
  boolean milestone;
  boolean[] completed = new boolean[2]; // completed[0] => Player1, [1] => Player2

  Tile(int x,int y,boolean h){
    this.x = x;
    this.y = y;
    hole   = h;
    milestone = false; // default false, set true as needed
    completed[0] = false;
    completed[1] = false;
  }

  void draw(){
    if (hole) {
      fill(30);
    } else if (milestone) {
      // visually highlight milestone tiles
      fill( color(240,200,0) ); // yellowish
    } else {
      fill(200);
    }
    rect(x*tile, y*tile, tile, tile);
  }
}


class Player{
  int id,x,y; color c; char U,L,D,R; int Ku,Kl,Kd,Kr;
  Player(int id,int sx,int sy,char u,char l,char d,char r){
    this.id=id; x=sx; y=sy; c=id==0?color(0,200,255):color(255,100,100);
    U=u;L=l;D=d;R=r;
  }
  Player(int id,int sx,int sy,int ku,int kl,int kd,int kr){
    this(id,sx,sy,' ',' ',' ',' '); Ku=ku;Kl=kl;Kd=kd;Kr=kr;
  }

  boolean move(char k,int kc,String r){
    int dx=0,dy=0;
    if(id==0){ k=Character.toLowerCase(k);
      if(k==U)dy=-1; if(k==D)dy=1; if(k==L)dx=-1; if(k==R)dx=1;
    }else{
      if(kc==Ku)dy=-1; if(kc==Kd)dy=1; if(kc==Kl)dx=-1; if(kc==Kr)dx=1;
    }
    if(dx==0&&dy==0) return false;

    if(r.equals("Pawn")){
      if(id==0 && !(dx==0&&dy==-1)) return false;
      if(id==1 && !(dx==0&&dy== 1)) return false;
    }

    int nx=constrain(x+dx,0,GRID-1), ny=constrain(y+dy,0,GRID-1);

    // hit a hole?
    if(board[nx][ny].hole){
      if(r.equals("Pawn")){ pts[id]=max(0,pts[id]-1); }  // deduct 1 point
      return false;
    }

    x=nx; y=ny; 
    
    if (board[x][y].milestone) {
      board[x][y].completed[id] = true;
    }
    
    return true;
  }

  void forceBack(){ if(id==0 && y<GRID-1) y++; if(id==1 && y>0) y--; }

  void draw(){ fill(c); noStroke();
    ellipse(x*tile+tile/2, y*tile+tile/2, tile*0.6,tile*0.6); }
}

/* webcam callback */
void captureEvent(Capture c){ c.read(); }
