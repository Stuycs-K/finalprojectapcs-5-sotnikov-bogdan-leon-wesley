import processing.sound.SoundFile;
import java.util.HashSet;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.util.Arrays;

//Game Loop
NotePlayer topPlayer, bottomPlayer, leftPlayer, rightPlayer;
Entity centerPoint;
ArrayList<PImage[]> dummySprites;
int[][] Song;
int speed = 120;
HashSet<Integer> keysDown = new HashSet<Integer>();
ArrayList<Entity> hitZones = new ArrayList<Entity>();
PImage bg, bgo, crystal;
int score = 0;
ArrayList<PImage[]> drummerSprites, flautistSprites, lutistSprites, harpistSprites, enemySprites;
Entity[] sigils;
Entity drummer, flautist, harpist, lutist;
SoundFile SongAudio;

//Main Menu
ArrayList<MenuItem> items;
float scrollY = 0;
float targetScrollY = 0;
float spacing = 140;
float maxScale = 1.4;
float fadeStart = 180;
float scrollSpeed = 40;
MenuItem activeItem = null;
double timeOn = 0;
boolean played = false;

// Play Button
float playButtonX = 1300;
float playButtonY = 800;
float playButtonW = 600;
float playButtonH = 200;
float imageHeight = 600;

int Scene = 0;
int offset = 0;
int frames = 0;
boolean gameLoaded = false;
boolean gameOver = false;
int finalNote = 0;
boolean transition = false;
int counter = -360;
int alpha = 0;
static double dt;
double t;
boolean testNote = false;
boolean pause = false;
boolean gameStart = false;
float pauseTime = 0;
Note tester;


void setup() {
  size(1920, 1080);
  //fullScreen();
  t = System.currentTimeMillis();
  dt = 0;
  if (Scene == 0)
  {
    items = new ArrayList<MenuItem>();
    textAlign(CENTER, CENTER);
    textSize(20);
    smooth();

    items.add(new MenuItem("Bad Apple", loadImage(sketchPath("data/MenuItems/tester.jpg")), new SoundFile(this, sketchPath("data/MenuItems/example.wav")), new SoundFile(this, sketchPath("data/SongAudio/BadApple.mp3")), "BadApple"));
    items.add(new MenuItem("ksi", loadImage(sketchPath("data/MenuItems/ksi_thumbnail.png")), new SoundFile(this, sketchPath("data/MenuItems/ksi_snippet.mp3")), new SoundFile(this, sketchPath("data/SongAudio/ksi.mp3")), "ksi"));
    items.add(new MenuItem("Machine Love (feat. Teto)", loadImage(sketchPath("data/MenuItems/machinelove_thumbnail.png")),
      new SoundFile(this, sketchPath("data/MenuItems/machinelove_snippet.mp3")), new SoundFile(this, sketchPath("data/SongAudio/Machine Love (feat. Kasane Teto).mp3")), "MachineLove"));
    items.add(new MenuItem("Prokofiev", loadImage(sketchPath("data/MenuItems/example.png")), new SoundFile(this, sketchPath("data/MenuItems/example.wav")), new SoundFile(this, sketchPath("data/SongAudio/Prokofiev.mp3")), "Prokofiev"));
    items.add(new MenuItem("ploopy", loadImage(sketchPath("data/MenuItems/example.png")), new SoundFile(this, sketchPath("data/MenuItems/example.wav")), new SoundFile(this, sketchPath("data/SongAudio/ploopy.mp3")), "ploopy"));
  }
  // dummy code to keep func, can remove
  if (Scene == 1)
  {
    LoadGame();
  }
  frameRate(60);
}
double getDt()
{
  return dt;
}
void LoadGame()
{
  bg = loadImage(sketchPath("data/Background.png"));
  bgo = loadImage(sketchPath("data/BackgroundOverlay.png"));
  crystal = loadImage(sketchPath("data/crystal.png"));
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
  centerPoint = new Entity(this, dummySprites, centerX, centerY, 256, 256);
  drummer = new Entity(this, drummerSprites, centerX + 96, centerY, 128, 128);
  flautist = new Entity(this, flautistSprites, centerX -96, centerY, 128, 128);
  harpist = new Entity(this, harpistSprites, centerX, centerY - 96, 128, 128);
  lutist = new Entity(this, lutistSprites, centerX, centerY + 96, 128, 128);

  drummer.setFrameDelay(0, 20);
  flautist.setFrameDelay(0, 20);
  harpist.setFrameDelay(0, 20);
  lutist.setFrameDelay(0, 20);
  drummer.setFrameDelay(1, 5);
  flautist.setFrameDelay(1, 5);
  lutist.setFrameDelay(1, 5);
  harpist.setFrameDelay(1, 5);

  SoundFile currentSong = activeItem == null? new SoundFile(this, sketchPath("data/SongAudio/BadApple.mp3")) : activeItem.song;
  SongAudio = currentSong;
  Song = getSong(activeItem.file + ".txt");
  topPlayer = new NotePlayer(this, new int[]{0, 1}, Song[1], speed, enemySprites, centerX, centerY  - height /2);
  bottomPlayer = new NotePlayer(this, new int[]{0, -1}, Song[3], speed, lutistSprites, centerX, centerY + height /2);
  leftPlayer = new NotePlayer(this, new int[]{1, 0}, Song[0], speed, flautistSprites, centerX  - height /2, centerY );
  rightPlayer = new NotePlayer(this, new int[]{-1, 0}, Song[2  ], speed, drummerSprites, centerX + height /2, centerY );



  int offset = height/4;
  ArrayList<PImage[]> sigil = new ArrayList<PImage[]>();
  sigil.add(loadImagesFromFolder(sketchPath("data/Sigils")));
  sigils = new Entity[4];
  sigils[0] = new Entity(this, sigil, centerX  + offset, centerY, 128, 128);
  sigils[1] = new Entity(this, sigil, centerX  - offset, centerY, 128, 128);
  sigils[2] = new Entity(this, sigil, centerX, centerY  - offset, 128, 128);
  sigils[3] = new Entity(this, sigil, centerX, centerY + offset, 128, 128);
  gameLoaded = true;
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
  enemySprites = new ArrayList<PImage[]>();
  enemySprites.add(loadImagesFromFolder(sketchPath("data/Enemy/WalkDown")));
}

void draw() {
  dt = (System.currentTimeMillis() - t)/1000;
  t = System.currentTimeMillis();
  if (transition)
  {

    if (counter <= 0)
    {
      counter +=2;
      rectMode(CORNER);
      fill(0);
      alpha = constrain(alpha +1, 0, 255);
      tint(alpha);
      rect(counter * 8, 0, 2880, 1080, 300);
    }
    if (counter <= 360 && counter > 0)
    {
      counter +=2;
      switch(Scene)
      {
      case 0:
        MainMenu();
        break;
      case 1:
        if (gameLoaded) GameLoop();
        break;
      }
      rectMode(CORNER);
      fill(0);
      alpha = constrain(alpha -1, 0, 255);
      tint(alpha);
      rect(counter * 8, 0, 2880, 1080, 300);
    }
    if (counter == 360)
    {
      transition = false;
      counter = -360;
      alpha = 0;
    }
    tint(255, 255, 255);
  } else if (!pause)
  {
    switch(Scene)
    {
    case 0:
      MainMenu();
      break;
    case 1:
      if (gameLoaded) GameLoop();
      break;
    }
  }
}

void GameLoop()
{
  resetMatrix();
  image(bg, 0, 0);
  for (Entity m : sigils)
  {
    m.drawSprite();
  }
  if (transition == false)
  {
    frames++;
    if (testNote == false)
    {
      tester = rightPlayer.testNote();
      testNote = true;
    }
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

    if (tester != null  && gameStart == false)
    {
      tester.move((float)(-1 * speed * dt), 0);
      tester.drawHitbox(this);
      if ((int)tester.getX() <= (int)sigils[0].getX())
      {
        SongAudio.play();
        tester = null;
        offset += 20;
        gameStart = true;
      } else
      {
        offset++;
      }
    }
  }



  for (Entity z : hitZones) {
    z.drawHitbox(this);
  }

  harpist.drawSprite();
  image(crystal, width/2-64-8, height/2-64-8);
  drummer.drawSprite();
  flautist.drawSprite();
  lutist.drawSprite();
  hitZones.clear();
  image(bgo, 0, 0);
  if (frames - offset >= finalNote)
  {
    gameOver = true;
    drawEnd();
  }
}
void MainMenu()
{
  background(140);
  scrollY = lerp(scrollY, targetScrollY, 0.2);

  float centerY = height / 2;
  float closestDist = Float.MAX_VALUE;
  MenuItem cur = activeItem;
  for (int i = 0; i < items.size(); i++) {
    float y = i * spacing - scrollY + centerY;
    float distToCenter = abs(y - centerY);

    float scale = map(distToCenter, 0, centerY, maxScale, 0.6);
    scale = constrain(scale, 0.6, maxScale);

    float alpha = map(distToCenter, 0, fadeStart, 255, 0);
    alpha = constrain(alpha, 0, 255);

    pushMatrix();
    translate(width / 4, y);
    scale(scale);
    items.get(i).display(alpha);
    popMatrix();

    if (distToCenter < closestDist)
    {
      closestDist = distToCenter;
      activeItem = items.get(i);
    }
  }
  if (activeItem != null && cur != null && activeItem.label != cur.label)
  {
    cur.sound.jump(0);
    cur.sound.pause();
    timeOn = 0;
    played = false;
  }
  if (!played)
  {
    timeOn += dt;
  }

  if (played == false && timeOn > 1 && activeItem != null&& activeItem.sound != null && !activeItem.sound.isPlaying())
  {
    activeItem.sound.play();
    played = true;
  }

  drawPlayButton();
  drawImage();
}
void drawImage() {

  if (Scene == 0 && activeItem != null)
  {
    rectMode(CENTER);
    tint(255, 255, 255);
    image(activeItem.img, playButtonX, playButtonY -450, 600, 600);
  }
}
void drawPlayButton() {
  if (Scene == 0)
  {
    fill(60);
    stroke(255);
    rectMode(CENTER);
    rect(playButtonX, playButtonY, playButtonW, playButtonH, 10);
    fill(255);
    text("Play", playButtonX, playButtonY);
  }
}
void drawEnd() {
  fill(60);
  stroke(255);
  rectMode(CENTER);
  rect(width/2, height/2, playButtonW, playButtonH, 10);
  fill(255);
  text("Main Menu", width/2, height/2);
  text("Score:" + score, width/2, height/2 - 200);
}

void mousePressed() {
  if (Scene == 0)
  {
    if (mouseX > playButtonX - playButtonW/2 &&
      mouseX < playButtonX + playButtonW/2 &&
      mouseY > playButtonY - playButtonH/2 &&
      mouseY < playButtonY + playButtonH/2)
    {
      if (activeItem != null)
      {
        transition = true;
        activeItem.sound.jump(0);
        activeItem.sound.pause();
        switchScene(activeItem);
      }
    }
  }
  if (Scene == 1 && gameOver)
  {
    if (mouseX > width/2 - playButtonW/2 &&
      mouseX < width/2 + playButtonW/2 &&
      mouseY > height/2 - playButtonH/2 &&
      mouseY < height/2 + playButtonH/2)
    {
      if (activeItem != null)
      {
        transition = true;
        resetScene();
      }
    }
  }
}
void resetScene()
{
  activeItem = null;
  offset = 0;
  targetScrollY = 0;
  gameOver = false;
  gameLoaded = false;
  finalNote = 0;
  Scene = 0;
  tester = null;
  testNote = false;
  frames = 0;
}


void mouseWheel(MouseEvent event)
{
  float e = event.getCount();
  targetScrollY += e * scrollSpeed;
  targetScrollY = constrain(targetScrollY, 0, (items.size() - 1) * spacing);
}

void switchScene(MenuItem activeItem)
{
  Scene = 1;
  resetMatrix();
  noTint();
  imageMode(CORNER);
  rectMode(CORNER);
  LoadGame();
}


void keyPressed() {
  if (Scene == 1)
  {
    if (keyCode == ESC || key == 'p' || key == 'P') {
      key = 0;
      if (gameStart)
      {
        pause = !pause;
        if (pause) {
          pauseTime = SongAudio.position(); // get current position in seconds
          SongAudio.pause();
        } else {
          SongAudio.cue(pauseTime); // resume from where we paused
          SongAudio.play();
        }
      }
    }
    keysDown.add((int)keyCode);
    checkDirectionalHits();
    keysDown.remove((int)keyCode);
  }
}


void checkDirectionalHits() {
  if (keysDown.contains((int)'W') || keysDown.contains(UP)) {
    createHitZoneAndCheck(topPlayer, 0, -1, 'w');
    harpist.setAnim(1);
  }
  if (keysDown.contains((int)'S') || keysDown.contains(DOWN)) {
    createHitZoneAndCheck(bottomPlayer, 0, 1, 's');
    lutist.setAnim(1);
  }
  if (keysDown.contains((int)'A') || keysDown.contains(LEFT)) {
    createHitZoneAndCheck(leftPlayer, -1, 0, 'a');
    flautist.setAnim(1);
  }
  if (keysDown.contains((int)'D') || keysDown.contains(RIGHT)) {
    createHitZoneAndCheck(rightPlayer, 1, 0, 'd');
    drummer.setAnim(1);
  }
}

void createHitZoneAndCheck(NotePlayer player, int dx, int dy, char pressedKey) {
  float x = centerPoint.getX() + dx * height /4;
  float y = centerPoint.getY() + dy * height /4;

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
      int x = sc.nextInt();
      finalNote = x > finalNote? x : finalNote;
      lanes[i][j] = x;
    }
    sc.close();
  }

  return lanes;
}
