class Entity
{
  private int[] pos = new int[2];
  private int[] center = new int[2];
  private PImage[][] frames;
  private int anims;
  private int curAnim;
  private int curSprite;
  
  public Entity(PImage[][] sprites, int xPos, int yPos, int xCen, int yCen)
  {
    frames = sprites;
    anims = sprites.length;
    pos[0] = xPos;
    pos[1] = yPos;
    center[0] = xCen;
    center[1] = yCen;
    clamp(center);
    clamp(pos);
  }
  public Entity(PImage[][] sprites, int xPos, int yPos)
  {
    this(sprites, xPos, yPos, 0 , 0);
  }
  public Entity(PImage[][] sprites)
  {
    this(sprites, 0 , 0);
  }
  
  public void drawSprite()
  {
    drawSprite(curAnim);
  }
  public void drawSprite(int anim)
  {
    if (anim != curAnim) 
    {
      curSprite = 0;
      curAnim = anim;
    }
    image(frames[anim][curSprite], pos[0] - center[0], pos[1] - center[1]);
    curSprite = (curSprite + 1) % frames[anim].length;
  }
  public void move(int x, int y)
  {
    pos[0] += x;
    pos[1] += y;
    clamp(pos);
  }
  
  
}
