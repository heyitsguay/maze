class Rectangle
{
  int xt; // top-left x Tile coordinate
  int yt; // top-left y Tile coordinate
  int x0; // initial x Tile coordinate
  int y0; // initial y Tile coordinate
  int wright;
  int wleft;
  int hup;
  int hdown;
  int w; // width
  int h; // height
  int rectarea; // area of the rectangle.
  boolean stoppedUp; // initializes to false, becomes true when the rectangle cannot grow further upward.
  boolean stoppedRight; // initializes to false, becomes true when the rectangle cannot grow further rightward.
  boolean stoppedDown;
  boolean stoppedLeft;
  boolean goodToGo;

  Rectangle(int x0_, int y0_, Room theRoom)
  {
    x0 = x0_;
    y0 = y0_;

    wleft = 0;
    wright = 1;
    hup = 0;
    hdown = 1;

    stoppedUp = false;
    stoppedRight = false;
    stoppedDown = false;
    stoppedLeft = false;
    goodToGo = false;
    if (grow()) // if Tile (x0,y0) is contained in a new Rectangle bigger than 2x2, the Rectangle is kept as part of a Room.
    {
      goodToGo = true;
      theRoom.rectList.add(this); // Add this Rectangle to the Room.
      for (int x = xt; x < xt + w; x++)
      {
        for (int y = yt; y < yt + h; y++)
        {
          //println(str(w) + " " + str(h));
          //println(str(wleft) + " " + str(wright) + " " + str(hup) + " " + str(hdown));
          tileArray[x][y].inRoom = true;
          tileArray[x][y].roomh = theRoom.roomh;
          theRoom.tileList.add(tileArray[x][y]);
        }
      }
    }
  }

  Rectangle(Tile tile0, Room theRoom)
  {
    x0 = tile0.xt;
    y0 = tile0.yt;

    wleft = 0;
    wright = 1;
    hup = 0;
    hdown = 1;

    stoppedUp = false;
    stoppedRight = false;
    stoppedDown = false;
    stoppedLeft = false;
    goodToGo = false;
    if (grow()) // if Tile (x0,y0) is contained in a new Rectangle bigger than 2x2, the Rectangle is kept as part of a Room.
    {
      goodToGo = true;
      theRoom.rectList.add(this); // Add this Rectangle to the Room.
      for (int x = xt; x < xt + w; x++)
      {
        for (int y = yt; y < yt + h; y++)
        {
          tileArray[x][y].inRoom = true;
          theRoom.tileList.add(tileArray[x][y]);
        }
      }
    }
  }

  boolean grow() // Returns the largest rectangle of maze Tiles not already in a Room containing Tile (x0,y0).
  {

    while (!stoppedUp || !stoppedRight || !stoppedDown || !stoppedLeft) //<>//
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

    xt = x0 - wleft;
    yt = y0 - hup;
    w = wleft + wright;
    h = hup + hdown;
    rectarea = w * h;
    if ((w>2 && h >= 2) || (w>=2 && h > 2)) // big enough to keep
    {
      return true;
    } else
    {
      return false;
    }
  }

  boolean growRight()
  {
    int checkx = x0 + wright;
    for (int checky = y0 - hup; checky < y0 + hdown; checky++)
    {
      if (tileArray[checkx][checky].wall || tileArray[checkx][checky].inRoom)
      {
        //println("right stopped");
        return true;
      }
    }
    wright +=1 ; // grow right

    return false;
  }

  boolean growLeft()
  {
    int checkx = x0 - wleft - 1;
    for (int checky = y0 - hup; checky < y0 + hdown; checky++)
    {
      if (tileArray[checkx][checky].wall || tileArray[checkx][checky].inRoom)
      {
        //println("left stopped");
        return true;
      }
    }
    wleft +=1 ; // grow left

    return false;
  }

  boolean growDown()
  {
    int checky = y0 + hdown; //<>//
    for (int checkx = x0 - wleft; checkx <= x0 + wright; checkx++)
    {
      if (tileArray[checkx][checky].wall || tileArray[checkx][checky].inRoom)
      {
        //println("down stopped");
        return true;
      }
    }
    hdown += 1; // grow down

    return false;
  }

  boolean growUp()
  {
    int checky = y0 - hup - 1;
    for (int checkx = x0 - wleft; checkx < x0 + wright; checkx++)
    {
      if (tileArray[checkx][checky].wall || tileArray[checkx][checky].inRoom)
      {
        //println("up stopped");
        return true;
      }
    }
    hup += 1; // grow down

    return false;
  }

  void addBoundaryTiles(ArrayList<Tile> checkTileList)
  {
    Tile ti;
    // Add the Tiles above the Rectangle
    for (int x = xt + 1; x < xt + w - 1; x++)
    {
      ti = tileArray[x][yt-1];
      if (!ti.wall && !ti.inRoom)
      {
        checkTileList.add(ti);
      }
    }

    // Add the Tiles right of the Rectangle
    for (int y = yt + 1; y < yt + h - 1; y++)
    {
      ti = tileArray[xt+w][y];
      if (!ti.wall && !ti.inRoom)
      {
        checkTileList.add(ti);
      }
    }

    // Add the Tiles below the Rectangle
    for (int x = xt + 1; x < xt + w - 1; x++)
    {
      ti = tileArray[x][yt + h];
      if (!ti.wall && !ti.inRoom)
      {
        checkTileList.add(ti);
      }
    }

    // Add the Tiles left of the Rectangle
    for (int y = yt + 1; y < yt + h - 1; y++)
    {
      ti = tileArray[xt-1][y];
      if (!ti.wall && !ti.inRoom && !ti.inRoomCheck)
      {
        checkTileList.add(ti);
        ti.inRoomCheck = true;
      }
    }
  }
}
