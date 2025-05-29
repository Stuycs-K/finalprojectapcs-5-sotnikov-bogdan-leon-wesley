import processing.sound.SoundFile;
import java.util.HashSet;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
NotePlayer topPlayer, bottomPlayer, leftPlayer, rightPlayer;
Entity centerPoint;
PImage[][] dummySprites;
int[][] Song;
int speed = 5;
HashSet<Integer> keysDown = new HashSet<Integer>();
ArrayList<Entity> hitZones = new ArrayList<Entity>();
PImage bg;

void setup() {
  size(960, 540);
  bg = loadImage(sketchPath("data/Background.png"));
  dummySprites = new PImage[1][1];
  dummySprites[0][0] = createImage(32, 32, RGB);
  dummySprites[0][0].loadPixels();
  for (int i = 0; i < dummySprites[0][0].pixels.length; i++) {
    dummySprites[0][0].pixels[i] = color(255, 0, 0);
  }
  dummySprites[0][0].updatePixels();
  
  
  
  int centerX = width /2;
  int centerY = height/2;
  centerPoint = new Entity(this, dummySprites, centerX + 8, centerY + 8, 32, 32);
  
  Song = getSong("bad apple");
  topPlayer = new NotePlayer(this, new int[]{0, 1}, Song[0], speed, dummySprites, "C Note.wav", centerX, centerY - 300);
  bottomPlayer = new NotePlayer(this, new int[]{0, -1}, Song[1], speed, dummySprites, "C Note.wav", centerX,  centerY + 300);
  leftPlayer = new NotePlayer(this, new int[]{1, 0}, Song[2], speed, dummySprites, "C Note.wav", centerX - 300,  centerY);
  rightPlayer = new NotePlayer(this, new int[]{-1, 0}, Song[3], speed, dummySprites, "C Note.wav", centerX + 300,  centerY);

  frameRate(60);
}

void draw() {
  image(bg, 0, 0);

  topPlayer.update();
  bottomPlayer.update();
  leftPlayer.update();
  rightPlayer.update();

  checkCenterHits(topPlayer);
  checkCenterHits(bottomPlayer);
  checkCenterHits(leftPlayer);
  checkCenterHits(rightPlayer);

  checkDirectionalHits();
  centerPoint.drawSprite();
  centerPoint.drawHitbox(this);
  for (Entity z : hitZones) {
    z.drawHitbox(this);
  }
  hitZones.clear();
}
void keyPressed() {
  keysDown.add((int)keyCode);
}

void keyReleased() {
  keysDown.remove((int)keyCode);
}

void checkDirectionalHits() {
  if (keysDown.contains((int)'W') || keysDown.contains(UP)) {
    createHitZoneAndCheck(topPlayer, 0, -1, 'w');
  }
  if (keysDown.contains((int)'S') || keysDown.contains(DOWN)) {
    createHitZoneAndCheck(bottomPlayer, 0, 1, 's');
  }
  if (keysDown.contains((int)'A') || keysDown.contains(LEFT)) {
    createHitZoneAndCheck(leftPlayer, -1, 0, 'a');
  }
  if (keysDown.contains((int)'D') || keysDown.contains(RIGHT)) {
    createHitZoneAndCheck(rightPlayer, 1, 0, 'd');
  }
}

void createHitZoneAndCheck(NotePlayer player, int dx, int dy, char pressedKey) {
  int x = centerPoint.getX() + dx * 100;
  int y = centerPoint.getY() + dy * 100;

  Entity zone = new Entity(this, dummySprites, x, y, 48, 48);
  hitZones.add(zone);

  ArrayList<Note> notes = player.getNotes();
  for (Note n : notes) {
    if (!n.isHit() && n.intersects(zone)) {
      n.hit(pressedKey);
      break;
    }
  }
}

void checkCenterHits(NotePlayer player) {
  ArrayList<Note> notes = player.getNotes();
  for (int i = notes.size() - 1; i >= 0; i--) {
    Note n = notes.get(i);
    if (n.intersects(centerPoint) && !n.isHit()) {
      n.hit(' '); // Default key when hit from center
    }
    if (n.isFinished()) {
      notes.remove(i);
    }
  }
}

PImage[] loadImagesFromFolder(String path) {
  File folder = new File(sketchPath(path));
  File[] files = folder.listFiles();

  if (files == null) return new PImage[0];

  ArrayList<PImage> images = new ArrayList<PImage>();
  for (File f : files) {
    String name = f.getName().toLowerCase();
    if (f.isFile() && (name.endsWith(".png") || name.endsWith(".jpg"))) {
      images.add(loadImage(f.getAbsolutePath()));
    }
  }
  return images.toArray(new PImage[images.size()]);
}

int[][] getSong(String path) {
    try {
        Scanner scanner = new Scanner(new File(sketchPath("data/Songs/" + path)));
        
        int len = scanner.nextInt();
        int[][] song = new int[4][len];
        for (int i = 0; i < len; i++) {
            for (int j = 0; j < 4; j++) {
                if (scanner.hasNextInt()) {
                    song[j][i] = scanner.nextInt();
                } else {
                    song[j][i] = 0;
                }
            }
        }

        scanner.close();
        return song;

    } catch (FileNotFoundException e) {
        e.printStackTrace();
        return new int[4][0];
    }
}
