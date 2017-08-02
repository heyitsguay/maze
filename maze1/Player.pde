// This file uses the following global variables defined in maze:
// TILE_SIZE - size of each drawn Tile in pixels.
// numTilesX - number of world Tiles in the x direction.
// numTilesY - number of world Tiles in the y direction.
// tileArray - the 2D array of all world Tiles.
// godMode
// t

class Player
// Here, treating Player basically as a moving circle.
{
  int xt; // x Tile coordinate of the Tile containing the Player's upper-left corner.
  int yt; // y Tile coordinate of the Tile containing the Player's upper-left corner.
  
  float xw; // x pixel coordinate of the Player's upper-left corner.
  float yw; // y pixel coordinate of the Player's upper-left corner.
  
  float vx; // x velocity (in pixels/frame)
  float vy; // y velocity (in pixels/frame)
  float v; // magnitude of the velocity (speed)
  
  float maxv; // maximum velocity
  float baseFriction; // base friction
  
  
  float xd; // World x coordinate of the center of the Tile the Player is on.
  float yd; // World y coordinate of the center of the Tile the Player is on.
  float r; // Radius of the Player's drawn circle
  float d; // Diameter of the Player's drawn circle
  
  float ch; // Player color hue parameter.
  float cs; // Player color saturation parameter.
  float cb; // Player color brightness parameter.
  
  float speed; // player speed
  
  float bness; // Player brightness. Can be arbitrarily large, though actual HSB brightness caps at 1. Player sets the cb of the Tile it's on to bness at each iteration.
  float bnessactive; // The frame-to-frame brightness varies according to additional parameters, culminating in this value actually used in the brightness calculation.
  
  // The light flickers faster and harder as the Player moves. 
  float beatRate;
  float beatRateMin;
  float beatRateMax;
  float dbRate;
  
  float beatSize;
  float beatSizeMax;
  float dbSize;
  
  // Let the ability to make a burst of light by clicking be a rechargey thing
  float charge;
  float minCharge;
  float maxCharge;
  float chargeCost; // The charge variable diminishes exponentially with this rate parameter
  float chargeRecharge; // Governs how quickly charge recharges.
  
  boolean justCollided; // true
  Player(float xw_, float yw_, float ch_, float cs_, float cb_, float bness_)
  {
    xw = xw_;
    yw = yw_;
    
    xt = int(xw) / TILE_SIZE;
    yt = int(yw) / TILE_SIZE;
    
    vx = 0;
    vy = 0;
    v = 0;
    
    maxv = 10;
    baseFriction = 0; // Total friction is the sum of baseFriction and each Tile's
    
    r = TILE_SIZE / 4;
    d = 2 * r;
    xd = xw + r;
    yd = yw + r;
    
    ch = ch_;
    cs = cs_;
    cb = cb_;
    bness = bness_;
    bnessactive = bness;
    
    speed = 5;
    
    beatRateMin = 0.2;
    beatRateMax = 5;
    beatRate = beatRateMin;
    dbRate = (beatRateMax - beatRateMin) / (60 * 3);
    
    beatSize = 0;
    beatSizeMax = 0.995;
    dbSize = beatSizeMax / (60 * 8);
    
    minCharge = pow(10,-8);
    maxCharge = 0.2;
    chargeCost = 0.90;
    chargeRecharge = 1.001;
    charge = maxCharge;
    
  }
  
  void move(float dx, float dy)
  {
    // Compute tentative new location Tile
    float xw0, xw1, yw0, yw1;
    if(godMode) // walls don't stop you!
    {
      xw0 = xw + 1 * speed * dx;
      xw1 = xw0 + d;
      yw0 = yw + 1 * speed * dy;
      yw1 = yw0 + d;
    }
    else
    {
      float[] np = tileCollisionCheck(dx, dy);
      
      xw0 = np[0];
      yw0 = np[1];
      //xw0 = xw + speed * dx;
      xw1 = xw0 + d;
      //yw0 = yw + speed * dy;
      yw1 = yw0 + d;
    }
    
    //// And the coordinates of the Tiles they're in
    //int xt0 = int(xw0) / TILE_SIZE;
    //int xt1 = int(xw1) / TILE_SIZE;
    //int yt0 = int(yw0) / TILE_SIZE;
    //int yt1 = int(yw1) / TILE_SIZE;
    
    //// See if we've collided with a blocked Tile.
    //boolean blocked00 = tileArray[xt0][yt0].blocked;
    //boolean blocked01 = tileArray[xt1][yt0].blocked;
    //boolean blocked10 = tileArray[xt0][yt1].blocked;
    //boolean blocked11 = tileArray[xt1][yt1].blocked;
    
    //// Check for collisions
    //if(dx>0) // moved right
    //{
    //  if(blocked01 || blocked11) // collided to the right
    //  {
    //    xw0 = xt1 * TILE_SIZE - d - 1;
    //  }
    //}
    //else if(dx<0) // moved left
    //{
    //  if(blocked00 || blocked10) // collided to the left
    //  {
    //    xw0 = xt0 * TILE_SIZE + TILE_SIZE;
    //  }
    //}
    
    //if(dy>0) // moved down
    //{
    //  if(blocked10 || blocked11)
    //  {
    //    yw0 = yt1 * TILE_SIZE - d - 1;
    //  }
    //}
    //else if(dy<0) // moved up
    //{
    //  if(blocked00 || blocked01)
    //  {
    //    yw0 = yt0 * TILE_SIZE + TILE_SIZE;
    //  }
    //}
    
    // Move if xw or yw has changed (or we're in god mode).
    if (godMode || xw != xw0 || yw != yw0)
    {
      // beats updates
      beatSize = min(beatSizeMax, beatSize + 0.45 * dbSize);
      beatRate = min(beatRateMax, beatRate + 0.2 * dbRate);
      
      // the rest
      xw = xw0;
      yw = yw0;
      xt = int(xw) / TILE_SIZE;
      yt = int(yw) / TILE_SIZE;
      xd = xw + r;
      yd = yw + r;
      
      // grab any Items we've moved onto.
      if(tileArray[xt][yt].itemHere)
      {
        grab(tileArray[xt][yt]);
      }
    }    
  }
  
  //////////////////////////////////////////////////////////////////////////////
  float[] tileCollisionCheck(float dx, float dy)
  {
    // Behavior will probably get weird at speeds exceeding wbb pixels/frame.
    
    // Return the new Entity (x,y) in this array.
    float[] newPosition = {0,0};
    
    // Calculate the coordinates of the Entity's 4 corners in the tentative new position.
    float xw0 = xw + speed * dx;
    float xw1 = xw0 + d;
    float yw0 = yw + speed * dy;
    float yw1 = yw0 + d;
    
    // An Entity can intersect 1, 2, or 4 Tiles, depending on whether the x coordinates of the Entity's corners
    // are in the same Tile and whether the y coordinates are in the same Tile. Track this to help collision resolution.
    boolean twoTilesX = false;
    boolean twoTilesY = false;
    
    // The Tile x coordinates of the Tiles containing the Entity's corners.
    int xt0 = int(xw0) / TILE_SIZE;
    int xt1 = int(xw1) / TILE_SIZE;
    
    // If xt0 != xt1, two different x Tile coordinates needed.
    if(xt0 != xt1)
    {
      twoTilesX = true;
    }
    
    // The Tile y coordinates of the Tiles containing the Entity's corners.
    int yt0 = int(yw0) / TILE_SIZE;
    int yt1 = int(yw1) / TILE_SIZE;    
    
    // If yt0 != yt1, two different y Tile coordinates needed.
    if(yt0 != yt1)
    {
      twoTilesY = true;
    }
    
    newPosition[0] = xw0;
    newPosition[1] = yw0;
    
    // Single Tile collision check
    if(!twoTilesX && !twoTilesY)
    {
      
      if(tileArray[xt0][yt0].blocked)
      {
        // new Tile is blocked, just stay in the previous position.
        newPosition[0] = xw;
        newPosition[1] = yw;
      }
    }
    
    // Two Tile collision check, vertical separation.
    else if(twoTilesX && !twoTilesY)
    {
      if(tileArray[xt0][yt0].blocked)
      {
        // Blocked left. Shift right.
        newPosition[0] = xt1 * TILE_SIZE + 0.0001;
      }
      else if(tileArray[xt1][yt0].blocked)
      {
        // Blocked right, shift left.
        newPosition[0] = xw0 - (xw1 - xt1 * TILE_SIZE + 0.0001);
      }
    }
    
    // Two Tile collision check, horizontal separation.
    else if(!twoTilesX && twoTilesY)
    {      
      if(tileArray[xt0][yt0].blocked)
      {
        // Blocked top. Shift down.
        newPosition[1] = yt1 * TILE_SIZE + 0.0001;
      }
      else if(tileArray[xt0][yt1].blocked)
      {
        // Blocked bottom. Shift up.
        newPosition[1] = yw0 - (yw1 - yt1 * TILE_SIZE + 0.0001);
      }
    }
    
    // Four Tile collision check.
    else
    {
      // Check for collisions with blocked Tiles.
      boolean blocked00 = tileArray[xt0][yt0].blocked;
      boolean blocked01 = tileArray[xt0][yt1].blocked;
      boolean blocked10 = tileArray[xt1][yt0].blocked;
      boolean blocked11 = tileArray[xt1][yt1].blocked;
      
      // Check 1-block intersections.
      
      
      // Upper-left ********
      if(blocked00 && !blocked01 && !blocked10 && !blocked11)
      {
        float collisionWidth = xt1 * TILE_SIZE - xw0;
        float collisionHeight = yt1 * TILE_SIZE - yw0;
        boolean widthGreaterThanHeight = collisionWidth >= collisionHeight;

        if(!widthGreaterThanHeight && dx < 0)
        {
          newPosition[0] = xt1 * TILE_SIZE + 0.0001;
        }
        else if(widthGreaterThanHeight && dy < 0)
        {
          newPosition[1] = yt1 * TILE_SIZE + 0.0001;
        }
      }
      
      // Lower-left ********
      else if(!blocked00 && blocked01 && !blocked10 && !blocked11)
      {
        float collisionWidth = xt1 * TILE_SIZE - xw0;
        float collisionHeight = yw1 - yt1 * TILE_SIZE;
        boolean widthGreaterThanHeight = collisionWidth >= collisionHeight;
        
        if(!widthGreaterThanHeight && dx < 0)
        {
          newPosition[0] = xt1 * TILE_SIZE + 0.0001;
        }
        else if(widthGreaterThanHeight && dy > 0)
        {
          newPosition[1] = yw0 - (yw1 - yt1 * TILE_SIZE + 0.0001);
        }
      }
      
      // Upper-right ********
      else if(!blocked00 && !blocked01 && blocked10 && !blocked11)
      {
        float collisionWidth = xw1 - xt1 * TILE_SIZE;
        float collisionHeight = yt1 * TILE_SIZE - yw0;
        boolean widthGreaterThanHeight = collisionWidth >= collisionHeight;
        
        if(!widthGreaterThanHeight && dx > 0)
        {
          newPosition[0] = xw0 - (xw1 - xt1 * TILE_SIZE + 0.0001);
        }
        else if(widthGreaterThanHeight && dy < 0)
        {
          newPosition[1] = yt1 * TILE_SIZE + 0.0001;
        }
      }
      
      // Lower-right ********
      else if(!blocked00 && !blocked01 && !blocked10 && blocked11)
      {
        float collisionWidth = xw1 - xt1 * TILE_SIZE;
        float collisionHeight = yw1 - yt1 * TILE_SIZE;
        boolean widthGreaterThanHeight = collisionWidth >= collisionHeight;
        
        if(!widthGreaterThanHeight && dx > 0)
        {
          newPosition[0] = xw0 - (xw1 - xt1 * TILE_SIZE + 0.0001);
        }
        else if(widthGreaterThanHeight && dy > 0)
        {
          newPosition[1] = yw0 - (yw1 - yt1 * TILE_SIZE + 0.0001);
        }
      }
      
      // Two or more blocked Tiles ********
      else
      {    
        // Vertical blockage on the left
        if(blocked00 && blocked01)
        {
          newPosition[0] = xt1 * TILE_SIZE + 0.0001;
        }
        
        // vertical blockage on the right
        else if(blocked10 && blocked11)
        {
          newPosition[0] = xw0 - (xw1 - xt1 * TILE_SIZE + 0.0001);
        }
        
        // horizontal blockage on top
        if(blocked00 && blocked10)
        {
          newPosition[1] = yt1 * TILE_SIZE + 0.0001;
        }
        
        // horizontal blockage on bottom
        if(blocked01 && blocked11)
        {
          newPosition[1] = yw0 - (yw1 - yt1 * TILE_SIZE + 0.0001);
        }
      }
    }
    
    // Constrain each Entity to lie between the second and second-to-last Tiles.
    newPosition[0] = constrain(newPosition[0], TILE_SIZE, (numTilesX - 2) * TILE_SIZE);
    newPosition[1] = constrain(newPosition[1], TILE_SIZE, (numTilesY - 2) * TILE_SIZE);
    return newPosition;
  }
  
  void display(float xscreen, float yscreen)
  {
    // update bnessactive
    bnessactive = bness + 0.97 * (bnessactive - bness);
    
    // update the beat variables
    beatSize = max(0, beatSize - 0.2 * dbSize);
    beatRate = max(beatRateMin, beatRate - 0.05 * dbRate);    
    
    // update charge
    charge = min(maxCharge, charge * chargeRecharge);
    
    // update the Player's Tile's desat vaue
    //Tile aTile = tileArray[xt][yt];
    //aTile.desat = aTile.desat + aTile.desatRate * aTile.desat * (1 - aTile.desat);
    //println(aTile.desat);
    
    // and the rest
//    float xrelative = xd - xscreen;
//    float yrelative = yd - yscreen;
    float xrelative = xw - xscreen;
    float yrelative = yw - yscreen;
    //stroke(0, 0, 0);
    float strokeAlpha = 0.8 * min(1, (bnessactive - bness)/10);
    stroke(0.6, 0.9, 1, strokeAlpha);
    strokeWeight(4);

    fill(constrain(ch,0,1), constrain(cs,0,1), constrain(cb,0,1), 0.5);
    //ellipse(xrelative, yrelative, 2*r, 2*r);
    rect(xrelative, yrelative, d, d);
  }
  
  void grab(Tile theTile)  
  {
    switch(theTile.theItem.id)
    {
      case 0: // Restore charge item
        charge = min(maxCharge, charge + maxCharge/6);
      break;
      
      case 1: // bness boost item
        bness = min(500, 1.24*bness);
        break;
        
      case 2: // max charge boost item
        maxCharge *= 1.28; // grow slightly faster than bness
        break;
        
      case 3: // slow charge loss item
        chargeCost += 0.06 * (1-chargeCost);
      
    }
    theTile.itemHere = false;  
  }
  
}
  