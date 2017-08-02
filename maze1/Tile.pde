// This file uses the following global variables defined in maze:
// TILE_SIZE - size of each drawn Tile in pixels

class Tile
{
  int xt; // Tile x location (Tile coordinates)
  int yt; // Tile y location (Tile coordinates)
  
  int xw; // Tile lower-left corner x location (World/pixel coordinates)
  int yw; // Tile lower-left corner y location (World/pixel coordinates)

  boolean wall; // If true, the Tile is a wall, which can't be traversed.
  boolean blocked; // If true, the Tile cannot be traversed.
  int borders; // Number of walkable Tiles which this Tile borders.
  
  float roomh; // Color of the Room the Tile is in.
  float ch; // Hue parameter for the Tile's color. Range [0, 1]
  float cs; // Saturation parameter for the Tile's color. Range [0, 1]
  float cb; // Brightness parameter for the Tile's color. Range [0, 1]
  float cbnew; // Used for the lighting updates to track changes between iterations.
  
  
  int[][] mazeNeighbors; // xt, yt coordinates for neighboring maze Tiles *8 neighbors*.
  int numNeighbors; // number of neighboring maze Tiles.
  
  boolean initialized; // initializes to false, changed to true once a Tile has been updated by some maze initialization routine
  boolean inList; // initializes to false, tracks whether the Tile is currently in the initialization update ArrayList. Should be renamed.
  boolean inLightList; // initializes to false, tracks where the Tile is currently in the lighting update ArrayList.
  boolean startsRoom; // true if the east, southeast, and south neighbors are also Tiles.
  boolean inRoom; // initializes to false, tracks whether the Tile is currently in a Room.
  boolean inRoomCheck; // initializes to false, tracks whether the Tile is in the room boundary Tile check list.
  
  float dh; // Let dh propagate tile-by-tile for better variation
  
  // Keep track of a logistically desaturating effect by the Player with these variables.

  // The initial value of desat controls when saturation starts: smaller values shift the start time outward. 
  // The effect is logarithmic: each power of 10 shifts the effect onset later by ~6 seconds.
  float desat; 
  //float desatnew; // Used for the saturation updates to track changes between iterations.
  float desatRate; // Rate at which desaturation occurs
  
  boolean winning; // true if the winning Tile
  
  boolean itemHere; // true if there is an Item here.
  Item theItem; // References the Item here, if it exists.
  
  
  Tile(int xt_, int yt_, float ch_, float cs_, float cb_)
  {
    xt = xt_;
    yt = yt_;
    xw = xt * TILE_SIZE;
    yw = yt * TILE_SIZE;
    wall = true;
    blocked = true;
    borders = 0;
    ch = ch_;
    cs = cs_;
    cb = cb_;
    cbnew = cb;
    initialized = false;
    inList = false;
    inLightList = false;
    startsRoom = false;
    inRoom = false;
    inRoomCheck = false;
    
    roomh = 0;
    
    // initialize mazeNeighbors
    mazeNeighbors = new int[2][8];
    numNeighbors = 0;
    
    // initialize desat and desatRate.
    desat = 0.01;
    desatRate = 0.01;
    //desatnew = desat;
    
    winning = false;
    itemHere = false;
  }
  
  void display(double xscreen, double yscreen)
  {
    double xrelative = xw - xscreen;
    double yrelative = yw - yscreen;
    noStroke();
    if(winning)
    {
      ch = mod1(ch + 0.01 * dh);
      dh = constrain(dh + 0.005 * random(-1,1), -1, 1);
    }
    if(godMode && !wall)
    {
      fill(ch, constrain(cs,0,1), 1);
    }
    else if(winning)
    {
      fill(ch, 1, constrain(cb,0,1));
    }
    else if(inRoom && drawRoomFlag)
    {
      fill(roomh,1,1);
    }
    else
    {
      fill(ch, constrain(cs-desat,0,1), constrain(cb,0,1));
    }
    rect((float)xrelative, (float)yrelative, (float)TILE_SIZE, (float)TILE_SIZE);
    if(itemHere)
    {
      theItem.display((float)xscreen, (float)yscreen, (float)cb);
    }
  }
  
  void addToLighting()
  {
    lightingTiles.add(this);
    inLightList = true;
  }
  
  void removeFromLighting()
  {
    lightingTiles.remove(this);
    inLightList = false;
  }
  
  void addItem(int id_)
  {
    theItem = new Item(xt, yt, id_);
    itemHere = true;
  }
  
  boolean isNeighbor(Tile neighb_)
  {
    if(numNeighbors>0)
    {
      for(int i = 0; i < numNeighbors; i++)
      {
        if(xt == mazeNeighbors[0][i] && yt == mazeNeighbors[1][i])
        {
          return true;
        }
      }
    }
    return false;
  }
  
}