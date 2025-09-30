int TRIANGLE_COUNT = 12;
float TRIANGLE_SIZE = 15;
ArrayList<Agent> agents = new ArrayList<Agent>();

void setup() {
  size(800, 600);
  frameRate(60);
  for (int i = 0; i < TRIANGLE_COUNT; i++) {
    float x = random(width);
    float y = random(height);
    agents.add(new Agent(#FF0000, new PVector(x, y)));
  }
}

void keyPressed() {
    if (key == '0') {
    for (Agent a : agents) {
      a.setBehavior("wallAvoidance");
    }
  }
  if (key == '1') {
    for (Agent a : agents) {
      a.setBehavior("seek");
    }
  }
  if (key == '2') {
    for (Agent a : agents) {
      a.setBehavior("flee");
    }
  }
  if (key == '3') {
    for (Agent a : agents) {
      a.setBehavior("arrive");
    }
  }
  if (key == '4') {
    for (Agent a : agents) {
      a.setBehavior("separation");
    }
  }
}

void draw() {
  background(000);
  stroke(200); 
  noFill();
  int offset = 20; 
  rect(offset, offset, width - 2 * offset, height - 2 * offset);
  
  for (Agent a : agents) {
    a.update();
    a.show(); 
    PVector mouse = new PVector(mouseX, mouseY);
    PVector force = new PVector(0, 0);
    if (a.behaviors.get("seek")) {
      force.add(a.seek(mouse));
     
    }
    if (a.behaviors.get("flee")) {
      force.add(a.flee(mouse).mult(1.5));
    }
    if (a.behaviors.get("arrive")) {
      force.add(a.arrive(mouse));
    }
    if (a.behaviors.get("wallAvoidance")) {
      force.add(a.wallAvoidance().mult(5));
    }
    if (a.behaviors.get("separation")) {
      PVector sep = a.separate(agents);
      sep.mult(1.5);
      force.add(sep);
    }
    a.applyForce(force);
    }
  }
