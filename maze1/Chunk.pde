// Uses the following global variables defined in maze
// CHUNK_SIZE
class Chunk
{
  int x1t; // Top-left corner Tile x coordinate.
  int y1t; // Top-left corner Tile y coordinate.
  int x2t;
  int y2t;
  int xw; 
  int yw;
  int csizex; // x Chunk size (perhaps less than CHUNK_SIZE due to World boundaries)
  int csizey; // y Chunk size
  
  ArrayList<Item> items;
  
  Chunk(int x1t_, int y1t_)
  {
    x1t = x1t_;
    y1t = y1t_;
    xw = x1t * TILE_SIZE;
    yw = y1t * TILE_SIZE;
    csizex = min(CHUNK_SIZE, numTilesX - x1t);
    csizey = min(CHUNK_SIZE, numTilesY - y1t);
    x2t = x1t + csizex - 1;
    y2t = y1t + csizey - 1;
    
    items = new ArrayList<Item>();
  }
  
}
