///////////////////////////////////////////////////////////////////////////////////
// First try at a function generating mazes using the Creator automata           //
///////////////////////////////////////////////////////////////////////////////////
void mazeFunction1(int numRounds, int creatorsPerRound)
{
  //int creatorsPerRound = 10;
  
  
  Creator cr; // References the current Creator being updated.
  int modValue = (int)(numRounds / 2);
  
  for(int i = 0; i < numRounds; i++)
  {
    creators = new ArrayList<Creator>(); // Initialize the ArrayList of Creators
    // Add one creator at the starting point on some rounds
    if(i%modValue == 0)
    {
      creators.add(new Creator(startXt, startYt, 0.6, 3, 2, 2, 0.25 + 0.7 * float(i)/float(numRounds), int(random(4)), 3 * numTilesX / 2));
      creators.add(new Creator(winXt, winYt, 0.4, 3, 2, 2, 0, int(random(4)), 3 * numTilesX / 2)); 
    
  }
    for(int j = 0; j < creatorsPerRound - 1; j++)
    {
      creators.add(new Creator(int(random(numTilesX - 2))+1, int(random(numTilesY - 2))+1, random(0.49, 0.51), 3, 2, 2, 0.05 + 0.2 * float(i)/float(numRounds), int(random(4)), 3 * numTilesX / 2));
    }
    
    while(creators.size() > 0) // while any Creators are alive
    {
      for(int k = creators.size()-1; k>=0; k--) // loop backwards for ease of removal of dead Creators
      {
        cr = creators.get(k);
        if(cr.lifeRemaining == 0)
        {
          creators.remove(k);
        }
        else
        {
          cr.move();
        }
      }
    }
  }
}
