import processing.sound.SoundFile;
import java.util.HashSet;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
NotePlayer topPlayer, bottomPlayer, leftPlayer, rightPlayer;
Entity centerPoint;
ArrayList<PImage[]> dummySprites;
int[][] Song;
int speed = 5;
HashSet<Integer> keysDown = new HashSet<Integer>();
ArrayList<Entity> hitZones = new ArrayList<Entity>();
PImage bg, bgo;
int score = 0;
ArrayList<PImage[]> drummerSprites, flautistSprites, lutistSprites, harpistSprites;
Entity[] sigils;
Entity drummer, flautist, harpist, lutist;

void setup() {
  //size(1920, 1080);
  fullScreen();
  bg = loadImage(sketchPath("data/Background.png"));
  bgo = loadImage(sketchPath("data/BackgroundOverlay.png"));
  dummySprites = new ArrayList<PImage[]>();
  dummySprites.add( new PImage[] {createImage(32, 32, RGB)});
  dummySprites.get(0)[0].loadPixels();
  for (int i = 0; i < dummySprites.get(0)[0].pixels.length; i++) {
    dummySprites.get(0)[0].pixels[i] = color(255, 0, 0);
  }
  dummySprites.get(0)[0].updatePixels();

  setupAnim();
  
  int centerX = width /2;
  int centerY = height/2;
  centerPoint = new Entity(this, dummySprites, centerX, centerY + 8, 256, 256);
  drummer = new Entity(this, drummerSprites, centerX + 96, centerY + 8, 128, 128);
  flautist = new Entity(this, flautistSprites, centerX - 96, centerY + 8, 128, 128);
  harpist = new Entity(this, harpistSprites, centerX + 8, centerY - 96, 128, 128);
  lutist = new Entity(this, lutistSprites, centerX + 8, centerY + 96, 128, 128);
  
  drummer.setFrameDelay(20);
  flautist.setFrameDelay(20);
  harpist.setFrameDelay(20);
  lutist.setFrameDelay(20);
  
  Song = getSong("bad apple");
  topPlayer = new NotePlayer(this, new int[]{0, 1}, Song[0], speed, harpistSprites, "C Note.wav", centerX + 8, centerY  - height /2);
  bottomPlayer = new NotePlayer(this, new int[]{0, -1}, Song[1], speed, lutistSprites, "C Note.wav", centerX + 8,  centerY + height /2);
  leftPlayer = new NotePlayer(this, new int[]{1, 0}, Song[2], speed, flautistSprites, "C Note.wav", centerX  - height /2,  centerY + 8);
  rightPlayer = new NotePlayer(this, new int[]{-1, 0}, Song[3], speed, drummerSprites, "C Note.wav", centerX + height /2,  centerY + 8);
  
    int x = centerPoint.getX() + dx * height /4;
  int y = centerPoint.getY() + dy * height /4;

  Entity zone = new Entity(this, dummySprites, x, y, 128, 128);

  frameRate(60);
}

void setupAnim()
{
  drummerSprites = new ArrayList<PImage[]>();
  drummerSprites.add(loadImagesFromFolder(sketchPath("data/Drummer/Idle")));
  drummerSprites.add(loadImagesFromFolder(sketchPath("data/Drummer/Atk1")));
  flautistSprites = new ArrayList<PImage[]>();
  flautistSprites.add(loadImagesFromFolder(sketchPath("data/Flautist/Idle")));
  flautistSprites.add(loadImagesFromFolder(sketchPath("data/Flautist/Atk1")));
  lutistSprites = new ArrayList<PImage[]>();
  lutistSprites.add(loadImagesFromFolder(sketchPath("data/Lutist/Idle")));
  lutistSprites.add(loadImagesFromFolder(sketchPath("data/Lutist/Atk1")));
  harpistSprites = new ArrayList<PImage[]>();
  harpistSprites.add(loadImagesFromFolder(sketchPath("data/Harpist/Idle")));
  harpistSprites.add(loadImagesFromFolder(sketchPath("data/Harpist/Atk1")));
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
  centerPoint.drawSprite();
  centerPoint.drawHitbox(this);
  for (Entity z : hitZones) {
    z.drawHitbox(this);
  }
  
  harpist.drawSprite();
  drummer.drawSprite();
  flautist.drawSprite();
  lutist.drawSprite();
  
  hitZones.clear();
  image(bgo, 0, 0);
  print(score);
}
void keyPressed() {
  keysDown.add((int)keyCode);
  checkDirectionalHits();
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
  int x = centerPoint.getX() + dx * height /4;
  int y = centerPoint.getY() + dy * height /4;

  Entity zone = new Entity(this, dummySprites, x, y, 128, 128);
  hitZones.add(zone);

  ArrayList<Note> notes = player.getNotes();
  for (Note n : notes) {
    if (!n.isHit() && n.intersects(zone)) {
      score += n.calculateScore(zone);
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
