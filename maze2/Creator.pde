// Mnemonic variable names for the 4 direction values used by Creators.
final char D_UP = 0;
final char D_RIGHT = 1;
final char D_DOWN = 2;
final char D_LEFT = 3;

class Creator
{
  // Creates the traversable portions of the maze.
  
  // Tile coordinates of the Creator.
  int xt, yt;
  
  // World coordinates of the Creator.
  int xw, yw;
  
  // Putative new Tile coordinates used in calculating movement.
  int xtnew, ytnew;
  
  // Angle in [0, 2*PI) relative to the positive x axis. Creator trajectories will be biased
  // towards this direction.
  float directionBias;
  
  // Strength of that trajectory bias, takes values in [0,+Infinity)
  float directionBiasStrength;
  
  // The arbitrary-angle directionBias gets transformed into bias amounts in the four cardinal
  // directions. 
  float biasUp, biasRight, biasDown, biasLeft;
  
  // Can be anything in (-Infinity, +Infinity). Large positive numbers drive the Creator
  // towards the winning Tile. Large negative numbers drive the Creator away from the
  // winning Tile.
  float winBias;
  
  // Corridor lengths are chosen randomly from a normal distribution with this mean.
  float lengthMean; 
  
  // Corridor lengths are chosen randomly from a normal distribution with this standard deviation.
  float lengthSD; 
  
  // Corridor width generated by the Creator.
  int corridorWidth;
  
  // Lower bound on Corridor length.
  int lengthMin; 
  
  // Probability of avoiding connecting to an existing hallway. When 1, totally self-avoiding.
  float avoidProb; 
  
  // The current heading of the Creator: D_UP, D_RIGHT, D_DOWN, D_LEFT for mnemonic ease
  char direction;
  
  // Number of moves remaining in the current direction before picking a new one.
  int movesLeft;
  
  // Number of updates the Creator performs before being deleted.
  int lifeTime;
  
  // Number of updates presently remaining.
  int lifeRemaining;
  
  Creator(
    int xt_, 
    int yt_, 
    float directionBias_, 
    float directionBiasStrength_, 
    float winBias_, 
    float lengthMean_, 
    float lengthSD_, 
    int lengthMin_, 
    int corridorWidth_, 
    float avoidProb_, 
    char direction_, 
    int lifeTime_
    )
  {
    xt = xt_; 
    yt = yt_;
    xtnew = xt;
    ytnew = yt;
    xw = xt * TILE_SIZE;
    yw = yt * TILE_SIZE;
    
    directionBias = directionBias_;
    directionBiasStrength = directionBiasStrength_;
    
    // Decompose the directionBias into biases in the four cardinal directions.
    if(directionBias >= 0 && directionBias < PI / 2)
    {
      // First quadrant angle.
      biasUp = sin(directionBias) * directionBiasStrength;
      biasRight = cos(directionBias) * directionBiasStrength;
      biasDown = 0;
      biasLeft = 0;
    }
    else if(directionBias >= PI / 2 && directionBias < PI)
    {
      // Second quadrant angle.
      biasUp = sin(directionBias) * directionBiasStrength;
      biasRight = 0;
      biasDown = 0;
      biasLeft = - cos(directionBias) * directionBiasStrength;
    }
    else if(directionBias >= PI && directionBias < 3 * PI / 2)
    {
      // Third quadrant angle.
      biasUp = 0;
      biasRight = 0;
      biasDown = - sin(directionBias) * directionBiasStrength;
      biasLeft = - cos(directionBias) * directionBiasStrength;
    }
    else if(directionBias >= 3 * PI / 2 && directionBias < 2 * PI)
    {
      // Fourth quadrant angle.
      biasUp = 0;
      biasRight = cos(directionBias) * directionBiasStrength;
      biasDown = - sin(directionBias) * directionBiasStrength;
      biasLeft = 0;
    }
    
    winBias = winBias_;
    
    lengthMean = lengthMean_;
    lengthSD = lengthSD_;
    lengthMin = lengthMin_;
    corridorWidth = corridorWidth_;
    
    avoidProb = avoidProb_;
    
    direction = direction_;
    
    lifeTime = lifeTime_;
    lifeRemaining = lifeTime;
    
    movesLeft = rollMoves();
  }
  
  /////////////////////////////////////////////////////////////////////////////////////
  void move()
  {
    // Run changeTiles, convert wall Tiles to path Tiles.
    changeTiles(T_WALL, T_PATH);
    
    lifeRemaining -= 1;
    
    if(movesLeft == 0)
    {
      // Out of moves, choose new direction. Can be the same as the old direction.
      update(false);
    }
    
    switch(direction)
    {
      case D_UP: // Move up
        xtnew = xt;
        ytnew = yt - 1;
        break;
      
      case D_RIGHT: // Move right
        xtnew = xt + 1;
        ytnew = yt;
        break;
        
      case D_DOWN: // Move down
        xtnew = xt;
        ytnew = yt + 1;
        break;
        
      case D_LEFT: // Move left
        xtnew = xt - 1;
        ytnew = yt;
        break;
    }
    
    
    if(xtnew == 0 || xtnew > tilesX-2 || ytnew == 0 || ytnew > tilesY-2)
    {
      // Check to see whether the new move puts us on the tileArray boundary, avoid if so.
      
      // Update currentDirection, new value can't be the same as the previous.
      update(true); 
      return;
    }
    
    if(tiles[xtnew][ytnew].neighborList.size() > 1)
    {
      // If true, new Tile borders another existing path Tile besides the one at tiles[xt][yt].
      if(random(1.0) < avoidProb)
      {
        // Avoid this new Tile.
        update(true);
        return;
      }
    }
    
    // If move() hasn't returned by now, move the Creator to the new location.
    xt = xtnew;
    yt = ytnew;
    movesLeft -= 1;
    
    
  }
  
  /////////////////////////////////////////////////////////////////////////////////////
  void update(boolean avoidPrevDirection)
  {
    // Create a new probability distribution over the possible motion directions, and then
    // sample from it.
    
    int prevDirection = direction;
    
    // Ultimately this will contain a probability distribution over the possible new directions, but we won't
    // normalize it until the last step in its calculation.
    float[] newDirectionP = {1.0 + biasUp, 1.0 + biasRight, 1.0 + biasDown, 1.0 + biasLeft};
    
    // Add in winning Tile bias
    if(xtwin > xt) 
    {
      // Winning Tile is to the right
      newDirectionP[D_RIGHT] = max(newDirectionP[D_RIGHT] + winBias, 0);
      newDirectionP[D_LEFT] = max(newDirectionP[D_LEFT] - winBias, 0);
    }
    else if(xtwin < xt) 
    {
      // Winning Tile is to the left
      newDirectionP[D_RIGHT] = max(newDirectionP[D_RIGHT] - winBias, 0);
      newDirectionP[D_LEFT] = max(newDirectionP[D_LEFT] + winBias, 0);
    }
    
    if(ytwin < yt)
    {
      // Winning Tile is up.
      newDirectionP[D_UP] = max(newDirectionP[D_UP] + winBias, 0);
      newDirectionP[D_DOWN] = max(newDirectionP[D_DOWN] - winBias, 0);
    }
    else if(ytwin > yt)
    {
      // Winning Tile is down.
      newDirectionP[D_UP] = max(newDirectionP[D_UP] - winBias, 0);
      newDirectionP[D_DOWN] = max(newDirectionP[D_DOWN] + winBias, 0);
    }
    
    if(avoidPrevDirection)
    {
      // Set the newDirectionP[prevDirection] to 0, add a small chance of going the
      // other way to prevent stagnation.
      newDirectionP[prevDirection] = 0;
      newDirectionP[(prevDirection + 2) % 4] += 0.1;
    }
    
    // Normalize newDirectionPs to create a probability vector.
    float pSum = newDirectionP[0] + newDirectionP[1] + newDirectionP[2] + newDirectionP[3];
    newDirectionP[0] /= pSum;
    newDirectionP[1] /= pSum;
    newDirectionP[2] /= pSum;
    newDirectionP[3] /= pSum;
    
    // Choose the new direction.
    float directionDecider = random(1.0);
    
    if(directionDecider < newDirectionP[0])
    {
      direction = D_UP;
    }
    else if(directionDecider < newDirectionP[0] + newDirectionP[1])
    {
      direction = D_RIGHT;
    }
    else if(directionDecider < newDirectionP[0] + newDirectionP[1] + newDirectionP[2])
    {
      direction = D_DOWN;
    }
    else
    {
      direction = D_LEFT;
    }
    
    // Reset movesLeft.
    movesLeft = rollMoves();
    
    // Make the Creator more self-avoiding
    avoidProb += 0.4 * (1.0 - float(lifeRemaining)/float(lifeTime)) * (1 - avoidProb);
    
  }
  
  /////////////////////////////////////////////////////////////////////////////////////
  void changeTiles(int type0, int type1)
  {
    // Changes all Tiles  of type type0 to type type1, within radius widthRadius of
    // the Creator's location.
    
    int wmin, wmax;
    Tile theTile;
    
    // Left (min) and right (max) boundary Tile coordinates of the current
    // hallway's width.
    wmin = - (corridorWidth - 1) / 2;
    wmax =  int(ceil(float(corridorWidth - 1) / 2.));
    
    // size is perpendicular to the direction of the Creator.
    switch(direction)
    {
      case D_UP:
        // Make sure the changed Tiles stay in the Tile array (plus a 1-Tile border).
        wmin = max(1, xt + wmin) - xt;
        wmax = min(pixWidth-2, xt + wmax) - xt;
        
        for(int i = wmin; i <= wmax; i++)
        {
          theTile = tiles[xt+i][yt];
          
          if(theTile.type == type0) // If type0, change to type1.
          {
            theTile.setType(type1);
          }
        }
        break;
      
      case D_RIGHT:
        // Make sure the changed Tiles stay in the Tile array (plus a 1-Tile border).
        wmin = max(1, yt + wmin) - yt;
        wmax = min(pixHeight-2, yt + wmax) - yt;
        
        for(int i = wmin; i <= wmax; i++)
        {
          theTile = tiles[xt][yt+i];
          
          if(theTile.type == type0)
          {
            theTile.setType(type1);
          }
        }
        break;
        
      case D_DOWN:
        // Make sure the changed Tiles stay in the Tile array (plus a 1-Tile border).
        wmin = xt - min(pixWidth-2, xt - wmin);
        wmax = xt - max(1, xt - wmax);
        
        for(int i = wmin; i <= wmax; i++)
        {
          theTile = tiles[xt-i][yt];
          
          if(theTile.type == type0)
          {
            theTile.setType(type1);
          }
        }
        break;
        
      case D_LEFT:
        // Make sure the changed Tiles stay in the Tile array (plus a 1-Tile border).
        wmin = yt - min(pixHeight-2, yt - wmin);
        wmax = yt - max(1, yt - wmax);
        
        for(int i = wmin; i <= wmax; i++)
        {
          theTile = tiles[xt][yt-i];
          
          if(theTile.type == type0)
          {
            theTile.setType(type1);
          }
        }
        break;
    }
    

  }
  
  /////////////////////////////////////////////////////////////////////////////////////
  int rollMoves()
  {
    // Calculate a random number indicating how far a Creator will
    // move in its present direction before changing course.
    return max(int(lengthSD * randomGaussian() + lengthMean), lengthMin);  
  }
}
  