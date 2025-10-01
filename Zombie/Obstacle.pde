class Obstacle {
  PVector position;
  float radius;
  int shapeType;
  color obstacleColor;
  
  Obstacle(float x, float y, float r, int shape) {
    this.position = new PVector(x, y);
    this.radius = r;
    this.shapeType = shape;
    this.obstacleColor = color(random(150, 255), random(50, 150), random(50, 150), 180);
  }
  
  Obstacle(float x, float y, float r) {
    this(x, y, r, 0);
  }
  
  void show() {
    fill(this.obstacleColor);
    stroke(red(this.obstacleColor) + 50, green(this.obstacleColor) + 50, blue(this.obstacleColor) + 50);
    strokeWeight(2);
    
    push();
    translate(this.position.x, this.position.y);
    
    switch(this.shapeType) {
      case 0:
        circle(0, 0, this.radius * 2);
        break;
      case 1:
        rectMode(CENTER);
        rect(0, 0, this.radius * 1.8, this.radius * 1.8);
        break;
      case 2:
        beginShape();
        float angle = TWO_PI / 3;
        for (int i = 0; i < 3; i++) {
          float x = cos(i * angle - PI/2) * this.radius;
          float y = sin(i * angle - PI/2) * this.radius;
          vertex(x, y);
        }
        endShape(CLOSE);
        break;
      case 3:
        beginShape();
        float hexAngle = TWO_PI / 6;
        for (int i = 0; i < 6; i++) {
          float x = cos(i * hexAngle) * this.radius;
          float y = sin(i * hexAngle) * this.radius;
          vertex(x, y);
        }
        endShape(CLOSE);
        break;
    }
    
    pop();
  }
}
