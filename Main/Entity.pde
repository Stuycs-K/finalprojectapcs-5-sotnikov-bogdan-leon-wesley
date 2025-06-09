class Entity {
  protected PApplet applet;
  
  protected float[] pos = new float[2];
  protected float[] center = new float[2];
  
  protected ArrayList<PImage[]> frames;
  protected int anims;
  protected int curAnim = 0;
  protected int curSprite;

  // Animation speed control
  protected int frameDelay = 5;
  protected int frameCounter = 0;
  protected int[] frameDelays;

  // Hitbox info
  protected int hitboxWidth = 0;
  protected int hitboxHeight = 0;

  // Constructors

  Entity(PApplet applet, ArrayList<PImage[]> sprites, int[] speeds, float xPos, float yPos, int hitboxWidth, int hitboxHeight) {
    this.applet = applet;  // save PApplet
    frames = sprites;
    anims = sprites.size();
    pos[0] = xPos;
    pos[1] = yPos;
    this.hitboxWidth = hitboxWidth;
    this.hitboxHeight = hitboxHeight;
    center[0] = hitboxWidth / 2;
    center[1] = hitboxHeight / 2;
    frameDelays = speeds;
  }
  Entity(PApplet applet, ArrayList<PImage[]> sprites, float xPos, float yPos, int hitboxWidth, int hitboxHeight) {
    this.applet = applet;  // save PApplet
    frames = sprites;
    anims = sprites.size();
    pos[0] = xPos;
    pos[1] = yPos;
    this.hitboxWidth = hitboxWidth;
    this.hitboxHeight = hitboxHeight;
    center[0] = hitboxWidth / 2;
    center[1] = hitboxHeight / 2;
    frameDelays = new int[sprites.size()];
    Arrays.fill(frameDelays, 20);
  }

  Entity(PApplet applet, ArrayList<PImage[]> sprites, float xPos, float yPos) {
    this(applet, sprites, xPos, yPos, 0, 0);
  }

  Entity(PApplet applet, ArrayList<PImage[]> sprites) {
    this(applet, sprites, 0, 0);
  }

  void setFrameDelay(int index, int delay) {
    frameDelays[index] = max(1, delay);
  }

  void setHitboxSize(int w, int h) {
    hitboxWidth = w;
    hitboxHeight = h;
  }
  
  float getX(){
    return pos[0];
  }
  float getY(){ 
    return pos[1];
  }

  float[] getHitbox() {
    float cx = pos[0] - hitboxWidth / 2;
    float cy = pos[1] - hitboxHeight / 2;
    return new float[] {
      cx,
      cy,
      hitboxWidth,
      hitboxHeight
    };
  }


  boolean intersects(Entity other) {
  float[] hb1 = this.getHitbox();
  float[] hb2 = other.getHitbox();
  return !(hb1[0] + hb1[2] < hb2[0] ||
           hb1[0] > hb2[0] + hb2[2] ||
           hb1[1] + hb1[3] < hb2[1] ||
           hb1[1] > hb2[1] + hb2[3]);

  }

  void drawSprite() {
    drawSprite(curAnim);
  }
  void setAnim(int anim)
  {
    if (anim > frames.size()) return;
    curAnim = anim;
    curSprite = 0;
    frameCounter = 0;
    frameDelay = frameDelays[anim];
  }

  void drawSprite(int anim) {
    if (anim != curAnim) {
      setAnim(anim);
    }
    image(frames.get(anim)[curSprite], pos[0] - center[0], pos[1] - center[1]);
    frameCounter++;
    if (frameCounter >= frameDelay) {
      curSprite = (curSprite + 1);
      if(curSprite == frames.get(anim).length)
      {
        setAnim(0);
      }
      frameCounter = 0;
    }
  }
  void setCenter(float x, float y)
  {
    center[0] = x;
    center[1] = y;
  }
  void move(float x, float y) {
    pos[0] += x;
    pos[1] += y;
  }

  void clamp(int[] arr) {
    arr[0] = constrain(arr[0], 0, width);
    arr[1] = constrain(arr[1], 0, height);
  }
  public void drawHitbox(PApplet applet) {
    applet.noFill();
    applet.stroke(0, 255, 0);
    float[] hb = getHitbox();
    applet.rect(hb[0], hb[1], hb[2], hb[3]);
  }
}
