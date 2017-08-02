// **************************************
// **************************************
class Torch extends Entity
{
  int ID = 0;
  
  // How much light the Torch creates.
  float glow;
  
  // Frequency (in Hz) of the Torch's light oscillation.
  float freq;
  
  //////////////////////////////////////////////////////////////////////////////////////////
  Torch(float xcenter_, float ycenter_, float glow_)
  {
    super(8, 24, 0, 0.1, xcenter_ - 4, ycenter_ - 12, 0, 0, 10, 0, 0, 10, 10, 0.1362, 0.95, 1, true, true);
    freq = 1/random(5, 15);
    glow = glow_;
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////
  void update()
  {
    // Light up the Tile that player is centered on
    tiles[xtcenter][ytcenter].c_bactiveNew += glow  * (1 + 0.3 * sin(2 * PI * freq * t));
    lightList.addTile(tiles[xtcenter][ytcenter]);
  }
}

// **************************************
// **************************************
//class Monster extends Entity
//{
//  float health;
//  float maxHealth;
//  
//  float energy;
//  float maxEnergy;
//  float energyCost; // Energy diminishes exponentially with this rate parameter.
//  float energyRechargeRate; // Governs how quickly energy recharges.
//  
//  float glow;
//  
//  // Player movement speed.
//  float moveSpeed;
//  
//  float alignment = A_HOSTILE;
//}
