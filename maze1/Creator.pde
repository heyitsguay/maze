// This file uses the following global variables defined in maze:
// TILE_SIZE - size of each drawn Tile in pixels.
// numTilesX - number of world Tiles in the x direction.
// numTilesY - number of world Tiles in the y direction.
// tileArray - the 2D array of all world Tiles.
// winXt - x Tile coordinate of the winning Tile.
// winYt - y Tile coordinate of the winning Tile.

class Creator
// Creates the traversable portions of the maze.
{
  int xt;
  int yt;
  int xtnew;
  int ytnew;
  int xw;
  int yw;
  float winBias; // Probability of turning towards the winning Tile. When 1, always seeks
  int lengthMean; // Corridor lengths are chosen randomly from a normal distribution with this mean.
  int lengthSD; // Corridor lengths are chosen randomly from a normal distribution with this standard deviation.
  int lengthMin; // Lower bound on Corridor length, to prevent crappiness.
  float avoidBias; // Probability of avoiding connecting to an existing hallway. When 1, totally self-avoiding.
  int currentDirection; // 0 for up, 1 for right, 2 for down, 3 for left
  int movesLeft; // Number of moves remaining in the current direction before picking a new one.
  int lifeTime; // Number of updates the Creator performs before being deleted.
  int lifeRemaining; // Number of updates remaining for the Creator.
  
  Creator(int xt_, int yt_, float winBias_, int lengthMean_, int lengthSD_, int lengthMin_, float avoidBias_, int currentDirection_, int lifeTime_)
  {
    xt = xt_; // Initial x position, Tile coordinates
    yt = yt_; // Initial y position Tile coordinates
    xtnew = xt;
    ytnew = yt;
    xw = xt * TILE_SIZE;
    yw = yt * TILE_SIZE;
    winBias = winBias_;
    lengthMean = lengthMean_;
    lengthSD = lengthSD_;
    lengthMin = lengthMin_;
    avoidBias = avoidBias_;
    currentDirection = currentDirection_; // Initial movement direction.
    movesLeft = max(int(lengthSD * randomGaussian() + lengthMean), lengthMin);
    
    lifeTime = lifeTime_;
    lifeRemaining = lifeTime;
    
    // Set the Creator initial position Tile to a walkway. Assumes xt_, yt_ aren't on the tileArray boundary.
    changeTile();
  }
  
  void move()
  {
    lifeRemaining -= 1;
    
    if(movesLeft == 0) // Out of moves, choose new currentDirection.
    {
      update(false); // Update currentDirection, new value may be the same as the previous.
    }
      
    switch(currentDirection)
    {
      case 0: // Move up
        xtnew = xt; 
        ytnew = yt-1;
        break;
      case 1: // Move right
        xtnew = xt+1; 
        ytnew = yt;
        break;
      case 2: // Move down
        xtnew = xt;
        ytnew = yt+1;
        break;
      case 3: // Move left
        xtnew = xt-1;
        ytnew = yt;
        break;
    }
    
    // Check to see whether the new move puts us on the tileArray boundary, avoid if so.
    if(xtnew == 0 || xtnew > numTilesX-2 || ytnew == 0 || ytnew >numTilesY-2)
    {
      update(true); // Update currentDirection, new value can't be the same as the previous.
      return;
    }
    
    if(tileArray[xtnew][ytnew].borders > 1) // If true, new Tile borders another existing walkway.
    {
      if(random(1.0) < avoidBias) // Avoid this tile
      {
        update(true); // Update currentDirection, new value can't be the same as the previous.
        return;
      }

    }
    
    // If move() hasn't returned by now, move the Creator to the new location.
    xt = xtnew;
    yt = ytnew;
    
    movesLeft -= 1;
    
    // If true, this is a newly-formed walkable tile. Increment the borders variable of neighboring wall Tiles
    // and make the current location's Tile walkable.
    if(tileArray[xt][yt].wall) 
    {
      changeTile();
    }
  }    
  
  void update(boolean avoidPrevDirection)  
  {
    // create probability distribution over the possible new motion directions
    int prevDirection = currentDirection;
    
    // Ultimately this will contain a probability distribution over the possible new directions, but we won't
    // normalize it until the last step in its calculation.
    float[] newDirectionPs = {1.0, 1.0, 1.0, 1.0};
    
    float biasAmount = (winBias - 0.5) * 20;
    
    if(winXt > xt) // Winning Tile is to the right.
    {
      newDirectionPs[1] = max(newDirectionPs[1] + biasAmount, 0);
      newDirectionPs[3] = max(newDirectionPs[3] - biasAmount, 0);
    }
    else if(winXt < xt) // Winning Tile is to the left.
    {
      newDirectionPs[1] = max(newDirectionPs[1] - biasAmount, 0);
      newDirectionPs[3] = max(newDirectionPs[3] + biasAmount, 0);
    }
    
    if(winYt < yt) // Winning Tile is up.
    {
      newDirectionPs[0] = max(newDirectionPs[0] + biasAmount, 0);
      newDirectionPs[2] = max(newDirectionPs[2] - biasAmount, 0);
    }
    else if (winYt > yt) // Winning Tile is down.
    {
      newDirectionPs[0] = max(newDirectionPs[0] - biasAmount, 0);
      newDirectionPs[2] = max(newDirectionPs[2] + biasAmount, 0);
    }
    
    if(avoidPrevDirection) // Set probability of keeping the same direction to 0
    {
      newDirectionPs[prevDirection] = 0;
      newDirectionPs[(prevDirection + 2) % 4] += 0.1; // Add a chance of going in the opposite direction to avoid stagnation
    }
    
    // normalize newDirectionPs to create a probability vector
    float pSum = newDirectionPs[0] + newDirectionPs[1] + newDirectionPs[2] + newDirectionPs[3];
    newDirectionPs[0] /= pSum;
    newDirectionPs[1] /= pSum;
    newDirectionPs[2] /= pSum;
    newDirectionPs[3] /= pSum;
    
    // choose the new direction
    float directionDecider = random(1.0);
    if(directionDecider < newDirectionPs[0])
    {
      currentDirection = 0;
    }
    else if(directionDecider < newDirectionPs[0] + newDirectionPs[1])
    {
      currentDirection = 1;
    }
    else if(directionDecider < newDirectionPs[0] + newDirectionPs[1] + newDirectionPs[2])
    {
      currentDirection = 2;
    }
    else
    {
      currentDirection = 3;
    }
    
    // reset movesLeft
    movesLeft = max(int(lengthSD * randomGaussian() + lengthMean), lengthMin);
    
    // make the Creator gradually more self-avoiding
    avoidBias += 0.4 * (1.0 - float(lifeRemaining)/float(lifeTime)) * (1 - avoidBias);
  }
  
  void changeTile()
  {
    // make tileArray[xt][yt] walkable
    tileArray[xt][yt].wall = false;
    tileArray[xt][yt].blocked = false;
    tileArray[xt][yt].borders = 0;
    // Increment the neighboring Tiles' borders variables.
    if(tileArray[xt-1][yt].wall){tileArray[xt-1][yt].borders+=1;}
    if(tileArray[xt+1][yt].wall){tileArray[xt-1][yt].borders+=1;}
    if(tileArray[xt][yt-1].wall){tileArray[xt][yt-1].borders+=1;}
    if(tileArray[xt][yt+1].wall){tileArray[xt][yt+1].borders+=1;}
    // color effects
    tileArray[xt][yt].ch = 1.0;
    tileArray[xt][yt].cs = 1;
    tileArray[xt][yt].cb = 0.06;
    
  }  
    
  }
 
