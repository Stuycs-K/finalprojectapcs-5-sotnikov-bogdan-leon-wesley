import processing.sound.SoundFile;
import java.util.HashSet;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
NotePlayer topPlayer, bottomPlayer, leftPlayer, rightPlayer;
Entity centerPoint;
ArrayList<PImage[]> dummySprites;
int[][] Song;
int speed = 2;
HashSet<Integer> keysDown = new HashSet<Integer>();
ArrayList<Entity> hitZones = new ArrayList<Entity>();
PImage bg, bgo;
int score = 0;
ArrayList<PImage[]> drummerSprites, flautistSprites, lutistSprites, harpistSprites;
Entity[] sigils;
Entity drummer, flautist, harpist, lutist;
SoundFile SongAudio;
void setup() {
  size(1920, 1080);
  //fullScreen();
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
  centerPoint = new Entity(this, dummySprites, centerX, centerY , 256, 256);
  drummer = new Entity(this, drummerSprites, centerX + 96, centerY, 128, 128);
  flautist = new Entity(this, flautistSprites, centerX -96 , centerY, 128, 128);
  harpist = new Entity(this, harpistSprites, centerX , centerY - 96, 128, 128);
  lutist = new Entity(this, lutistSprites, centerX, centerY + 96, 128, 128);
  
  drummer.setFrameDelay(20);
  flautist.setFrameDelay(20);
  harpist.setFrameDelay(20);
  lutist.setFrameDelay(20);
  
  SongAudio = new SoundFile(this, sketchPath("data/SongAudio/BadApple.mp3"));
  SongAudio.play();
  Song = getSong("BadApple.txt");
  topPlayer = new NotePlayer(this, new int[]{0, 1}, Song[1], speed, harpistSprites, "C Note.wav", centerX , centerY  - height /2);
  bottomPlayer = new NotePlayer(this, new int[]{0, -1}, Song[3], speed, lutistSprites, "C Note.wav", centerX ,  centerY + height /2);
  leftPlayer = new NotePlayer(this, new int[]{1, 0}, Song[0], speed, flautistSprites, "C Note.wav", centerX  - height /2,  centerY );
  rightPlayer = new NotePlayer(this, new int[]{-1, 0}, Song[2  ], speed, drummerSprites, "C Note.wav", centerX + height /2,  centerY );
  

  
  int offset = height/4;
  ArrayList<PImage[]> sigil = new ArrayList<PImage[]>();
  sigil.add(loadImagesFromFolder(sketchPath("data/Sigils")));
  sigils = new Entity[4];
  sigils[0] = new Entity(this, sigil, centerX  + offset, centerY , 128, 128);
  sigils[1] = new Entity(this, sigil, centerX  - offset, centerY  , 128, 128);
  sigils[2] = new Entity(this, sigil, centerX  , centerY  - offset, 128, 128);
  sigils[3] = new Entity(this, sigil, centerX  , centerY + offset, 128, 128);
  
  
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
  
  for (Entity m : sigils)
  {
    m.drawSprite();
  }
  
  hitZones.clear();
  image(bgo, 0, 0);
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
  File folder = new File(sketchPath("data/Songs/" + path));
  String[] lines = loadStrings(folder);
  int[][] lanes = new int[4][];

  for (int i = 0; i < 4; i++) {
    Scanner sc = new Scanner(lines[i]);
    int count = sc.nextInt();
    lanes[i] = new int[count];
    for (int j = 0; j < count; j++) {
      lanes[i][j] = sc.nextInt() - height * 3/ (4 * speed);
    }
    sc.close();
  }

  return lanes;
}
