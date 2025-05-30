import processing.sound.SoundFile;
class Note extends Entity {
  private SoundFile sound;
  private boolean isHit = false;
  private boolean isFinished = false;
  private int hitAnimIndex = 0;
  

  Note(PApplet applet, ArrayList<PImage[]> sprites, int xPos, int yPos, int hitboxWidth, int hitboxHeight, String soundFilePath) {
    super(applet, sprites, xPos, yPos, hitboxWidth, hitboxHeight);
    sound = new SoundFile(applet, soundFilePath);
  }

  Note(PApplet applet, PImage[][] sprites, int xPos, int yPos, String soundFilePath) {
    this(applet, sprites, xPos, yPos, 0, 0, soundFilePath);
  }

  public void setHitboxSize(int w, int h) {
    hitboxWidth = w;
    hitboxHeight = h;
  }

  @Override
  public void drawSprite() {
    if (isHit) {
      if (curSprite >= frames.get(curAnim).length) {
        curSprite = frames.get(curAnim).length - 1;
        isFinished = true;
      }
      applet.image(frames.get(curAnim)[curSprite], pos[0] - center[0], pos[1] - center[1]);
      frameCounter++;
      if (frameCounter >= frameDelay) {
        curSprite++;
        frameCounter = 0;
      }
    } else {
      super.drawSprite();
    }
  }

  public void hit() {
    if (!isHit) {
      isHit = true;
      playSound();
      curAnim = hitAnimIndex;
      curSprite = 0;
      frameCounter = 0;
    }
  }
  public void hit(char type) {
    hit();
  }
  public int calculateScore(Entity other)
  {  
    return 1000 / Math.abs((pos[0] - other.getX())) + 1000 / Math.abs((pos[1] - other.getY()));
  }

  public boolean isHit() {
    return isHit;
  }

  public boolean isFinished() {
    return isFinished;
  }

  public void playSound() {
    if (sound != null) {
      sound.play();
    }
  }
}
