// This setup function performs a recursive operation on ArrayList updateTiles, containing uninitialized maze Tiles, until
// updateTiles is empty. updateTiles initially contains only the starting Tile, and at each update adds all uninitialized maze Tiles
// neighboring a Tile in the list.

// The generator cellular automata are stochastic, there's a small chance the maze could fail to create a path between start and finish, but
// initialization can catch this by checking whether any initialized tile is the winning Tile. Function setupMazeTiles returns false if this happens,
// and the generation procedure is restarted.

// In addition to initializing Tile colors, the setup procedure create a neighbor set for each Tile, containing the adjacent maze Tiles. This is used
// for the lighting updates.

////////////////////////////////////////////////////////////////////////////////
// maze tile setup function                                                  //
////////////////////////////////////////////////////////////////////////////////
boolean setupMazeTiles(float h0, float b0, float drate1, float drate2)
// Initializes the walkable Tile colors, and adds references to neighboring walkable Tiles
{
  boolean foundTheWinner = false; // Becomes true if we ever setup the winning Tile.
  // drate1 controls the rate at which dh changes.
  // drate2 controls the rate at which h changes.
  // Initialize the ArrayList of Tiles to update
  updateTiles = new ArrayList<Tile>();
  
  Tile ti, tu, tr, td, tl; // Tiles referencing the initial Tile updated, and its four URDL neighbors.
  Tile tn; // Tile used in the maze Tile neighbor check.
  
  int xti, yti; // Tile coordinates
    
  //float h = h0;
  float dh0 = random(-1, 1); // initial dh
  float b = b0;
  
  // Add the starting Tile to be list
  updateTiles.add(tileArray[startXt][startYt]);
  // Initialize the starting Tile color parameters
  tileArray[startXt][startYt].ch = h0;
  tileArray[startXt][startYt].dh = dh0;
  
  
  //int temp = 0;
  
  while(updateTiles.size() > 0)// && temp < 80) // While there are any Tiles left to update
  {
    //temp += 1;
    for(int i = updateTiles.size()-1; i>=0; i--) // loop backwards for ease of removal of intialized Tiles
    {
      ti = updateTiles.get(i);
      ti.initialized = true; // Tile ti is getting initialized.
      // Set the Tile's color H and B coordinates.
      //ti.ch = h;
      ti.cb = b;
      // Add all uninitialized walkable neighbors to updateTiles
      
      // Get ti's Tile coordinates
      xti = ti.xt;
      yti = ti.yt;
      
      // Check if ti is the winning Tile, update foundTheWinner if so
      if (ti.winning)
      {
        foundTheWinner = true;
      }
      
      // Add an item with some probability
      int numItems = 4; 
      if(random(0,1)<0.05) // Add an item if true
      {
        ti.addItem(int(random(0,numItems)));
        chunkArray[(int)xti / CHUNK_SIZE][(int)yti / CHUNK_SIZE].items.add(ti.theItem);
      }
      
      // U Tile neighbor check
      tu = tileArray[xti][yti-1];
      if(!(tu.wall) && !(tu.initialized) && !(tu.inList))
      { 
        updateTiles.add(tu);
        tu.dh = constrain(ti.dh + drate1 * random(-1, 1), -1, 1);
        tu.ch = mod1(ti.ch + drate2 * tu.dh);
        
        tu.inList = true; 
      }
      
      // R Tile neighbor check
      tr = tileArray[xti+1][yti];
      if(!(tr.wall) && !(tr.initialized) && !(tr.inList))
      { 
        updateTiles.add(tr);
        tr.dh = constrain(ti.dh + drate1 * random(-1, 1), -1, 1);
        tr.ch = mod1(ti.ch + drate2 * tr.dh);
        
        tr.inList = true; 
      }
      
      // D Tile neighbor check
      td = tileArray[xti][yti+1];
      if(!(td.wall) && !(td.initialized) && !(td.inList))
      { 
        updateTiles.add(td);
        td.dh = constrain(ti.dh + drate1 * random(-1, 1), -1, 1);
        td.ch = mod1(ti.ch + drate2 * td.dh);
        
        td.inList = true; 
      }
      
      // L Tile neighbor check
      tl = tileArray[xti-1][yti];
      if(!(tl.wall) && !(tl.initialized) && !(tl.inList))
      { 
        updateTiles.add(tl);
        tl.dh = constrain(ti.dh + drate1 * random(-1, 1), -1, 1);
        tl.ch = mod1(ti.ch + drate2 * tl.dh);
        
        tl.inList = true; 
      }
      
      // Add neighboring maze Tile coordinates to the mazeNeighbors[][] array.
      for(int dx=-1; dx < 2; dx++)
      {
        for(int dy=-1; dy < 2; dy++)
        {
          if(!(dy==0 && dx == 0)) // don't check yourself!
          {
            tn = tileArray[xti + dx][yti + dy];
            
            if(!(tn.wall)) // if this neighbor is a maze Tile... 
            { // ...add its coordinates to mazeNeighbors
              
              if(dx != 0 && dy!=0) // don't add diagonal neighbors without also having a connecting URDL neighbor
              {
                if (!(tileArray[xti + dx][yti].wall) && !(tileArray[xti][yti + dy].wall))
                {
                  ti.mazeNeighbors[0][ti.numNeighbors] = xti + dx;
                  ti.mazeNeighbors[1][ti.numNeighbors] = yti + dy;
                  ti.numNeighbors += 1; // and increment numNeighbors
                }
              }
              else // always add URDL neighbors
              {
                ti.mazeNeighbors[0][ti.numNeighbors] = xti + dx;
                ti.mazeNeighbors[1][ti.numNeighbors] = yti + dy;
                ti.numNeighbors += 1; // and increment numNeighbors
              }
            }
          }
        }
      }
      
      // Check to see if this maze Tile forms the upper-left corner of a 2x2 square of Tiles.
      ti.startsRoom = ti.isNeighbor(tileArray[ti.xt+1][ti.yt]) && ti.isNeighbor(tileArray[ti.xt+1][ti.yt+1]) && ti.isNeighbor(tileArray[ti.xt][ti.yt+1]);
      
      updateTiles.remove(i); // Remove the current Tile from the update list.      
    }
  }  

return foundTheWinner;  
}
