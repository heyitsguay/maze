// maze2 - Matthew Guay, 01/04/2015
// An iteration on 'maze', hopefully a refinement!
// Procedurally-generated mazes with some other cool things happening.

// TODO:
// x Finish writing Room's constructor (add Rectangles + their Tiles). DONE 2/11/15
// x Write Item code: interface instead of class? DONE 2/15/15
// x Finish Entity code. DONE 2/13/15
// x Finish Player code. DONE 2/17/15
// x Revert colors back to float triplets. DONE 2/14/15
// x Finish LightList code. DONE 2/15/15
// x Finish MazePlan1. DONE 2/15/15
// x Add HUD class. DONE 2/17/15
// x Add Tile initialization after MazePlan1 runs. DONE 2/17/15
// x Get maze2 running! DONE 2/22/15
// - Entity collision.
// x Add key press functions. DONE 2/17/15
// x Add to Entity update code to include Entities in Tile and Chunk entityLists. DONE 2/25/15
// x Fix Entity-Tile collisions. DONE 2/22/15
// x Player textures/animations. DONE 2/25/15

// Some useful constants.
final float ISQRT2 = 1 / sqrt(2);
final float SQRT2 = sqrt(2);

int TILE_SIZE = 64; // Size of each Tile in pixels.
int CHUNK_SIZE = 32; // 32x32 Tiles in a Chunk.
int CHUNKSX = 20;
int CHUNKSY = 12;

int tilesX = CHUNKSX * CHUNK_SIZE;
int tilesY = CHUNKSY * CHUNK_SIZE;
int chunkPix = CHUNK_SIZE * TILE_SIZE;

// Size of the World, in pixels.
int pixWidth = CHUNKSX * CHUNK_SIZE * TILE_SIZE;
int pixHeight = CHUNKSY * CHUNK_SIZE * TILE_SIZE;

// Maximum number of Tiles potentially on the screen at once.
int tilesOnScreenX;// = (int)(width / TILE_SIZE) + 2;
int tilesOnScreenY;// = (int)(height / TILE_SIZE) + 2;

// Maximum number of Chunks potentially on the screen at once.
int chunkDrawRadiusX;
int chunkDrawRadiusY;

// Screen position within the maze is calculated relative to the
// upper-left hand corner of the window. maxScreenX, maxScreenY
// give the coordinates for the largest value this anchor point 
// can take.
int maxScreenX = pixWidth - width;
int maxScreenY = pixHeight - height;

// (x,y) World coordinates of the top-left corner of the window.
float screenX = 0.;
float screenY = 0.;

// Tile array containing all the Tiles in the game.
Tile[][] tiles;

// Chunk array containing all the Chunks in the game.
Chunk[][] chunks;

// A world object that contains functions for altering Arrays tiles and chunks.
World world; 

// The person playing the game.
Player player;

// List of all Tiles getting active lighting updates in a given frame.
LightList lightList;

// HUD class
HUD hud;

// Start in tileArray[xtstart][ytstart], win at tileArray[xtwin][ytwin]
float xwstart, ywstart;
int xtstart, ytstart;
int xtwin, ytwin;

float t = 0; // Current 'time', incremented by dt every frame
float dt = 1./30.; // Used as an increment amount for physics updates. 

// keyList[key]==true if key is currently pressed, where key is a Unicode character between 0 and numKeys.
boolean[] keyList;
int numKeys = 256;

// Image assets
PImage tileSheet1;
PImage playerSheet;

void setup()
{
  //size(1366, 768, P2D);
  size(1920, 1080, P2D);
  background(0);
  colorMode(HSB, 1.0);
  smooth();
  
  // Load image assets.
  tileSheet1 = loadImage("sprites/tileSheet1.png");
  playerSheet = loadImage("sprites/player.png", "png");
  
  
  tilesOnScreenX = (int)(width / TILE_SIZE) + 2;
  tilesOnScreenY = (int)(height / TILE_SIZE) + 2;
  
  chunkDrawRadiusX = int(width / chunkPix) + 1;
  chunkDrawRadiusY = int(height / chunkPix) + 1;
  
  lightList = new LightList();
  MazePlan1 mazePlan = new MazePlan1();
  keyList = new boolean[numKeys];
  hud = new HUD();
  
  world = new World(mazePlan);
  
  player = new Player(xwstart, ywstart);
}

void draw()
{
  println(frameRate);
  //println(player.animationState);

  keyCheck();
  
  switch(world.state)
  {
    case W_PAUSE: // Game is paused, gray the screen.
      fill(0, 0, 1, 0.1);
      rect(0, 0, width, height);
      break;
      
    case W_PLAY: // Normal game play.
    
      //background(0);
      
      // Update world
      world.update();
      
      world.display();
      
      break;
    
    case W_WIN: // player has found the winning Tile.
    
      // Update world.
      world.update();
      
      world.display();
      break;
  }
}
      
  
  