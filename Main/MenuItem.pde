class MenuItem {
  String label;
  String file;
  PImage img;
  SoundFile sound;
  SoundFile song;
  float buttonW = 260;
  float buttonH = 60;
  float imgSize = 600;
  PImage thumbnail;

  MenuItem(String label, PImage img, SoundFile sound, SoundFile song, String file) {
    this.label = label;
    this.img = img;
    this.sound = sound;
    this.song = song;
    this.file = file;
    this.img.resize((int)imgSize, (int)imgSize);
    
    thumbnail = img.copy();
    thumbnail.resize(100, 100);

  }

  void display(float alpha) {
    noStroke();
    fill(255, alpha);
    rectMode(CENTER);
    rect(-100, 0, buttonW, buttonH, 20);

    fill(0, alpha);
    text(label, -100, 0);

    imageMode(CENTER);
    tint(255, alpha);
    image(thumbnail, 130, 0);
  }
}
