void mouseClicked()
{
  int xtm = int((screenX + mouseX) / TILE_SIZE);
  int ytm = int((screenY + mouseY) / TILE_SIZE);
  Tile aTile = tiles[xtm][ytm];
  println(aTile.type);
  println(aTile.c_bactive);
  println(aTile.xw);
  println(aTile.yw);
  //println(sigmoid(aTile.c_bbase + aTile.c_bactive + aTile.a_b * aTile.alignment));
}
