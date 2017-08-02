class Room
{
  
  // ArrayList of all Tiles in the Room.
  ArrayList<Tile> tileList; 
  
  // ArrayList of all Tiles adjacent to the Room to be checked for Rectangles.
  ArrayList<Tile> tileCheckList; 
  
  // A Room is subdivided into adjacent nonintersecting Rectangles.
  ArrayList<Rectangle> rectList;
  
  // Tile coordinate of the initial Tile which generates the Room.
  int x0t, y0t;
  
  // Area occupied by the Room.
  int area;
  
  // All effects modulated by Room area.
//  color c_base; // Base color effect created by the Room.
  float c_h; // Base hue effect created by the Room.
  float c_s; // Base saturation effect created by the Room.
  float c_b; // Base brightness effect created by the Room.
  
  // Used in Room setup, initializes to true. If the Room is large enough
  // (according to some parameters input to the constructor), changes to false.
  boolean empty;  
  
  //////////////////////////////////////////////////////////////////////////////////
  Room(Tile tile_, int minDimension1, int minDimension2)
  {
    empty = true;
    
    if(tile_.roomState == R_NO)
    {
      // Only bother creating a Room if tile_ is not already in one or known to not be contained
      // in a room. 
      
      tileList = new ArrayList<Tile>();
      tileCheckList = new ArrayList<Tile>();
      rectList = new ArrayList<Rectangle>();
      
      x0t = tile_.xt;
      y0t = tile_.yt;
      
      area = 0;
      
      //c_base = color(0.2, -0.02, 0.02);
      c_h = random(-0.5, 0.5);//0.2;
      c_s = -0.02;
      c_b = 0.02;
      
      // begin the Room creation procedure.
      // Create a new Room by adding a Rectangle starting at tile_ if it
      // is big enough, then all neighboring Rectangles recursively.
      tileCheckList.add(tile_);
      while(tileCheckList.size() > 0)
      {
        Tile aTile = tileCheckList.get(0);
        tileCheckList.remove(0);
        Rectangle newRect = new Rectangle(this, aTile, minDimension1, minDimension2); 
        if(newRect.bigEnough)
        {
          empty = false;
          addRectangle(newRect);
        }
        else
        {
          aTile.roomState = R_CHKD;
        }
      }
    }
  }
  
  //////////////////////////////////////////////////////////////////////////////////
  void addRectangle(Rectangle rect_)
  {
    // Add rect_ to rectList and add its area to the Room's area.
    rectList.add(rect_);
    area += rect_.area;
    
    // Set rect_'s Tiles' roomState to R_YES and set parentRoom.
    rect_.updateTiles();
    
    // Add the appropriate boundary Tiles to tileCheckList.
    rect_.addBoundaryTiles();
  }
  
}
