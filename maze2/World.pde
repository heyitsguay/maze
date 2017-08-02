// Mnemonic variable names for World states.
final int W_PAUSE = 0;
final int W_PLAY = 1;
final int W_WIN = 2;

// *******************************************************
// *******************************************************
class World
{
  // Initializes the Arrays 'chunks' and 'tiles', provides an interface
  // to quickly manipulate these Arrays.
  
  // A Plan to create the maze.
  Plan mazeSetupPlan;
  
  // Tiles in the World can be sent through initList for some property
  // initializations.
  InitializationList initList;
  
  // Possible states: W_PAUSE, W_PLAY, W_WIN. Controls which World
  // updates happen each frame.
  int state;
  
  ArrayList<Room> rooms;
  int roomMinDimension1 = 4;
  int roomMinDimension2 = 4;
  
  // Update all Chunks within chunkUpdateRadius of the player (in Chunk coordinates).
  int chunkUpdateRadius = 2;
  
  // Number of (non-Player) existing Entity types.
  int numEntityTypes = 1;
  
  // Number of existing Item types.
  int numItemTypes = 0;
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  World(Plan mazeSetupPlan_)
  {
    // Initialize chunks
    chunks = new Chunk[CHUNKSX][CHUNKSY];
    for(int i = 0; i < CHUNKSX; i++)
    {
      for(int j = 0; j < CHUNKSY; j++)
      {
        chunks[i][j] = new Chunk(i,j);
      }
    }
    
    // Initialize tiles
    tiles = new Tile[tilesX][tilesY];
    for(int i = 0; i < tilesX; i++)
    {
      for(int j = 0; j < tilesY; j++)
      {
        tiles[i][j] = new Tile(i,j);
      }
    }
    
    mazeSetupPlan = mazeSetupPlan_;
    
    initList = new InitializationList();
    
    // Try to create a maze.
    if(!createMaze())
    {
      println("Maze creation failed.");
      exit();
    }
    
    setupRooms();
    
    takeMazeShot();
    
    state = W_PLAY;
    
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////
//  void addEntity(int ID_, float x_, float y_)
//  {
//    switch(ID_)
//    {
//      case 0:
//        Torch newEntity = new Torch(
  
  ////////////////////////////////////////////////////////////////////////////////////////////////
  boolean createMaze()
  {
    // Attempts to create a solvable maze using mazeSetupPlan. If a solvable maze is generated
    // before maxAttempts is reached, returns true. Else, returns false.
    
    int creationAttemptCounter = -1;
    int maxAttempts = 10;
    
    boolean creationSuccessful = false;
    
    while((!initList.foundTheWinner) && creationAttemptCounter < maxAttempts)
    {
      creationAttemptCounter += 1;
      mazeSetupPlan.run();
      initList.update();    
    }
    
    if(initList.foundTheWinner)
    {
      creationSuccessful = true;
    }
    
    return creationSuccessful;
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  void update()
  {
    t += dt;
    
    // Update Chunks within chunkUpdateRadius of the player.
    int imin = max(0, player.xc - chunkUpdateRadius);
    int imax = min(CHUNKSX, player.xc + chunkUpdateRadius);
    
    int jmin = max(0, player.yc - chunkUpdateRadius);
    int jmax = min(CHUNKSY, player.yc + chunkUpdateRadius);
    
    for(int i = imin; i <= imax; i++)
    {
      for(int j = jmin; j <= jmax; j++)
      {
        chunks[i][j].updateEntities();
      }
    }
    
    // Update lightList
    lightList.updateAll();
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  void display()
  {
    screenX = constrain(player.x - width / 2, 0, maxScreenX);
    screenY = constrain(player.y - height / 2, 0, maxScreenY);
    
    int drawStartTileX = int(screenX / TILE_SIZE);
    int drawStartTileY = int(screenY / TILE_SIZE);
    
    texture(tileSheet1);
    
    // Draw on-screen Tiles
    for(int i = 0; i < tilesOnScreenX; i++)
    {
      int nextX = min(drawStartTileX + i, tilesX - 1);
      
      for(int j = 0; j < tilesOnScreenY; j++)
      {
        int nextY = min(drawStartTileY + j, tilesY - 1);
        tiles[nextX][nextY].display();
      }
    }
    
    // Draw the Player
    //player.display();
    
    // Draw Entities.
    int imin = max(0, player.xc - chunkDrawRadiusX);
    int imax = min(CHUNKSX, player.xc + chunkDrawRadiusX);
    
    int jmin = max(0, player.yc - chunkDrawRadiusY);
    int jmax = min(CHUNKSY, player.yc + chunkDrawRadiusY);
    
    for(int i = imin; i <= imax; i++)
    {
      for(int j = jmin; j <= jmax; j++)
      {
        chunks[i][j].drawEntities();
      }
    }
    
    // Draw the HUD
    hud.display();
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  void wipeInitialized()
  {
    // Sets properties 'initialized' and 'inInitializationList' to 
    // false for all Tiles in tiles.
    for(int i = 0; i < tilesX; i++)
    {
      for(int j = 0; j < tilesY; j++)
      {
        tiles[i][j].initialized = false;
        //tiles[i][j].inInitializationList = false;
      }
    }
  }  
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  void setupRooms()
  {
    rooms = new ArrayList<Room>();
    
    for(int x = 1; x < tilesX - 1; x++)
    {
      for(int y = 1; y < tilesY - 1; y++)
      {
        Room aRoom = new Room(tiles[x][y], roomMinDimension1, roomMinDimension2);
        if(!aRoom.empty)
        {
          // If nonempty, add aRoom to rooms.
          rooms.add(aRoom);
        }
      }
    }
  }
        
        
}
