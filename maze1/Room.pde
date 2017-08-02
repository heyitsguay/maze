class Room // contains N Tiles in some arrangement
{
  ArrayList<Tile> tileList; // ArrayList of all Tiles in the room.
  ArrayList<Tile> tileCheckList; // ArrayList of all Tiles adjacent to the Room to be checked for Rectangles.
  // A room is subdivided into R rectangles, stored as an ArrayList of 4x1 int vectors [x y w h]
  // of top-left Tile (x,y) coordinates and width w, height h.
  ArrayList<Rectangle> rectList;
  int numRects = 0;
  int x0t; // x0t and y0t form the top-left corner of the initial Tile rectangle which generates the room
  int y0t;
  int centerXt;
  int centerYt;
  float roomh; // room H color value
  boolean roomHere;
  int roomarea;
  
  Room(Tile tin)
  {
    
    roomHere = false;
    tileList = new ArrayList<Tile>();
    tileCheckList = new ArrayList<Tile>();
    rectList = new ArrayList<Rectangle>();
    roomh = random(1.0);
    roomarea = 0;
    Rectangle rect = new Rectangle(tin.xt, tin.yt, this);
    if(rect.goodToGo)
    {
      roomHere = true;
      numRects += 1;
      roomarea += rect.rectarea;
      rectList.add(rect);
      rect.addBoundaryTiles(tileCheckList);
      
      
      while(tileCheckList.size() > 0)
      {
        Tile ti = tileCheckList.get(0);
        tileCheckList.remove(0);
        rect = new Rectangle(ti, this);
        if(rect.goodToGo)
        {
          numRects += 1;
          rectList.add(rect);
          rect.addBoundaryTiles(tileCheckList);
        }
      //println(tileCheckList.size());
      }
    }    
  }
}
