// Base class
class Entity
{
  // width and height of the Entity's image box
  float w;
  float h;
  
  float mass;
  
  // Position x and y coordinates (upper-left hand corner of the image box)
  float x;
  float y;
  
  // Velocity x and y coordinates
  float vx;
  float vy;
  float vmax; // maximum magnitude of vx or vy (so max speed is sqrt(2)*vmax)
  
  // Acceleration x and y coordinates
  float ax;
  float ay;
  float amax;
  
  // Allow the bounding box to be slightly smaller than the image box.
  float boundingBoxOffset; 

  // 
  boolean justCollided;
  
  // Impulse that each motion per frame imparts (basically, movement speed).
  float dv; 
  
  // Base brightness of the Entity.
  float brtness; 
  
  // Entity health
  float health;
  float maxHealth;
  
  // Entity energy
  float energy;
  float maxEnergy;
  
  // If ghost, this Entity passes through other Entities and blocked Tiles (no collisions).
  boolean ghost;
  
  
  Entity(float w_, float h_, float mass_, float x0, float y0, float vx0, float vy0,  float boundingBoxOffset_, float dv_, float brtness_, float maxHealth_, float maxEnergy_, boolean ghost_)
  {
    w = w_;
    h = h_;
    mass = mass_;
    x = x0;
    y = y0;
    vx = vx0;
    vy = vy0;
    vmax = 10;
    ax = 0;
    ay = 0;
    amax = 5;
    boundingBoxOffset = boundingBoxOffset_;
    dv = dv_;
    brtness = brtness_;
    maxHealth = maxHealth_;
    health = maxHealth;
    maxEnergy = maxEnergy_;
    energy = maxEnergy;
    ghost = ghost_;
  }
  
  void update(float dt)
  {
    vx = constrain(vx + dt * ax, -vmax, vmax);
    vy = constrain(vy + dt * ay, -vmax, vmax);
    move(dt * vx, dt * vy);
  }
  
  void move(float dx, float dy)
  {
    float[] newPosition = {0,0};
    
    // No collisions for ghosts!
    if(ghost)
    {
      newPosition[0] = x + dx;
      newPosition[1] = y + dy;
    }
    else // Check for collisions.
    {
      newPosition = tileCollisionCheck(dx, dy);
    }
    
    // Update x and y. Constrain each Entity to lie between the second and second-to-last Tile.
    x = constrain(newPosition[0], TILE_SIZE, (numTilesX - 1) * TILE_SIZE);
    y = constrain(newPosition[1], TILE_SIZE, (numTilesY - 1) * TILE_SIZE);
  }
  
  float[] tileCollisionCheck(float dx, float dy)
  {
    // Calculate the coordinates of the Entity's 4 corners in the tentative new position.
    float xw0 = x + dx;
    float xw1 = xw0 + w;
    float yw0 = y + dy;
    float yw1 = yw0 + h;
    
    // Return the new Entity (x,y) in this array.
    float[] newPosition = {0,0};
    
    // And the coordinates of the Tiles they're in.
    int xt0 = int(xw0) / TILE_SIZE;
    int xt1 = int(xw1) / TILE_SIZE;
    int yt0 = int(yw0) / TILE_SIZE;
    int yt1 = int(yw1) / TILE_SIZE;
    
    // See if we've collided with a blocked Tile.
    boolean blocked00 = tileArray[xt0][yt0].blocked;
    boolean blocked01 = tileArray[xt1][yt0].blocked;
    boolean blocked10 = tileArray[xt0][yt1].blocked;
    boolean blocked11 = tileArray[xt1][yt1].blocked;
    
    // Check for collisions
    if(dx>0) // moved right
    {
      if(blocked01 || blocked11) // collided to the right
      {
        xw0 = xt1 * TILE_SIZE - w - 0.0001;
      }
    }
    else if(dx<0) // moved left
    {
      if(blocked00 || blocked10) // collided to the left
      {
        xw0 = (xt0 + 1) * TILE_SIZE;
      }
    }
    
    if(dy>0) // moved down
    {
      if(blocked10 || blocked11)
      {
        yw0 = yt1 * TILE_SIZE - h - 0.0001;
      }
    }
    else if(dy<0) // moved up
    {
      if(blocked00 || blocked01)
      {
        yw0 = yt0 * TILE_SIZE + TILE_SIZE;
      }
    }
    
    newPosition[0] = xw0;
    newPosition[1] = yw0;
    return newPosition;
  }
    
  
}
