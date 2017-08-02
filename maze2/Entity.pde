// Mnemonic variable names for Entity orientations
final char O_U = 0;
final char O_UR = 1;
final char O_R = 2;
final char O_DR = 3;
final char O_D = 4;
final char O_DL = 5;
final char O_L = 6;
final char O_UL = 7;

// Mnemonic variable names for Entity alignments
final char A_FRIEND = 0;
final char A_NEUTRAL = 1;
final char A_HOSTILE = 2;

class Entity
{
  // width and height of the Entity's image box.
  float w;
  float h;
  
  // Entity mass.
  float mass;
  
  // Position x and y (World) coordinates (upper-left hand corner of the image box).
  float x;
  float y;
  
  // x and y Tile coordinates of the upper-left corner of Entity's image box.
  int xt;
  int yt;
  
  // x and y Chunk coordinates of the upper-left corner of the Entity's image box.
  int xc;
  int yc;
  
  // Center World coordinates.
  float xcenter;
  float ycenter;
  
  // Center Tile coordinates.
  int xtcenter;
  int ytcenter;
  
  // Velocity x and y coordinates.
  float vx;
  float vy;
  float vmax; // maximum magnitude of vx or vy (so max speed is sqrt(2)*vmax).
  
  // Acceleration x and y coordinates.
  float ax;
  float ay;
  float amax;
  
  // Entity's contribution to friction.
  float friction;
  
  // Allow the bounding box to be (slightly) smaller than the image box.
  float boundingBoxOffset; 
  
  // Last side of the Entity that resolved an Entity-Tile collision. Initialize to whatever.
  char lastResolutionSide = D_UP;
  
  float xbb, ybb; // Entity position (x,y) World coordinates, offset by boundingBoxOffset.
  float wbb, hbb; // Entity bounding box width and height.
  
  float xbbLast, ybbLast; // Entity bounding box (x,y) World coordinates in the previous frame. 
  int xtLast, ytLast; // Tile coordinates of bounding box top-left corner in the previous frame.
  int xcLast, ycLast; // Chunk coordinates of bounding box top-left corner in the previous frame.

  // True if this Entity has collided with something during this frame.
  boolean justCollided = false;
  
  // HSB triplet of Entity color values, range [0,1].
  float c_h, c_s, c_b;

  // If ghost, this Entity passes through other Entities and blocked Tiles (no collisions).
  boolean ghost;  
  
  // If fixed, never update position
  boolean fixed;
  
  // If dead, eventually add a routine to handle the removal of the entity.
  boolean dead = false;
  
  // Orientation, determined by difference between present and last position.
  char orientation = O_D;
  
  // Tracks which frame of the Entity's animation is being displayed.
  float animationState = 0;
  
  // How many frames to stay in each state.
  int framesPerState = 8;
  
  // Entity alignment: Friendly (A_FRIEND), Neutral (A_NEUTRAL), Hostile (A_HOSTILE).
  char alignment = A_NEUTRAL;
  
  ////////////////////////////////////////////////////////////////////////////////
  Entity(
    float w_,
    float h_,
    float boundingBoxOffset_,
    float mass_,
    float x_,
    float y_,
    float vx_,
    float vy_,
    float vmax_,
    float ax_,
    float ay_,
    float amax_,
    float friction_,
    float c_h_,
    float c_s_,
    float c_b_,
    boolean ghost_,
    boolean fixed_
    )
    {
      w = w_;
      h = h_;
      
      boundingBoxOffset = boundingBoxOffset_;
      
      mass = mass_;
      
      x = x_;
      y = y_;

      xbb = x + boundingBoxOffset;
      ybb = y + boundingBoxOffset;
      wbb = w - 2 * boundingBoxOffset;
      hbb = h - 2 * boundingBoxOffset;

      xt = int(xbb / TILE_SIZE);
      yt = int(ybb / TILE_SIZE);
      xc = int(xbb / chunkPix);
      yc = int(ybb / chunkPix);
      
      xbbLast = xbb;
      ybbLast = ybb;
      
      xtLast = xt;
      ytLast = yt;
      
      xcLast = xc;
      ycLast = yc;
      
      xcenter = x + w / 2; 
      ycenter = y + w / 2;
      
      xtcenter = int(xcenter / TILE_SIZE);
      ytcenter = int(ycenter / TILE_SIZE);
      
      vx = vx_;
      vy = vy_;
      vmax = vmax_;
      ax = ax_;
      ay = ay_;
      amax = amax_;
      friction = friction_;
      c_h = c_h_;
      c_s = c_s_;
      c_b = c_b_;
      ghost = ghost_;
      fixed = fixed_;
      
      // Add to Tile and Chunk entityLists.
      tiles[xt][yt].entityList.add(this);
      chunks[xc][yc].entityList.add(this);
    }
    
  ////////////////////////////////////////////////////////////////////////////////////
  void update()
  {
    // Overwritten by derived classes.
    updatePhysics();
  }
    
  ////////////////////////////////////////////////////////////////////////////////////
  void updatePhysics()
  {
    if(!fixed)
    {
      // Add acceleration and friction contributions to velocity.
      vx = constrain(vx + dt * (ax - sign(vx) * friction), -vmax, vmax);
      vy = constrain(vy + dt * (ay - sign(vy) * friction), -vmax, vmax);
      
      // If vx or vy are very small, threshold to 0.
      float vcutoff = 0.001;
      if(abs(vx) < vcutoff)
      {
        vx = 0;
      }
      if(abs(vy) < vcutoff)
      {
        vy = 0;
      }
    
      // Zero out force.
      ax = 0;
      ay = 0;
    
      if(vx != 0 || vy != 0 || ax != 0 || ay != 0)
      {
        move(dt * vx, dt * vy);
      }
    }
  }
  
  //////////////////////////////////////////////////////////////////////////////////////
  void display()
  {
    noStroke();
    pushMatrix();
    translate(-screenX, -screenY);
    
    // For now just draw a rectangle with a uniform fill.
    fill(c_h, c_s, c_b);
    //stroke(c_h, c_s, c_b);
    //strokeWeight(1);
    rect(x, y, w, h); 
    
    popMatrix();
  }
  
  //////////////////////////////////////////////////////////////////////////////////////
  void display2()
  {
    float xsheet0;
    float xsheet1;
    float ysheet0;
    float ysheet1;
    boolean flipped = false;
    
    if(orientation == O_L || orientation == O_DR || orientation == O_UL)
    {
      flipped = true;
    }
    
    if(orientation == O_D)
    {
      ysheet0 = 0;
    }
    else if(orientation == O_R || orientation == O_L)
    {
      ysheet0 = 25;
    }
    else if(orientation == O_U)
    {
      ysheet0 = 50;
    }
    else if(orientation == O_DR || orientation == O_DL)
    {
      ysheet0 = 75;
    }
    else //if(orientation == O_UR || orientation == O_UL)
    {
      ysheet0 = 100;
    }
    
    ysheet1 = ysheet0 + 23;
    
    xsheet0 = floor(animationState) * 17;
    
    if(flipped)
    {
      xsheet1 = xsheet0;
      xsheet0 = xsheet1 + 15;
    }    
    else
    {
      xsheet1 = xsheet0 + 15;
    }
    
    noStroke();
    pushMatrix();
    translate(-screenX, -screenY);
    
    beginShape();
    texture(playerSheet);
    vertex(x, y, xsheet0, ysheet0);
    vertex(x + w, y, xsheet1, ysheet0);
    vertex(x + w, y + h, xsheet1, ysheet1);
    vertex(x, y+h, xsheet0, ysheet1);
    endShape();
    
    popMatrix();
    
  }
  
  //////////////////////////////////////////////////////////////////////////////////////
  void tileListCheck()
  {
    // Called during move(). Checks to see if a new position will change which Tile the
    // Entity is in, and updates Tile entityLists if so.
    
    if(xtLast != xt || ytLast != yt)
    {
      tiles[xtLast][ytLast].entityList.remove(this);
      tiles[xt][yt].entityList.add(this);
    }
  }
  
  //////////////////////////////////////////////////////////////////////////////////////
  void chunkListCheck()
  {
    // Called during move(). Checks to see if a new position will change which Chunk the
    // Entity is in, and updates Chunk entityLists if so.
    
    if(xcLast != xc || ycLast != yc)
    {
      chunks[xcLast][ycLast].entityList.remove(this);
      chunks[xc][yc].entityList.add(this);
    }
  }
  
  //////////////////////////////////////////////////////////////////////////////////////
  void move(float dx, float dy)
  {
    float[] newPosition = {0,0};
    
    if(ghost) // No collisions for ghosts!
    {
      newPosition[0] = xbb + dx;
      newPosition[1] = ybb + dy;
    }
    else // Check for collisions.
    {
      newPosition = tileCollisionCheck(dx, dy);
    }
    
    // Save previous position variable values.
    xbbLast = xbb;
    ybbLast = ybb;
    xtLast = xt;
    ytLast = xt;
    xcLast = xc;
    ycLast = yc;
    
    // Update position variables.
    xbb = newPosition[0];
    ybb = newPosition[1];
    
    x = xbb - boundingBoxOffset;
    y = ybb - boundingBoxOffset;
    
    // Animate the Entity.
    animate();
    
    // Check to see if newPosition changes which Tile and/or Chunk the Entity is in.
    tileListCheck();
    chunkListCheck();
    
    
    // Update xt and yt.
    xt = int(x / TILE_SIZE);
    yt = int(y / TILE_SIZE);
    
    // Update xc and yc.
    xc = int(x / chunkPix);
    yc = int(y / chunkPix);
    
    xcenter = x + w / 2;
    ycenter = y + h / 2;
    
    xtcenter = int(xcenter / TILE_SIZE);
    ytcenter = int(ycenter / TILE_SIZE);
  }
  
  //////////////////////////////////////////////////////////////////////////////
  float[] tileCollisionCheck(float dx, float dy)
  {
    // Behavior will probably get weird at speeds exceeding wbb pixels/frame.
    
    // Return the new Entity (x,y) in this array.
    float[] newPosition = {0,0};
    
    // Calculate the coordinates of the Entity's 4 corners in the tentative new position.
    float xw0 = xbb + dx;
    float xw1 = xw0 + wbb;
    float yw0 = ybb + dy;
    float yw1 = yw0 + hbb;
    
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
      
      if(tiles[xt0][yt0].blocked)
      {
        // new Tile is blocked, just stay in the previous position.
        newPosition[0] = xbb;
        newPosition[1] = ybb;
      }
    }
    
    // Two Tile collision check, vertical separation.
    else if(twoTilesX && !twoTilesY)
    {
      if(tiles[xt0][yt0].blocked)
      {
        // Blocked left. Shift right.
        newPosition[0] = xt1 * TILE_SIZE + 0.0001;
      }
      else if(tiles[xt1][yt0].blocked)
      {
        // Blocked right, shift left.
        newPosition[0] = xw0 - (xw1 - xt1 * TILE_SIZE + 0.0001);
      }
    }
    
    // Two Tile collision check, horizontal separation.
    else if(!twoTilesX && twoTilesY)
    {      
      if(tiles[xt0][yt0].blocked)
      {
        // Blocked top. Shift down.
        newPosition[1] = yt1 * TILE_SIZE + 0.0001;
      }
      else if(tiles[xt0][yt1].blocked)
      {
        // Blocked bottom. Shift up.
        newPosition[1] = yw0 - (yw1 - yt1 * TILE_SIZE + 0.0001);
      }
    }
    
    // Four Tile collision check.
    else
    {
      // Check for collisions with blocked Tiles.
      boolean blocked00 = tiles[xt0][yt0].blocked;
      boolean blocked01 = tiles[xt0][yt1].blocked;
      boolean blocked10 = tiles[xt1][yt0].blocked;
      boolean blocked11 = tiles[xt1][yt1].blocked;
      
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
    newPosition[0] = constrain(newPosition[0], TILE_SIZE, (tilesX - 2) * TILE_SIZE);
    newPosition[1] = constrain(newPosition[1], TILE_SIZE, (tilesY - 2) * TILE_SIZE);
    return newPosition;
  }
  
  //////////////////////////////////////////////////////////////////////////////
  void animate()
  {
    char orientationNew;
    float dx = xbb - xbbLast;
    float dy = ybb - ybbLast;
    
    if(dx == 0 && dy == 0)
    {
      // No movement. Same orientation, reset animationState.
      
      orientationNew = orientation;
      
      // reset to this instead of 0 so that there is a change in animation on the first frame of a movement.
      animationState = float(framesPerState - 1) / framesPerState;
    }
    else 
    {
      if(dx > 0 && dy == 0)
      {
        // Motion right.
        orientationNew = O_R;
      }
      else if(dx < 0 && dy == 0)
      {
        // Motion left.        
        orientationNew = O_L;
      }
      else if(dx == 0 && dy > 0)
      {
        // Motion down.       
        orientationNew = O_D;
      }
      else if(dx == 0 && dy < 0)
      {
        // Motion up.        
        orientationNew = O_U;
      }
      else if(dx > 0 && dy > 0)
      {
        // Motion down and right.
        orientationNew = O_DR;
      }
      else if(dx < 0 && dy > 0)
      {
        // Motion down and left.
        orientationNew = O_DL;
      }
      else if(dx > 0 && dy < 0)
      {
        // Motion up and right.
        orientationNew = O_UR;
      }
      else
      {
        // Motion up and left.
        orientationNew = O_UL;
      }
      
      // Update animation state.
      animationStateUpdate(orientationNew);
    }
    
      
  }
  
  //////////////////////////////////////////////////////////////////////////////
  void animationStateUpdate(char orientation_)
  {
    if(orientation_ != orientation)
    {
      // If orientation has changed, reset animation state.
        
      animationState = 1;
      orientation = orientation_;
    }
    else
    {      
      int numStates;
      if(orientation == O_U || orientation == O_R || orientation == O_D || orientation == O_L)
      {
        numStates = 8;
      }
      else if(orientation == O_DL || orientation == O_DR)
      {
        numStates = 4;
      }
      else
      {
        numStates = 5;
      }
      
      // Advance animation state.
      animationState = 1 + (((animationState-1) + 1./framesPerState) % numStates);
    }
  }
  
  //////////////////////////////////////////////////////////////////////////////
  void addS(float dx_, float dy_)
  {
    // Additively modify the Entity's position.
    
    x = constrain(x + dx_, 1, pixWidth - TILE_SIZE - w);
    y = constrain(y + dy_, 1, pixHeight - TILE_SIZE - h);
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  void addV(float dvx_, float dvy_)
  {
    // Additively modify the Entity's velocity.
    
    vx = constrain(vx + dvx_, -vmax, vmax);
    vy = constrain(vy + dvy_, -vmax, vmax);
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  void addP(float dpx_, float dpy_)
  {
    // Additively modify the Entity's momentum.
    // Same as addV() but weighted by mass.
    
    if(mass > 0)
    {
      // divide dp through by mass
      addV(dpx_/mass, dpy_/mass);
    }
    else
    {
      // mass is 0 or negative. Just treat it
      // as if mass = 1.
      addV(dpx_, dpy_);
    }
  }
  
  //////////////////////////////////////////////////////////////////////////////
  void addA(float dax_, float day_)
  {
    // Additively modify the Entity's acceleration.
    
    ax = constrain(ax + dax_, -amax, amax);
    ay = constrain(ay + day_, -amax, amax);
  }
  
  //////////////////////////////////////////////////////////////////////////////
  void addF(float dfx_, float dfy_)
  {
    // Apply an additive force to the Entity.
    // Same as addA() but weighted by mass.
    
    if(mass > 0)
    {
      // divide dp through by mass
      addA(dfx_/mass, dfy_/mass);
    }
    else
    {
      // mass is 0 or negative. Just treat it
      // as if mass = 1.
      addA(dfx_, dfy_);
    }
  }
  
}
