// This file uses the following global variables defined in maze2:
//   TILE_SIZE

// Mnemonic variable names for the Tile types.
final int T_WALL = 0;
final int T_PATH = 1;
final int T_WIN  = 2;

// Mnemonic variable names for a Tile's Room states.
final int R_NO = 0;
final int R_BDRY = 1;
final int R_YES = 2;
final int R_CHKD = 3; // has been in a checklist, known to not be contained in a Room.

class Tile
{
  // (x,y) Tile coordinates of this Tile
  int xt;
  int yt;
  
  // (x,y) World coordinates of the top-left corner of this Tile. (0,0) is the top-left pixel of the maze.
  int xw;
  int yw;
  
  int type; // Type of Tile. Initializes to 0.
  // Types currently defined:
  //    0: wall Tile (never walkable).
  //    1: walkable Tile.
  //    2: winning Tile.
  
  boolean blocked; // If true, the Tile cannot be traversed.
  
  //int numNeighbors; // Number of Tiles which this Tile borders.
  ArrayList<Tile> neighborList; // ArrayList pointing to the walkable neighbor Tiles. 
  
  // Diffusion calculations look like my.z = sum_{neighbors}[neighborWeight * neighbor.z] - my.z.
  // Diagonal neighbors have weight baseNeighborWeight. URDL neighbors have weight sqrt(2) * baseNeighborWeight.
  float baseNeighborWeight; 


  float c_h, c_s; // HS (of HSB) values in range [0,1]. Base Tile color.
  float c_bmax; // Maximum Tile brightness
  float c_bbase, c_bactive; // B has passive and active illumination components.
  float c_bactiveNew; // Used in updating c_bactive.
  float a_h, a_s, a_b; // HSB values in range [0,1]. Alignment Tile color modifier (additive).
  
  float dh; // Amount that ch changes each frame (for color-changing effects).
  
  boolean initialized; // Starts false, changes to true once this Tile has been initialized by the maze initialization routine.
  //boolean inInitializationList; // Starts false, changes to true when the Tile is in the list of Tiles to be initialized.
 
  ArrayList<Item> itemList; // List of all Items whose position overlaps this Tile.
  ArrayList<Entity> entityList; // List of all Entities whose position overlaps this Tile.
  
  // Value in [-1,1], indicating disposition to spawn friendly vs. hostile Entities.
  float alignment;
  
  // If 0, Tile is not in a room (R_NO). 
  // If 1, Tile is in a Room's boundary Tile check list (R_BDRY). 
  // If 2, Tile is in a Room (R_YES).
  // If 3, Tile has been through a Room's tileCheckList and found to be contained in no Room (R_CHKD).
  char roomState;
  
  // If in a Room, this points to it
  Room parentRoom;
  float c_hroom;
  
  /////////////////////////////////////////////////////////////////////////////////
  Tile(int xt_, int yt_)
  {
    xt = xt_;
    yt = yt_;
    
    xw = xt * TILE_SIZE;
    yw = yt * TILE_SIZE;
    
    //numNeighbors = 0;
    neighborList = new ArrayList<Tile>(8);
    
    // Initializes to wall type.
    setType(T_WALL);
    
    initialized = false;
    //
    
    itemList = new ArrayList<Item>();
    entityList = new ArrayList<Entity>();
    
    alignment = 0;
    //c_alignment = color(0.1, 0., 0.05);
    a_h = 0.1;
    a_s = 0.;
    a_b = 0.05; 
    
    c_bactive = 0.;
    c_bactiveNew = 0.;
    
    roomState = R_NO;
    c_hroom = 0;
  }
  
  ///////////////////////////////////////////////////////////////////////////////////
  void display()
  {    
    //noStroke();
    pushMatrix();
    translate(-screenX, -screenY);
    
    // Fill colors.
    if(type == 2) // winning Tile
    {
      c_h = mod1(c_h + 0.01 * dh);
      dh = constrain(dh + 0.005 * random(-1,1), -1, 1);
      fill(c_h, c_s, 1);
    }
    else
    {   
      float final_h = mod1(constrain(c_h + a_h * alignment, 0, 1) + c_hroom);
      float final_s = constrain(c_s + a_s * alignment, 0, 1);
      float final_b;
      
      // When the player is a ghost, display all path Tiles
      if(player.ghost && type != T_WALL)
      {
        final_b = 0.8;
      }
      else
      {
        final_b = constrain(c_bbase + c_bactive + a_b * alignment, 0, 1);
        //final_b = sigmoid(c_bbase + c_bactive + a_b * alignment);
      }
      
      fill(final_h , final_s, final_b * c_bmax);
      stroke(final_h, final_s, final_b * c_bmax);
      strokeWeight(1);
      
      //fill(c_base + alignment * c_alignment);
    }
    
    // Draw the rectangle
    rect(xw, yw, TILE_SIZE, TILE_SIZE);
    
    popMatrix();
  }
  
  //////////////////////////////////////////////////////////////////////////////////
  void setType(int type_)
  {
    type = type_;
    
    // Also, special changes for each type (blocked -> unblocked, etc.)
    // on a case-by-case basis.
    switch(type_)
    {
      case 0: // Wall
        blocked = true;
        c_h = 0;
        c_s = 1;
        c_bmax = 1;
        c_bbase = 0.0;
        break;
        
      case 1: // Path
        blocked = false;
        c_h = 0.635;
        c_s = 0.5;
        c_bmax = 1;
        c_bbase = 0;
        break;
        
      case 2: // Winning
        blocked = false;
        c_h = 0.4; // whatever, it drifts
        c_s = 1;
        c_bmax = 1;
        c_bbase = 0;
        break;
    }
  }
  
}
