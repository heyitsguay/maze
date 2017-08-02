void setupRooms()
{
  for(int x = 1; x < numTilesX-1; x++)
  {
    //println(x);
    for(int y = 1; y < numTilesY-1; y++)
    {
      
      Tile ti = tileArray[x][y];
      //println(ti.inRoom);
      if(!ti.inRoom && !ti.wall)
      {
        Room newRoom = new Room(ti);
        //println(y);
        if(newRoom.roomHere) // room setup was successful
        {
          //println("woo");
          roomList.add(newRoom);
          numRooms += 1;
          //println(numRooms);
        }
      }
    }
  }
}
