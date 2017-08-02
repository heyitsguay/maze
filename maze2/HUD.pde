// ************************************************
// ************************************************
class HUD
{
  // List of all HUDBars the HUD contains.
  ArrayList<HUDBar> barList;
  
  
  float healthBarLength = 128;
  float healthBarHeight = 16;
  color c_base = color(0, 0, 0.8);
  color c_outline = color(0, 0, 0.2);
  color c_fill = color(0.05, 1, 1);
  float x = width - healthBarLength - 64;
  float y = height - healthBarHeight - 128;
  
  HUDBar healthBar;
  
  HUD()
  {
     barList = new ArrayList<HUDBar>();
     healthBar = new HUDBar(x, y, healthBarLength, healthBarHeight, c_base, 1, c_outline, c_fill, 1);
     barList.add(healthBar);
  }
  
  void display()
  {
    // Draw all hudBars
    for(int i = 0; i < barList.size(); i++)
    {
      barList.get(i).drawBar();
    }
  }
}

// ************************************************
// ************************************************
class HUDRectangle
{
  // A visible rectangle in the HUD. 
  
  // (x,y) screen coordinates of the top-left corner of the HUDRectangle.
  float x, y;
  
  // Length of the HUDRectangle.
  float L;
  
  // Height of the HUDRectangle.
  float H;
  
  // HUDRectangle's body's color. HSB coordinates in [0,1].
  color c_body;
  
  // HUDRectangle's outline's stroke weight.
  float outlineWeight;
  
  // HUDRectangle's outline's color. HSB coordinates in [0,1].
  color c_outline;
  
  /////////////////////////////////////////////////////////////////////////////////////////////////
  HUDRectangle(
    float x_, 
    float y_, 
    float L_, 
    float H_, 
    color c_body_, 
    float outlineWeight_,
    color c_outline_
  )
  {
    x = x_;
    y = y_;
    L = L_;
    H = H_;
    c_body = c_body_;
    outlineWeight = outlineWeight_;
    c_outline = c_outline_;
  }
  
  void drawRectangle()
  {
    stroke(c_outline);
    strokeWeight(outlineWeight);
    fill(c_body);
    rect(x, y, L, H);
  }
}

// ***********************************************
// ***********************************************
class HUDBar extends HUDRectangle
{
  // A HUDBar is a meter that tracks e.g. player health, player energy,
  // displaying a proportion of a maximum quantity (e.g. health/maxHealth).
  // The display has a proportionately-sized rectangle of color c_fill on
  // top of a full-sized background rectangle of color c_body.
  
  color c_fill;
  
  // Float in [0,1], tracks how full the Bar is.
  float howFull;
  
  ///////////////////////////////////////////////////////////////////////////////////////////////
  HUDBar(
    float x_, 
    float y_, 
    float L_, 
    float H_, 
    color c_body_, 
    float outlineWeight_,
    color c_outline_,
    color c_fill_,
    float howFull_
  )
  {
    super(x_, y_, L_, H_, c_body_, outlineWeight_, c_outline_);
    c_fill = c_fill_;
    howFull = howFull_;
  }
  
  /////////////////////////////////////////////////////////////////////////////////////////////////
  void drawBar()
  {
    // Draw the base HUDRectangle.
    drawRectangle();
    
    strokeWeight(0); // No outline.
    
    fill(c_fill);
    
    // Draw the additional rectangle measuring fullness.
    rect(x, y, howFull * L, H);
  }
}
    
    
  
