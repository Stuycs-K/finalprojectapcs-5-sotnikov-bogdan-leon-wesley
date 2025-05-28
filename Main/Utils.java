class Utils
{
  public void clamp (int[] pos)
  {
    pos[0] = constrain(pos[0], 0, width);
    pos[1] = constrain(pos[1], 0, height);
  }
}
