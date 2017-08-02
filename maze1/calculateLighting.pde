/////////////////////////////////////////////////////////////////////////////////////
// lighting calculation function                                                   //
/////////////////////////////////////////////////////////////////////////////////////
void calculateLighting(float drate)
{
  // decay Constant
  float decayConstant = 0.95;
  // light threshold
  float threshold = 0.0001;
  Tile t1, t2;
  
  // set thePlayer's current Tile's lighting level to thePlayer's bnessactive value.
  tileArray[thePlayer.xt][thePlayer.yt].cbnew += (thePlayer.bnessactive)*(1 - thePlayer.beatSize * 0.5 * (cos(2*PI*t/60.0) + 1));
  
  // add the Player's current Tile to the light list if it's not there already.
  if(!(tileArray[thePlayer.xt][thePlayer.yt].inLightList)){ tileArray[thePlayer.xt][thePlayer.yt].addToLighting(); }
  
  // update lightingTiles (iterating backwards again)
  for(int i=lightingTiles.size()-1;i>=0;i--)
  {
    t1 = lightingTiles.get(i); // Tile currently being addressed
    
    // update desat using previous values
    t1.desat = t1.desat + pow(constrain(t1.cb,0,1),2) * t1.desatRate * t1.desat * (1 - t1.desat);
    
    // update t1's cb, clear cbnew
    t1.cb = decayConstant * t1.cbnew;
    //t1.desat = t1.desatnew;
    
    if(t1.cb < threshold)
    {
      t1.removeFromLighting();
    }
    else
    {
      t1.cbnew = 0; 
      //t1.desatnew = 0;
     
      for(int j=0;j<t1.numNeighbors;j++)
      {
        t2 = tileArray[t1.mazeNeighbors[0][j]][t1.mazeNeighbors[1][j]];
        if(!(t2.inLightList)){ t2.addToLighting(); } // add this neighbor Tile to lightingTiles if it's not there already
        // add (drate / numNeighbors) times t1's current cb value to this neighbor's cbnew.
        t2.cbnew += (drate / t1.numNeighbors) * t1.cb;
        //t2.desatnew += ((drate/100) / t1.numNeighbors) * t1.desat;
      }
      
      // increment t1.cbnew
      t1.cbnew += (1 - drate) * t1.cb;
      //t1.desatnew += (1 - (drate/100)) * t1.desat;
    }
  }
  
  
}
