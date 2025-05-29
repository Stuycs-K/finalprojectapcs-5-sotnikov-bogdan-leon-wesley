class NotePlayer {
  PApplet applet;
  int[] direction;
  int speed;
  int[] spawnFrames;
  int currentFrame = 0;
  ArrayList<Note> notes = new ArrayList<Note>();
  PImage[][] sprites;
  String soundFile;
  int startX, startY;

  NotePlayer(PApplet applet, int[] direction, int[] spawnFrames, int speed, PImage[][] sprites, String soundFile, int startX, int startY) {
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

    for (int f : spawnFrames) {
      if (f == currentFrame) {
        Note n = new Note(applet, sprites, startX, startY, 16, 16, soundFile);
        n.setHitboxSize(32, 32);
        notes.add(n);
      }
    }

    for (int i = notes.size() - 1; i >= 0; i--) {
      Note n = notes.get(i);
      if (!n.isHit()) {
        n.move(direction[0] * speed, direction[1] * speed);
      }
      n.drawSprite();

      if (n.isFinished()) {
        notes.remove(i);
      }
    }
  }

  ArrayList<Note> getNotes() {
    return notes;
  }
}
