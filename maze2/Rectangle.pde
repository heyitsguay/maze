class Rectangle
{
  // Tile coordinates of the Rectangle's top-left corner.
  int xt, yt;
  
  // Tile coordinates of the initial Tile found in Rectangle generation.
  int xt0, yt0;
  
  // Rectangle width right and left of (xt0,yt0).
  int wright, wleft;
  
  // Rectangle height up and down from (xt0,yt0).
  int hup, hdown;
  
  int w; // width
  int h; // height
  
  // Area of this Rectangle.
  int area;
  
  // Initialized to false, becomes true when the rectangle cannot grow further in the given direction.
  boolean stoppedUp, stoppedRight, stoppedDown, stoppedLeft;
  
  // When true, the Rectangle's initial Tile is contained in a rectangular patch of Tiles
  // large enough for inclusion in the parent Room.
  boolean bigEnough;
  
  // Room this Rectangle is contained in.
  Room parentRoom;
  
  /////////////////////////////////////////////////////////////////////////
  Rectangle(Room parentRoom_, int xt0_, int yt0_, int minDimension1, int minDimension2)
  {
    // Constructor with input (xt0_, yt0_)
    
    parentRoom = parentRoom_;
    
    xt0 = xt0_;
    yt0 = yt0_;
   
    wleft = 0;
    wright = 0;
    hup = 0;
    hdown = 0;
    
    stoppedUp = false;
    stoppedRight = false;
    stoppedDown = false;
    stoppedLeft = false;
    bigEnough = false;
    
    if(grow(minDimension1, minDimension2)) 
    {
      // Tile (xt0,yt0) is contained in a new Rectangle of size bigger than
      // minDimension1 x minDimension2. Triggers the addition of this Rectangle
      // to Room parentRoom.
      bigEnough = true;
    }
  }
  
  
  Rectangle(Room parentRoom_, Tile tile_, int minDimension1, int minDimension2)
  {
    // Constructor with a Tile
    
    bigEnough = false;
    
    if(tile_.type != T_WALL)
    {
      parentRoom = parentRoom_;
      
      xt0 = tile_.xt;
      yt0 = tile_.yt;
     
      wleft = 0;
      wright = 0;
      hup = 0;
      hdown = 0;
      
      stoppedUp = false;
      stoppedRight = false;
      stoppedDown = false;
      stoppedLeft = false;
      
      
      if(grow(minDimension1, minDimension2)) 
      {
        // Tile (xt0,yt0) is contained in a new Rectangle of size bigger than
        // minDimension1 x minDimension2. Triggers the addition of this Rectangle
        // to Room parentRoom.
        bigEnough = true;
      }
    }
  }
  
  /////////////////////////////////////////////////////////////////////////
  boolean grow(int minDimension1, int minDimension2)
  {
    while(!stoppedUp || !stoppedRight || !stoppedDown || !stoppedLeft)
    {
      if (!stoppedRight)
      {
        stoppedRight = growRight();
      }
      
      if (!stoppedDown)
      {
        stoppedDown = growDown();
      }
      
      if (!stoppedLeft)
      {
        stoppedLeft = growLeft();
      }
      
      if (!stoppedUp)
      {
        stoppedUp = growUp();
      }
    }
    
    xt = xt0 - wleft;
    yt = yt0 - hup;
    w = wleft + wright + 1; // +1 for (xt0,yt0).
    h = hup + hdown + 1; // +1 for (xt0,yt0).
    
    area = w * h;
    
    if( (w >= minDimension1 && h >= minDimension2) || (w >= minDimension2 && h >= minDimension1) )
    {
      // Rectangle is large enough to keep as part of the Room.
      return true;
    }
    else
    {
      return false;
    }
  }
  
  /////////////////////////////////////////////////////////////////////////
  boolean growUp()
  {
    // Checks to see whether the Rectangle has room to grow up one row.
    
    int checky = yt0 - hup - 1;
    
    for(int checkx = xt0 - wleft; checkx <= xt0 + wright; checkx++)
    {
      Tile theTile = tiles[checkx][checky];
      if(theTile.yt == 0 || theTile.type == T_WALL || theTile.roomState == R_YES)
      {
        // Next row of Tiles up contains a wall Tile or already belongs to an existing Room.
        
        // true as in 'it is true that growth upward is stopped'.
        return true;
      }
    }
    
    hup += 1; // grow up.
    
    return false;
  }
  
  ///////////////////////////////////////////////////////////////////////////
  boolean growRight()
  {
    // Checks to see whether the Rectangle has room to grow right one column.
    
    int checkx = xt0 + wright + 1;
    
    for(int checky = yt0 - hup; checky <= yt0 + hdown; checky++)
    {
      Tile theTile = tiles[checkx][checky];
      if(theTile.xt == tilesX - 1 || theTile.type == T_WALL || theTile.roomState == R_YES)
      {
        // Next column of Tiles right contains a wall Tile or already belongs to an existing Room.
        
        // true as in 'it is true that growth rightward is stopped'.
        return true;
      }
    }
    
    wright += 1; // grow right.
    
    return false;
  }
  
  ///////////////////////////////////////////////////////////////////////////
  boolean growDown()
  {
    // Checks to see whether the Rectangle has room to grow down one row.
    
    int checky = yt0 + hdown + 1;
    
    for(int checkx = xt0 - wleft; checkx <= xt0 + wright; checkx++)
    {
      Tile theTile = tiles[checkx][checky];
      if(theTile.yt == tilesY - 1 || theTile.type == T_WALL || theTile.roomState == R_YES)
      {
        // Next row of Tiles down contains a wall Tile or already belongs to an existing Room.
        
        // true as in 'it is true that growth downward is stopped'.
        return true;
      }
    }
    
    hdown += 1; // grow down.
    
    return false;
  }
  
  ////////////////////////////////////////////////////////////////////////////
  boolean growLeft()
  {
    // Checks to see whether the Rectangle has room to grow left one column.
    
    int checkx = xt0 - wleft - 1;
    
    for(int checky = yt0 - hup; checky <= yt0 + hdown; checky++)
    {
      Tile theTile = tiles[checkx][checky];
      if(theTile.xt == 0 || theTile.type == T_WALL || theTile.roomState == R_YES)
      {
        // Next column of Tiles left contains a wall Tile or already belongs to an existing Room.
        
        // true as in 'it is true that growth leftward is stopped'.
        return true;
      }
    }
    
    wleft += 1; // grow left.
    
    return false;
  }
  
  /////////////////////////////////////////////////////////////////////////
  void addBoundaryTiles()
  {
    // Add all Tiles bordering this Rectangle, not already in a Room or Room's tileCheckList,
    // to this Tile's Room's tileCheckList.
    
    // Add the Tiles above and below the Rectangle
    for(int x = xt; x < xt + w; x++)
    {
      // above
      if(yt > 1) // Don't add World boundary Tiles.
      {
        tile2boundary(tiles[x][yt-1]);
      }
       
      //below
      if(yt + h < tilesY - 1) // Don't add World boundary Tiles.
      {
        tile2boundary(tiles[x][yt+h]);
      }
    }
    
    // Add the Tiles to the left and right of the Rectangle.
    for(int y = yt; y < yt+h; y++)
    {
      // left
      if(xt > 1) // Don't add World boundary Tiles.
      {
        tile2boundary(tiles[xt-1][y]);
      }
      
      // right
      if (xt + w < tilesX - 1) // Don't add World boundary Tiles.
      {
        tile2boundary(tiles[xt+w][y]);
      }    
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////
  void updateTiles()
  {
    for(int x = xt; x < xt + w; x++)
    {
      for(int y = yt; y < yt + h; y++)
      {
        tiles[x][y].roomState = R_YES;
        tiles[x][y].parentRoom = parentRoom;
        tiles[x][y].c_hroom = parentRoom.c_h;
      }
    }
  }
  
  ////////////////////////////////////////////////////////////////////////////
  void tile2boundary(Tile aTile)
  {
    // Adds input Tile aTile to this Rectangle's Room's tileCheckList.
    
    if( (aTile.type != T_WALL) && (aTile.roomState == R_NO) )
    {
      // Add aTile to the list of new Tiles to check for Rooms if it's not
      // a wall Tile and not already in a Room.
      parentRoom.tileCheckList.add(aTile);
      aTile.roomState = R_BDRY;
    }
  }
  
}
