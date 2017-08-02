// uses the following global variables defined in maze2
// - int TILE_SIZE
// - int CHUNK_SIZE
// - int chunkPix
// - Chunk[][] chunks
// - Tile[][] tiles

class Chunk
{
  // (x,y) Chunk coordinates 
  int xc;
  int yc;
  
  // (x,y) World coordinates of the top-left corner of this Chunk. (0,0) is the top-left pixel of the maze.
  int xw;
  int yw;
  
  // Tiles with Tile coordinates (xt0,yt0) to (xt1,yt1) reside in this Chunk.
  int xt0, xt1;
  int yt0, yt1;
  
  // List of all Entities whose intersection with this Chunk is nonempty.
  ArrayList<Entity> entityList;
  
  // List of all Items located on a Tile within this Chunk.
  ArrayList<Item> itemList;
  
  //////////////////////////////////////////////////////////////////////////////////
  Chunk(int xc_, int yc_)
  {
    xc = xc_;
    yc = yc_;
    
    xw = xc * chunkPix;
    yw = yc * chunkPix;
    
    xt0 = xc * CHUNK_SIZE;
    yt0 = yc * CHUNK_SIZE;
    
    xt1 = xt0 + CHUNK_SIZE - 1;
    yt1 = yt0 + CHUNK_SIZE - 1;
    
    entityList = new ArrayList<Entity>();
    itemList = new ArrayList<Item>(); 
  }
  
  ///////////////////////////////////////////////////////////////////////////////////
  void updateEntities()
  {
    if(entityList.size() > 0)
    {
      for(int i = entityList.size() - 1; i >= 0; i--)
      {
        entityList.get(i).update();
      }
    }
  }
  
  void drawEntities()
  {
    if(entityList.size() > 0)
    {
      for(int i = entityList.size() - 1; i >= 0; i--)
      {
        entityList.get(i).display();
      }
    }
  }
  
}
  
  
