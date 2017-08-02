interface Item
{
  void pickUp(Player player_);
  void display();  
}

// ****************************************
// ****************************************
class ItemHealth implements Item
{
  // (x,y) World coordinates of the Item's upper-left corner.
  float x, y;
  
  // Width and Height of the Item.
  float w, h;
  
  // Amount of health this Item restores
  float healthAmount;
  
  // HSB color coordinates of this Item. Range [0,1].
  float c_h, c_s, c_b;
  
  ////////////////////////////////////////////////////////////////////////////////
  ItemHealth(float x_, float y_)
  {
    x = x_;
    y = y_;
    w = float(TILE_SIZE)/2;
    h = float(TILE_SIZE)/2;
    
    healthAmount = 15;
    
    c_h = 0;
    c_s = 1;
    c_b = 1;
    
    // Add a function to add the Item to the itemLists of the Tiles which the Item intersects.
  }
  
  //////////////////////////////////////////////////////////////////////////////////
  void pickUp(Player player_)
  {
    player_.addHealth(healthAmount);
  }
  
  ///////////////////////////////////////////////////////////////////////////////////
  void display()
  {
    noStroke();
    pushMatrix();
    translate(-screenX, -screenY);
    
    // For now just draw a rectangle with a uniform fill.
    fill(c_h, c_s, c_b);
    rect(x, y, w, h); 
    
    popMatrix();
  }
  
  ////////////////////////////////////////////////////////////////////////////////////
  void addToTiles()
  {
    // Add this Item to all the Tiles which it intersects.
    
    // Tile coordinates of the Item's four corners.
    int xt0 = int(x / TILE_SIZE);
    int yt0 = int(y / TILE_SIZE);
    int xt1 = int((x + w) / TILE_SIZE);
    int yt1 = int((y + h) / TILE_SIZE); 
    
    // Top-left corner Tile
    tiles[xt0][yt0].itemList.add(this);
    
    if(yt1 != yt0)
    {
      // Bottom corners aren't in the same Tile as top corners.
      
      tiles[xt0][yt1].itemList.add(this);
      
      if(xt1 != xt0)
      {
        // Also, right corners aren't in the same Tile as left corners.
        
        tiles[xt1][yt0].itemList.add(this);
        tiles[xt1][yt1].itemList.add(this);
      }
    }
    else if(xt1 != xt0)
    {
      // Right corners aren't in the same Tile as left corners.
      
      tiles[xt1][yt0].itemList.add(this);
    }    
  }
    
  }
