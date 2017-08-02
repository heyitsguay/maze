// Does a proper x mod 1 operation, so that negative numbers become positive
float mod1(float xin)
{
  if(xin < 0)
  {
    return xin % 1.0 + 1;
  }
  else
  {
    return xin % 1.0;
  }
}
