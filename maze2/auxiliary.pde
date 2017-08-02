//////////////////////////////////////////////////////////////////////////////////////////////
float mod1(float x_)
{
  // Does a proper x mod 1 operation, so that negative numbers become positive
  
  if(x_ < 0)
  {
    return x_ % 1.0 + 1;
  }
  else
  {
    return x_ % 1.0;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////
int sign(float x_)
{
  // Returns -1 if xin < 0, 0 if xin == 0, +1 if xin > 0
  
  if(x_ < 0)
  {
    return -1;
  }
  else if(x_ == 0)
  {
    return 0;
  }
  else if(x_ > 0)
  {
    return 1;
  }
  else
  {
    return -2; // How did you get here?
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////
int getTileIdx(Tile tile_)
{
  // Returns the index of tile_ in a linear indexing of the World
  // which starts at 0 at the top-left corner and runs horizontally
  // then downward.
  
  return tile_.yt * tilesX + tile_.xt;
}

/////////////////////////////////////////////////////////////////////////////////////////////////
float sigmoid(float x_)
{
  return 1./(1+exp(4.8 - 8 * x_));
}

/////////////////////////////////////////////////////////////////////////////////////////////////
char creatorDirection(int x_)
{
  x_ = x_ % 4;
  return char(x_);
} 

/////////////////////////////////////////////////////////////////////////////////////////////////
void takeMazeShot()
{
  int tsize = 4;
    PImage mazeShot = createImage(tsize*tilesX, tsize*tilesY, RGB);
    for(int i=0; i<tilesX; i++)
    {
      int x0 = i * tsize;
      for(int j=0; j<tilesY; j++)
      {
        int y0 = j * tsize;
        Tile ti = tiles[i][j];
        color tileColor;
        if(ti.initialized)
        {
          tileColor = color(ti.c_h + ti.c_hroom, 1, 1);
        }
        else
        {
          tileColor = color(0,0,0.3);
        }
        
        for(int k=0; k<tsize; k++)
        {
          for(int l=0; l<tsize; l++)
          {
            if(ti.type == T_WIN)
            {
              mazeShot.set(x0+k,y0+l, color(random(1), 1, 1));
            }
            else
            {
              mazeShot.set(x0+k,y0+l, tileColor);
            }
          }
        }
      }
    }
    
    int dy = day();
    int hr = hour();
    int mn = minute();
    int sec = second();
    int ms = millis();
    
    String fname = "images/mazeshot" + String.valueOf(dy) + String.valueOf(hr) + String.valueOf(mn) + String.valueOf(sec) + String.valueOf(ms) + ".png";
    
    mazeShot.save(fname);
}
