void keyPressed()
{
  // key press callback function.
  
  if(key != CODED && key < numKeys)
  {
    keyList[key] = true;
  }
}

void keyReleased()
{
  // key release callback function.
  
  if(key != CODED && key < numKeys)
  {
    keyList[key] = false;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void keyCheck()
{
  // Quit check.
  if(keyList['q'] || keyList['Q'])
  {
    exit();
  }
  
  // Check WASD keys for Player movement.
  checkMovement();
  
  // Toggle Player ghost mode
  if(keyList['g'] || keyList['G'])
  {
    player.ghost = !player.ghost;
  }
  
  // Print the number of path Tiles in tiles
  if(keyList['p'] || keyList['P'])
  {
    takeMazeShot();
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
void checkMovement()
{
  // Check for movement first. Get WASD input and then normalize to magnitude 1.
 float dx = 0;
 float dy = 0;
 
 if(keyList['a'] || keyList['A']) // move left
  {
    dx -= 1;
  }
  
  if(keyList['w'] || keyList['W']) // move up
  {
    dy -= 1;
  }
  
  if(keyList['d'] || keyList['D']) // move right
  {
    dx += 1;
  }
  
  if(keyList['s'] || keyList['S']) // move down
  {
    dy += 1;
  }
  
  // Divide (dx,dy) by sqrt(2) if both dx, dy, are nonzero.
  // This normalizes the movement vector.
  if(dx != 0 && dy != 0)
  {
    dx *= ISQRT2;
    dy *= ISQRT2;
  }
  
  player.move(player.moveSpeed * dx, player.moveSpeed * dy);
}
