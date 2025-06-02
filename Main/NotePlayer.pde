class NotePlayer {
  PApplet applet;
  int[] direction;
  int speed;
  int[] spawnFrames;
  int currentFrame = 0;
  int framesPlayed = 0;
  ArrayList<Note> notes = new ArrayList<Note>();
  ArrayList<PImage[]> sprites;
  String soundFile;
  int startX, startY;

  NotePlayer(PApplet applet, int[] direction, int[] spawnFrames, int speed, ArrayList<PImage[]> sprites, String soundFile, int startX, int startY) {
    this.applet = applet;
    this.direction = direction;
    this.spawnFrames = spawnFrames;
    this.speed = speed;
    this.sprites = sprites;
    this.soundFile = soundFile;
    this.startX = startX;
    this.startY = startY;
  }

  void update() {
    currentFrame++;
    
    if (framesPlayed < spawnFrames.length && spawnFrames[framesPlayed] <= currentFrame)
    {
      if (spawnFrames[framesPlayed] > 0)
      {
        Note n = new Note(applet, sprites, startX, startY, 128, 128, soundFile);
        notes.add(n);
      }
       
      framesPlayed++;
    }
    

    for (int i = notes.size() - 1; i >= 0; i--) {
      Note n = notes.get(i);
      if (!n.isHit()) {
        n.move(direction[0] * speed, direction[1] * speed);
      }
      n.drawSprite();
      n.drawHitbox(applet);

      if (n.isFinished()) {
        notes.remove(i);
      }
    }
  }

  ArrayList<Note> getNotes() {
    return notes;
  }
}
