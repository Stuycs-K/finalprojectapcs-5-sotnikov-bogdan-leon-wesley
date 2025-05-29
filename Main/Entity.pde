class Entity {
  protected PApplet applet;
  
  protected int[] pos = new int[2];
  protected int[] center = new int[2];
  protected PImage[][] frames;
  protected int anims;
  protected int curAnim = 0;
  protected int curSprite;

  // Animation speed control
  protected int frameDelay = 5;
  protected int frameCounter = 0;

  // Hitbox info
  protected int hitboxWidth = 0;
  protected int hitboxHeight = 0;

  // Constructors

  Entity(PApplet applet, PImage[][] sprites, int xPos, int yPos, int hitboxWidth, int hitboxHeight) {
    this.applet = applet;  // save PApplet
    frames = sprites;
    anims = sprites.length;
    pos[0] = xPos;
    pos[1] = yPos;
    this.hitboxWidth = hitboxWidth;
    this.hitboxHeight = hitboxHeight;
    center[0] = hitboxWidth / 2;
    center[1] = hitboxHeight / 2;
  }

  Entity(PApplet applet, PImage[][] sprites, int xPos, int yPos) {
    this(applet, sprites, xPos, yPos, 0, 0);
  }

  Entity(PApplet applet, PImage[][] sprites) {
    this(applet, sprites, 0, 0);
  }

  void setFrameDelay(int delay) {
    frameDelay = max(1, delay);
  }

  void setHitboxSize(int w, int h) {
    hitboxWidth = w;
    hitboxHeight = h;
  }
  
  int getX(){
    return pos[0];
  }
  int getY(){ 
    return pos[1];
  }

  int[] getHitbox() {
    int cx = pos[0] - center[0];
    int cy = pos[1] - center[1];
    return new int[] {
      cx,
      cy,
      hitboxWidth,
      hitboxHeight
    };
  }


  boolean intersects(Entity other) {
  int[] hb1 = this.getHitbox();
  int[] hb2 = other.getHitbox();
  return !(hb1[0] + hb1[2] < hb2[0] ||
           hb1[0] > hb2[0] + hb2[2] ||
           hb1[1] + hb1[3] < hb2[1] ||
           hb1[1] > hb2[1] + hb2[3]);

  }

  void drawSprite() {
    drawSprite(curAnim);
  }

  void drawSprite(int anim) {
    if (anim != curAnim) {
      curSprite = 0;
      curAnim = anim;
      frameCounter = 0;
    }

    image(frames[anim][curSprite], pos[0] - center[0], pos[1] - center[1]);
    frameCounter++;
    if (frameCounter >= frameDelay) {
      curSprite = (curSprite + 1) % frames[anim].length;
      frameCounter = 0;
    }
  }

  void move(int x, int y) {
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
    int[] hb = getHitbox();
    applet.rect(hb[0], hb[1], hb[2], hb[3]);
  }
}
