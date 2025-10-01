class Path {
  float radius;
  ArrayList<PVector> points;

  Path() {
    this.radius = 20;
    this.points = new ArrayList<PVector>();
  }

  void addPoint(float x, float y) {
    PVector pathPoint = new PVector(x, y);
    this.points.add(pathPoint);
  }

  void show() {
    stroke(200);
    strokeWeight(this.radius * 2);
    noFill();
    beginShape();
    for (PVector pathPoint : this.points) {
      vertex(pathPoint.x, pathPoint.y);
    }
    endShape();
    
    stroke(0);
    strokeWeight(1);
    beginShape();
    for (PVector pathPoint : this.points) {
      vertex(pathPoint.x, pathPoint.y);
    }
    endShape();
  }
}
