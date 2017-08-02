//color c_player = color(0.5, 1., 1.);
// Player color (HSB), range [0,1].
float player_h = 0.5;
float player_s = 1.;
float player_b = 0.5;

class Player extends Entity
{
  float health;
  float maxHealth;
  
  float energy;
  float maxEnergy;
  float energyCost; // Energy diminishes exponentially with this rate parameter.
  float energyRechargeRate; // Governs how quickly energy recharges.
  
  float glow;
  
  // Player movement speed.
  float moveSpeed;
  
  ////////////////////////////////////////////////////////////////////////////////////////
  Player(float xw_, float yw_)
  {    
    super(
      20, // width
      30, // height
      3, // boundingBoxOffset
      1., // mass
      xw_, // x0
      yw_, // y0
      0., // vx0
      0., // vy0
      60., // vmax
      0., // ax0
      0., // ay0
      60., // amax
      1., // friction
      player_h, // c_h
      player_s, // c_s
      player_b, // c_b
      false, // ghost
      false // fixed
      );
    
    health = 50.;
    maxHealth = 100.;
    
    energy = 100.;
    maxEnergy = 100.;
    
    energyCost = 0.90;
    energyRechargeRate = 1.001;
    
    glow = 2;
    
    moveSpeed = 2.5;
    
    alignment = A_FRIEND;
  }
  
  void update()
  {
    // Light up the Tile that the player is centered on
    tiles[xtcenter][ytcenter].c_bactiveNew += glow;
    
    // Add that Tile to the lightList.
    lightList.addTile(tiles[xtcenter][ytcenter]);
    
    // Call Entity physics update.
    updatePhysics();
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////
  void addHealth(float dhealth_)
  {
    health = constrain(health + dhealth_, 0, maxHealth);
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////
  void addEnergy(float denergy_)
  {
    energy = constrain(energy + denergy_, 0, maxEnergy);
  }
  
  void display()
  {
    display2();
  }
}
