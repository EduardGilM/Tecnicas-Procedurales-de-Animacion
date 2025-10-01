int TRIANGLE_COUNT = 12;
float TRIANGLE_SIZE = 6;
ArrayList<Agent> agents = new ArrayList<Agent>();
ArrayList<Path> paths = new ArrayList<Path>();
int currentPathIndex = 0;
boolean showPath = false;
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();

void setup() {
  size(800, 600);
  frameRate(60);
  for (int i = 0; i < TRIANGLE_COUNT; i++) {
    float x = random(50, width-50);
    float y = random(50, height-50);
    Agent agent = new Agent(#FF0000, new PVector(x, y));
    float angle = random(TWO_PI);
    float speed = random(2, 5);
    agent.velocity = new PVector(cos(angle) * speed, sin(angle) * speed);
    agents.add(agent);
  }
  
  if (agents.size() > 0) {
    agents.get(0).becomeZombie();
  }
  
  Path path1 = new Path();
  path1.addPoint(100, 100);
  path1.addPoint(300, 200);
  path1.addPoint(500, 100);
  path1.addPoint(700, 300);
  path1.addPoint(500, 500);
  path1.addPoint(100, 400);
  paths.add(path1);
  
  Path path2 = new Path();
  path2.addPoint(100, 300);
  path2.addPoint(700, 300);
  path2.addPoint(700, 150);
  path2.addPoint(100, 150);
  paths.add(path2);
  
  Path path3 = new Path();
  path3.addPoint(400, 100);
  path3.addPoint(650, 250);
  path3.addPoint(400, 400);
  path3.addPoint(150, 250);
  path3.addPoint(400, 100);
  paths.add(path3);
  
  Path path4 = new Path();
  path4.addPoint(150, 150);
  path4.addPoint(650, 150);
  path4.addPoint(650, 450);
  path4.addPoint(150, 450);
  path4.addPoint(150, 150);
  paths.add(path4);
  
  obstacles.add(new Obstacle(300, 200, 35, 0));
  obstacles.add(new Obstacle(500, 350, 40, 1));
  obstacles.add(new Obstacle(200, 450, 38, 2));
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
      a.setBehavior("pathFollow");
    }
    showPath = !showPath;
  }
  if (key == '5') {
    for (Agent a : agents) {
      a.setBehavior("separation");
    }
  }
  if (key == '6') {
    for (Agent a : agents) {
      a.setBehavior("alignment");
    }
  }
  if (key == '7') {
    for (Agent a : agents) {
      a.setBehavior("cohesion");
    }
  }
  if (key == '8') {
    for (Agent a : agents) {
      a.setBehavior("wander");
    }
  }
  if (key == '9') {
    for (Agent a : agents) {
      a.setBehavior("obstacleAvoidance");
    }
  }
  
  if (keyCode == LEFT) {
    currentPathIndex--;
    if (currentPathIndex < 0) {
      currentPathIndex = paths.size() - 1;
    }
  }
  
  if (keyCode == RIGHT) {
    currentPathIndex++;
    if (currentPathIndex >= paths.size()) {
      currentPathIndex = 0;
    }
  }
  
  if (key == 'r' || key == 'R') {
    agents.clear();
    for (int i = 0; i < TRIANGLE_COUNT; i++) {
      float x = random(50, width-50);
      float y = random(50, height-50);
      Agent agent = new Agent(#FF0000, new PVector(x, y));
      float angle = random(TWO_PI);
      float speed = random(2, 5);
      agent.velocity = new PVector(cos(angle) * speed, sin(angle) * speed);
      agents.add(agent);
    }
    if (agents.size() > 0) {
      agents.get(0).becomeZombie();
    }
  }
}

void draw() {
  background(20, 20, 40);
  
  stroke(60, 60, 100); 
  strokeWeight(2);
  noFill();
  int offset = 20; 
  rect(offset, offset, width - 2 * offset, height - 2 * offset);
  
  if (showPath) {
    paths.get(currentPathIndex).show();
  }
  
  for (Obstacle obs : obstacles) {
    obs.show();
  }
  
  drawUI();
  
  for (Agent a : agents) {
    a.update();
    a.show(); 
    a.checkCapture(agents);
    
    PVector mouse = new PVector(mouseX, mouseY);
    PVector force = new PVector(0, 0);
    
    if (a.isZombie) {
      force.add(a.pursueNearestHuman(agents).mult(a.pursueMultiplier));
      force.add(a.separateZombies(agents).mult(a.separationMultiplier));
      force.add(a.alignZombies(agents).mult(a.alignmentMultiplier));
      force.add(a.cohesionZombies(agents).mult(a.cohesionMultiplier));
    } else {
      force.add(a.evadeNearestZombie(agents).mult(a.evadeMultiplier));
    }
    if (a.behaviors.get("seek")) {
      force.add(a.seek(mouse).mult(a.seekMultiplier));
    }
    if (a.behaviors.get("flee")) {
      force.add(a.flee(mouse).mult(a.fleeMultiplier));
    }
    if (a.behaviors.get("arrive")) {
      force.add(a.arrive(mouse).mult(a.arriveMultiplier));
    }
    if (a.behaviors.get("wallAvoidance")) {
      force.add(a.wallAvoidance().mult(6));
    }
    if (a.behaviors.get("separation") && !a.isZombie) {
      force.add(a.separate(agents).mult(a.separationMultiplier));
    }
    if (a.behaviors.get("alignment") && !a.isZombie) {
      force.add(a.align(agents).mult(a.alignmentMultiplier));
    }
    if (a.behaviors.get("cohesion") && !a.isZombie) {
      force.add(a.cohesion(agents).mult(a.cohesionMultiplier));
    }
    if (a.behaviors.get("wander")) {
      force.add(a.wander().mult(a.wanderMultiplier));
    }
    if (a.behaviors.get("obstacleAvoidance")) {
      force.add(a.avoidObstacles(obstacles).mult(a.obstacleAvoidanceMultiplier));
    }
    if (a.behaviors.get("pathFollow")) {
      force.add(a.follow(paths.get(currentPathIndex)).mult(a.pathFollowMultiplier));
    }
    a.applyForce(force);
    }
  }

void drawUI() {
  fill(200, 220, 255);
  textSize(14);
  textAlign(LEFT);
  
  int yPos = 30;
  int lineHeight = 20;
  int xPos = 30;
  
  int zombieCount = 0;
  int humanCount = 0;
  for (Agent a : agents) {
    if (a.isZombie) {
      zombieCount++;
    } else {
      humanCount++;
    }
  }
  
  fill(0, 255, 0);
  text("ZOMBIES: " + zombieCount, xPos, yPos);
  yPos += lineHeight;
  
  fill(255, 0, 0);
  text("HUMANOS: " + humanCount, xPos, yPos);
  yPos += lineHeight + 10;
  
  if (humanCount == 0) {
    fill(255, 255, 0);
    textSize(18);
    text("¡LOS ZOMBIES HAN GANADO!", xPos, yPos);
    textSize(14);
    yPos += lineHeight + 10;
  }
  
  fill(200, 220, 255);
  text("CONTROLES:", xPos, yPos);
  yPos += lineHeight + 5;
  
  drawBehaviorStatus("0 - Wall Avoidance", agents.get(0).behaviors.get("wallAvoidance"), xPos, yPos);
  yPos += lineHeight;
  
  drawBehaviorStatus("1 - Seek (Mouse)", agents.get(0).behaviors.get("seek"), xPos, yPos);
  yPos += lineHeight;
  
  drawBehaviorStatus("2 - Flee (Mouse)", agents.get(0).behaviors.get("flee"), xPos, yPos);
  yPos += lineHeight;
  
  drawBehaviorStatus("3 - Arrive (Mouse)", agents.get(0).behaviors.get("arrive"), xPos, yPos);
  yPos += lineHeight;
  
  drawBehaviorStatus("4 - Path Follow", agents.get(0).behaviors.get("pathFollow"), xPos, yPos);
  yPos += lineHeight;
  
  drawBehaviorStatus("5 - Separation", agents.get(0).behaviors.get("separation"), xPos, yPos);
  yPos += lineHeight;
  
  drawBehaviorStatus("6 - Alignment", agents.get(0).behaviors.get("alignment"), xPos, yPos);
  yPos += lineHeight;
  
  drawBehaviorStatus("7 - Cohesion", agents.get(0).behaviors.get("cohesion"), xPos, yPos);
  yPos += lineHeight;
  
  drawBehaviorStatus("8 - Wander", agents.get(0).behaviors.get("wander"), xPos, yPos);
  yPos += lineHeight;
  
  drawBehaviorStatus("9 - Obstacle Avoidance", agents.get(0).behaviors.get("obstacleAvoidance"), xPos, yPos);
  yPos += lineHeight * 2;
  
  fill(200, 220, 255);
  text("← → : Cambiar Path (" + (currentPathIndex + 1) + "/" + paths.size() + ")", xPos, yPos);
  yPos += lineHeight;
  text("R : Reiniciar simulación", xPos, yPos);
}

void drawBehaviorStatus(String label, boolean isActive, int x, int y) {
  if (isActive) {
    fill(100, 255, 100);
    text("● " + label, x, y);
  } else {
    fill(150, 150, 170);
    text("○ " + label, x, y);
  }
}
