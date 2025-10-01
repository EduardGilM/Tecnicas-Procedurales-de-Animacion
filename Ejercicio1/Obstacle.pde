class Obstacle {
  PVector position;
  float radius;
  
  Obstacle(float x, float y, float r) {
    this.position = new PVector(x, y);
    this.radius = r;
  }
  
  void show() {
    fill(200, 50, 50, 150);
    stroke(255, 100, 100);
    strokeWeight(2);
    circle(this.position.x, this.position.y, this.radius * 2);
  }
}
