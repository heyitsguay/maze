class Item
{
  int xt;
  int yt;
  float xw;
  float yw;
  float r;
  
  int id;
  float ch;
  float cs;
  float cb;
  boolean lightSource; // if true, emits light
  float brightness; // 0 if not a lightSource.
  
  Item(int xt_, int yt_, int id_)
  {
    xt = xt_;
    yt = yt_;
    xw = xt * TILE_SIZE + TILE_SIZE / 2;
    yw = yt * TILE_SIZE + TILE_SIZE / 2;
    r = TILE_SIZE / 4;
    
    id = id_; // Item ID dictates what it does
    
    // Setup item coloration
    switch(id)
    {
      case 0: // Restore charge item. Blue
        ch = 0.6;
        cs = 0.85;
        cb = 0.9;
        lightSource = false;
        brightness = 0;
        break;
        
      case 1: // Boost Player's base bness. Red
        ch = 0;
        cs = 1;
        cb = 1;
        lightSource = false;
        brightness = 0;
        break;
        
      case 2: // Boost Player's maxCharge. Green
        ch = 0.33;
        cs = 0.9;
        cb = 0.8;
        lightSource = false;
        brightness = 0;
        break;
        
      case 3: // Slow Player's charge cost. White
        ch = 0;
        cs = 0;
        cb = 0.95;
        lightSource = false;
        brightness = 0;
        break;
        
      default: // Default item coloration. White
        ch = 0;
        cs = 0;
        cb = 0.5;
        lightSource = false;
        brightness = 0;
        break;
    }
  }
  
  void display(float xscreen, float yscreen, float cbIn)
  {
    stroke(0,0,0);
    strokeWeight(0.5);
    fill(ch, cs, cb * constrain(cbIn,0,1));
    ellipse(xw - xscreen, yw - yscreen, 2*r, 2*r);
  }
  
  
}
