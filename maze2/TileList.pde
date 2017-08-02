// base class for ArrayLists of Tiles to be used in the following way:
// (1) an update function is run on each Tile in TileList, every k frames,
//     where k is specified on construction.
// (2) the update function will modify one or more properties of each Tile
//     and also add additional Tiles to the TileList (i.e. the Tile's neighbors).

class TileList
{
  // Contains all Tiles in the List.
  ArrayList<Tile> theList;
  
  // A boolean vector of length (tilesX*tilesY), 
  // intializes to false and becomes true when a Tile is added.
  // Indexed from the top-left corner of the World and runs horizontally.
  boolean[] inTheList;
  
  ////////////////////////////////////////////////////////////////////////////////////////
  TileList()
  {
    theList = new ArrayList<Tile>();
    inTheList = new boolean[tilesX*tilesY];
  }
  
  /////////////////////////////////////////////////////////////////////////////////////////
  void updateAll()
  {
    if(theList.size() > 0)
    {
      for(int i = theList.size()-1; i>=0; i--)
      {
        // Call the Tile update function on each Tile in theList.
        //Tile aTile = theList.get(i);
        update(i);
      }
    }
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////
  boolean tileRemovalCheck(Tile tile_)
  {
    // This method is overwritten by subclasses. Default behavior is to always
    // return true.
    return true;
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////
  void update(int listIdx_)
  {
    // Overwritten by subclasses.
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////
  Tile pop(int listIdx_)
  {
    Tile aTile = theList.get(listIdx_);
    theList.remove(listIdx_);
    return aTile;
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////
  void addTile(Tile tile_)
  {
    // Adds the Tile tile_ to theList if it's not in 
    // there already. Updates inTheList as well.
    
    int tileIdx = getTileIdx(tile_);
    
    if(!inTheList[tileIdx])
    {
      theList.add(tile_);
      inTheList[tileIdx] = true;
    }
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////
  void removeTile(int listIdx_)
  {
    // Removes theList[listIdx_] from theList.
    // Updates inTheList as well.
    
    Tile aTile = theList.get(listIdx_);
    
    int tileIdx = getTileIdx(aTile);
    
    theList.remove(listIdx_);
    inTheList[tileIdx] = false;
  }    
}

// ******************************************************
// ******************************************************
class LightList extends TileList
{
  // Diffusion-based lighting effect. Modifies the c_bactive property of Tiles.
  
  // diffusion rate.
  float diffusionRate = 0.2;
  
  // decay constant.
  float decayRate = 0.999;//0.99999;
  
  // c_bactive threshold for inclusion in the List.
  float threshold = 0.0001;//0.00001;
  
  /////////////////////////////////////////////////////////////////////////////////////////////
  LightList()
  {
    super();
  }
  
  /////////////////////////////////////////////////////////////////////////////////////////////  
  void updateAll()
  {
    // Add the Tile that the player is standing on to the LightList.
    //addTile(tiles[player.xtcenter][player.ytcenter]);
    
    for(int i = theList.size()-1; i>=0; i--)
    {
      // Call the Tile update function on each Tile in theList.
      //Tile aTile = theList.get(i);
      update(i);
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////
  void update(int listIdx_)
  {
    Tile aTile = theList.get(listIdx_);
    
    aTile.c_bactive = decayRate * aTile.c_bactiveNew;
    
    if(tileRemovalCheck(aTile))
    {
      removeTile(listIdx_);
    }
    else
    {
      // Reset the active component update.
      aTile.c_bactiveNew = 0;
      
      // Diffuse aTile's c_bactive to its neighbors, add
      // those neighbors to theList.
      diffuseLight(aTile);     
    }
    
  }
  
  /////////////////////////////////////////////////////////////////////////////////////////////////
  void diffuseLight(Tile tile_)
  {
    // Iterate through tile_'s neighborList, diffusing and adding neighbors to 
    // theList.

    for(int i = 0; i < tile_.neighborList.size(); i++)
    {
      Tile neighbor = tile_.neighborList.get(i);
      
      // Add a portion of tile_.c_bactive to URDL neighbors
      if(abs(tile_.xt - neighbor.xt) + abs(tile_.yt - neighbor.yt) == 2)
      {
        // Diagonal neighbor. Weight diffusion term by baseNeighborWeight.
        neighbor.c_bactiveNew += diffusionRate * tile_.baseNeighborWeight * tile_.c_bactive;
      }
      else
      {
        // URDL neighbor. Weight diffusion term by sqrt(2) * baseNeighborWeight
        neighbor.c_bactiveNew += diffusionRate * SQRT2 * tile_.baseNeighborWeight * tile_.c_bactive;
      }
      
      // Add Tile neighbor to LightList's theList.
      addTile(neighbor);
    }
    
    // Add a portion of tile_.c_bactive to tile_.c_bactiveNew
    tile_.c_bactiveNew += (1 - diffusionRate) * tile_.c_bactive;
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  boolean tileRemovalCheck(Tile tile_)
  {
    if(tile_.c_bactive < threshold)
    {
      return true;
    }
    return false;
  }
      
}

// *********************************************
// *********************************************
class InitializationList extends TileList
{
  
  // Changes to true when tiles[xtwin][ytwin] is added to the InitializationList.
  // Signals successful maze setup (a path exists from start to finish).
  boolean foundTheWinner = false;
  
  //////////////////////////////////////////////////////////////////////////////////////////////////  
  InitializationList()
  {
    super();
    
    // Add the starting Tile to the InitializationList.
    addTile(tiles[xtstart][ytstart]);
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  boolean update()
  {
    // Changes to true when tiles[xtwin][ytwin] is added to the InitializationList.
    // Signals successful maze setup (a path exists from start to finish).
    // boolean foundTheWinner = false;
    
    // The constructor adds a single path Tile to theList. Each iteration of update()
    // removes a single Tile from theList, intializes it, and then adds any unitialized 
    // path Tile neighbors to theList.
    while(theList.size() > 0)
    {
      Tile aTile = pop(0);
      initialize(aTile);      
    }   
 
    return foundTheWinner;   
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  void initialize(Tile tile_)
  {
    tile_.initialized = true;
    
    int xti = tile_.xt;
    int yti = tile_.yt;
    
    // Check if tile_ is the winning Tile.
    if(xti == xtwin && yti == ytwin)
    {      
      // Set tile_'s type to T_WIN.
      tile_.setType(T_WIN);
      
      // Confirm that we've found the winner.
      foundTheWinner = true;
    }

    // Add neighboring non-wall Tiles to tile_.neighborList, and add any non-initialized
    // neighboring Tiles to theList.
    addTileNeighbors(tile_);
    
    // Add a Torch with some probability.
    float torchCheck = random(1);
    if(torchCheck < 0.005)
    {
      Torch aTorch = new Torch(tile_.xw + TILE_SIZE/2, tile_.yw + TILE_SIZE/2, 1);
    }
    
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  void addTileNeighbors(Tile tile_)
  {
    int xti = tile_.xt;
    int yti = tile_.yt;
    
    int numDiagonalNeighbors = 0;
    int numURDLNeighbors = 0;
    
    // Add neighboring path Tiles to tile_.neighborList and theList.
    for(int dx = -1; dx < 2; dx++)
    {
      if(xti + dx >= 0 && xti + dx < tilesX)
      {
        for(int dy = -1; dy < 2; dy++)
        {
          if(yti + dy >=0 && yti + dy < tilesY)
          {
            if(!(dy == 0 && dx == 0)) // don't check yourself!
            {
              // A neighboring Tile to tile_.
              Tile nTile = tiles[xti + dx][yti + dy];
              
              // Add this neighbor if it's not a wall.
              if(!(nTile.type == T_WALL))
              {
                
                // Rules for adding diagonal neighbors.
                if(dx != 0 && dy != 0)
                {
                  // Only add diagonally-neighboring path Tiles if both non-diagonal
                  // neighbors are path Tiles.
                  if(!(tiles[xti+dx][yti].type == T_WALL) && !(tiles[xti][yti+dy].type == T_WALL))
                  {
                    tile_.neighborList.add(nTile);
                    numDiagonalNeighbors += 1;
                    
                  }
                }    
                // Add URDL neighbors        
                else 
                {
                  tile_.neighborList.add(nTile);
                  numURDLNeighbors += 1;
                }
                
                // Add nTile to theList if not initialized or inTheList.
                if(!(nTile.initialized))
                {
                  // addTile() checks to see whether nTile is inTheList.
                  addTile(nTile);
                }
              }
            }
          }
        }
      }
    }
    
    // Calculate baseNeighborWeight (used for lighting).
    tile_.baseNeighborWeight = 1./(numDiagonalNeighbors + 2 * numURDLNeighbors);
  }
  
}
