class MenuItem {
  String label;
  PImage img;
  SoundFile sound;
  float buttonW = 260;
  float buttonH = 60;
  float imgSize = 100;

  MenuItem(String label, PImage img, SoundFile sound) {
    this.label = label;
    this.img = img;
    this.sound = sound;
    img.resize((int)imgSize, (int)imgSize);
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
    image(img, 130, 0);
  }
}
