// maze - Matthew Guay, 10/07/2014.
// Procedurally-generated mazes with lighting-based visual effects

// Globally visible info
Tile[][] tileArray; // 2D array of all maze Tiles
ArrayList<Tile> updateTiles; // ArrayList containing the Tiles being actively updated during maze initialization.
ArrayList<Tile> lightingTiles; // ArrayList containing the Tiles being tracked for lighting
ArrayList<Room> roomList;
int numRooms;

boolean drawRoomFlag = false;

ArrayList<Creator> creators;
final int TILE_SIZE = 32;
final int numTilesX = 500;
final int numTilesY = 500;
int tilesOnScreenX;
int tilesOnScreenY;
int maxScreenX;
int maxScreenY;

final int CHUNK_SIZE = 40;
int numChunksX = ceil(float(numTilesX)/CHUNK_SIZE);
int numChunksY = ceil(float(numTilesY)/CHUNK_SIZE);
Chunk[][] chunkArray; // 2D array of all Chunks.

float xScreen = 0;
float yScreen = 0;

// Start at tileArray[1][1], win at tileArray[end-1][end-1]
int startXt = 1;
int startYt = 1;
int winXt = numTilesX - 30;
int winYt = numTilesY - 30;

int gameOver; // changes to 1 when the Player reaches the winning Tile.
int winTime; // Records the time at which the Player wins.
int waitTime = 2000; // Wait 2 seconds after winning before quitting.

// Player object
Player thePlayer;

boolean godMode = false; // When true, Player can move through walls

float dratebase = 0.5;
float drateactive = dratebase;

int t = 0;

// keyList[key]==true if key is pressed, where key is a Unicode character between 0 and numKeys.
boolean[] keyList;
int numKeys = 256;


//////////////////////////////////////////////////////////////////////////
// The main setup function                                              //
//////////////////////////////////////////////////////////////////////////
void setup() {
  size(1366, 768, P2D);
  //size(1920, 1080, P2D);
  background(0);
  colorMode(HSB, 1.0);
  smooth();
  
  // Calculate the number of tiles on the screen
  tilesOnScreenX = (int)(width / TILE_SIZE) + 2;
  tilesOnScreenY = (int)(height / TILE_SIZE) + 2;
  
  // Initialize the tileArray to all walls (black and blocked)
  tileArray = new Tile[numTilesX][numTilesY];
  for(int i = 0; i < numTilesX; i++)
  {
    for(int j = 0; j < numTilesY; j++)
    {
      tileArray[i][j] = new Tile(i, j, 0, 1, 0);
      if(i == winXt && j == winYt) // If this is the winning Tile, declare it!
      {
        tileArray[i][j].winning = true;
      }
    }
  }
  
  // Considering the entire maze as a single pixel object, compute the boundary X and Y pixel values.
  maxScreenX = numTilesX * TILE_SIZE - width;
  maxScreenY = numTilesY * TILE_SIZE - height;
  
  // Initialize the chunkArray
  chunkArray = new Chunk[numChunksX][numChunksY];
  for(int i = 0; i < numChunksX; i++)
  {
    for(int j = 0; j < numChunksY; j++)
    {
      chunkArray[i][j] = new Chunk(i * CHUNK_SIZE, j * CHUNK_SIZE);
    }
  }
  
  // Initialize the Player
  thePlayer = new Player(TILE_SIZE+1, TILE_SIZE+1, 0, 0, 0, 0.1);

  // Initialize the roomList
  roomList = new ArrayList<Room>();

  mazeFunction1(150, 4); // Generate a maze!
  
  // Initialize maze Tiles. Also checks to see if mazeFunction1 generated a maze
  // which doesn't connect the starting and winning Tiles. Restart setup() if that happens.
  if(!setupMazeTiles(random(0,1), 0.0, 0.08, 0.03)) 
  {
    setup();
  }
  
  tileArray[winXt][winYt].cs = 0; // make the winning Tile white
  
  // Initialize the light list.
  lightingTiles = new ArrayList<Tile>();
  //lightingTiles.add(tileArray[startXt][startYt]);
  
  // setup all the Rooms.
  setupRooms();
  
  
  // Game is not over!
  gameOver = 0;
  
  // Initialize keyList
  keyList = new boolean[numKeys];
}

/////////////////////////////////////////////////////////////////////////////////////
// main draw function                                                              //
/////////////////////////////////////////////////////////////////////////////////////
void draw()
{
  println(frameRate);
  t += 1;
  keyCheck();
  
  switch(gameOver) // Different routine depending on whether the game is over or not
  {
    case 0: // Game is still going
      // Mouse press updates.
      if(mousePressed)
      {
        float dcharge = 2.5;
        if(thePlayer.charge > 0)
        {
          thePlayer.bnessactive += dcharge * thePlayer.charge;
          thePlayer.charge = max(thePlayer.minCharge, (thePlayer.charge) * thePlayer.chargeCost);
          drateactive = 0.9;
        }
      }
      // Figure out where in the Tile array to start drawing.
      xScreen = constrain(thePlayer.xd - (int)(width / 2), 0, maxScreenX);
      yScreen = constrain(thePlayer.yd - (int)(height / 2), 0, maxScreenY);
      int drawStartX = (int)(int(xScreen) / TILE_SIZE);
      int drawStartY = (int)(int(yScreen) / TILE_SIZE);
      int nextX, nextY;
      
      // Calculate lighting
      drateactive = dratebase + 0.95 * (drateactive - dratebase);
      calculateLighting(drateactive);
  
      // Draw the on-screen Tiles
      for(int i = 0; i < tilesOnScreenX; i++)
      {
        for(int j = 0; j < tilesOnScreenY; j++)
        {
          nextX = min(drawStartX + i, numTilesX-1);
          nextY = min(drawStartY + j, numTilesY-1);
          tileArray[nextX][nextY].display(xScreen, yScreen);
        }
      }
  
      // Draw the Player
      thePlayer.display(xScreen, yScreen);
      
      // Draw the HUD
      drawHUD();
      
      break;
      
   case 1:// Game has just been won, last graphic update
      gameOver = 2;
      winTime = millis();
      xScreen = constrain(thePlayer.xd - (int)(width / 2), 0, maxScreenX);
      yScreen = constrain(thePlayer.yd - (int)(height / 2), 0, maxScreenY);
      drawStartX = (int)(int(xScreen) / TILE_SIZE);
      drawStartY = (int)(int(yScreen) / TILE_SIZE);
      //int nextX, nextY;
      
      // Calculate lighting
      calculateLighting(0.5);
  
      // Draw the on-screen Tiles
      for(int i = 0; i < tilesOnScreenX; i++)
      {
        for(int j = 0; j < tilesOnScreenY; j++)
        {
          nextX = min(drawStartX + i, numTilesX-1);
          nextY = min(drawStartY + j, numTilesY-1);
          tileArray[nextX][nextY].display(xScreen, yScreen);
        }
      }
  
      // Draw the Player
      thePlayer.display(xScreen, yScreen);
      
      break;
      
      
   case 2: // Game has been won, freeze and fade to black
      loadPixels();
      for(int i = 0; i < width * height; i++)
      {
        color c = pixels[i];
        float ch = hue(c);
        float cb = brightness(c);
        pixels[i] = color(ch, 1, cb * 0.9);
      }
      updatePixels();
      if(millis() - winTime >= waitTime){exit();}
      break;
  }

}