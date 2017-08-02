/////////////////////////////////////////////////////////////////////////
// keypress callback function                                          //
/////////////////////////////////////////////////////////////////////////
void keyPressed()
{
  if(key != CODED && key < numKeys)
  {
    keyList[key] = true;
  }
  
  if(thePlayer.xt == winXt  && thePlayer.yt == winYt && gameOver == 0)
  {
   gameOver = 1;
  }
}

void keyReleased()
{
  if(key != CODED && key < numKeys)
  {
    keyList[key] = false;
  }
}

void keyCheck()
{
  // Check for movement first
  float moveX = 0;
  float moveY = 0;
  
  if(keyList['a'] || keyList['A']) // move left
  {
    moveX -= 1;
  }
  
  if(keyList['w'] || keyList['W']) // move up
  {
    moveY -= 1;
  }
  
  if(keyList['d'] || keyList['D']) // move right
  {
    moveX += 1;
  }
  
  if(keyList['s'] || keyList['S']) // move down
  {
    moveY += 1;
  }
  
  // If (moveX,moveY) != (0,0), normalize and move.
  if(moveX != 0 || moveY != 0)
  {
    float speed = sqrt(pow(moveX,2) + pow(moveY,2));
    moveX /= speed;
    moveY /= speed;
    thePlayer.move(moveX, moveY);
  }
  
  if(keyList['q'] || keyList['Q']) // quit
  {
    exit();
  }
  
  if(keyList['e'] || keyList['E']) // toggle godMode
  {
    godMode = !godMode;
  }
  
  if(keyList['g'] || keyList['G']) // save a picture of the full maze.
  {
    takeMazeshot();
  }
  
}
  
//void keyPressed()
//{
//  if(key == 'a' || key == 'A') // move left
//  {
//    thePlayer.move(-1, 0);
//  }
//  else if(key == 'w' || key == 'W') // move up
//  {
//    thePlayer.move(0, -1);
//  }
//  else if(key == 'd' || key == 'D') // move right
//  {
//    thePlayer.move(1, 0);
//  }
//  else if(key == 's' || key == 'S') // move down
//  {
//    thePlayer.move(0, 1);
//  }
//  else if(key == 'q' || key == 'Q') // quit
//  {
//    for(int i = 0; i < 10; i++)
//    {
//      println(roomList.get(i).roomarea);
//    }
//    println(numRooms);
//    exit();
//  }
//  else if(key == 'e' || key == 'E') // toggle godMode
//  {
//    godMode = !godMode;
//  }
//  else if(key == 'g' || key == 'G') // save a picture of the full maze
//  {
//    takeScreenshot();
//  }
//        
//  
//  if(thePlayer.xt == winXt  && thePlayer.yt == winYt && gameOver == 0)
//  {
//    gameOver = 1;
//  }
//}

void takeMazeshot()
{
  int tsize = 4;
    PImage mazeShot = createImage(tsize*numTilesX, tsize*numTilesY, RGB);
    for(int i=0; i<numTilesX; i++)
    {
      int x0 = i * tsize;
      for(int j=0; j<numTilesY; j++)
      {
        int y0 = j * tsize;
        Tile ti = tileArray[i][j];
        color tileColor;
        if(ti.initialized)
        {
          tileColor = color(ti.ch, 1, 1);
        }
        else
        {
          tileColor = color(0,0,0);
        }
        
        for(int k=0; k<tsize; k++)
        {
          for(int l=0; l<tsize; l++)
          {
            if(ti.winning)
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
    
    String fname = "mazeshot" + String.valueOf(dy) + String.valueOf(hr) + String.valueOf(mn) + String.valueOf(sec) + String.valueOf(ms) + ".png";
    
    mazeShot.save(fname);
}
