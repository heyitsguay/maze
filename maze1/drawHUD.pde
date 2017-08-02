void drawHUD()
{
  // lb = light bar
  float lbLength = 100;
  float lbHeight = 10;
  float lbColorH = 0.6;
  float lbOutlineH = 0;
  float lbOutlineS = 0; // white 
  int lbx = width - ((int)lbLength + 20);
  int lby = height - ((int)lbHeight + 20);
  
  // draw the outline rectangle
  stroke(lbOutlineH, lbOutlineS, 0.8, 0.7);
  strokeWeight(1);
  fill(0, 0, 0.1, 0.7);
  rect(lbx, lby, lbLength, lbHeight);
  
  // draw the charge remaining rectangle
  fill(lbColorH, 1, 1, 0.7);
  noStroke();
  float lbLengthNow = thePlayer.charge / thePlayer.maxCharge * lbLength;
  rect(lbx, lby, lbLengthNow, lbHeight);
}
  
