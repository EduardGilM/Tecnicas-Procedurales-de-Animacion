int TRIANGLE_COUNT = 12;
float TRIANGLE_SIZE = 6;
int TRAINING_STEPS = 50;
boolean evolveZombie = true; 
boolean evolveHuman = false; 
ArrayList<Agent> agents = new ArrayList<Agent>();
ArrayList<Path> paths = new ArrayList<Path>();
int currentPathIndex = 0;
boolean showPath = false;
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
Evolution evolution;
boolean trainingMode = false;
boolean showTreeMode = false;
int trainingStepsCompleted = 0;

// Áreas de la pantalla
int simulationWidth;
int treeWidth = 450;
int dividerX;

void setup() {
  fullScreen();
  frameRate(60);
  
  // Calcular áreas
  simulationWidth = width - treeWidth;
  dividerX = simulationWidth;
  
  for (int i = 0; i < TRIANGLE_COUNT; i++) {
    float x = random(50, simulationWidth-50);
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
  
  // Usar posiciones relativas al área de simulación
  float simW = simulationWidth;
  float simH = height;
  
  Path path1 = new Path();
  path1.addPoint(simW * 0.125, simH * 0.166);
  path1.addPoint(simW * 0.375, simH * 0.333);
  path1.addPoint(simW * 0.625, simH * 0.166);
  path1.addPoint(simW * 0.875, simH * 0.5);
  path1.addPoint(simW * 0.625, simH * 0.833);
  path1.addPoint(simW * 0.125, simH * 0.666);
  paths.add(path1);
  
  Path path2 = new Path();
  path2.addPoint(simW * 0.125, simH * 0.5);
  path2.addPoint(simW * 0.875, simH * 0.5);
  path2.addPoint(simW * 0.875, simH * 0.25);
  path2.addPoint(simW * 0.125, simH * 0.25);
  paths.add(path2);
  
  Path path3 = new Path();
  path3.addPoint(simW * 0.5, simH * 0.166);
  path3.addPoint(simW * 0.8125, simH * 0.416);
  path3.addPoint(simW * 0.5, simH * 0.666);
  path3.addPoint(simW * 0.1875, simH * 0.416);
  path3.addPoint(simW * 0.5, simH * 0.166);
  paths.add(path3);
  
  Path path4 = new Path();
  path4.addPoint(simW * 0.1875, simH * 0.25);
  path4.addPoint(simW * 0.8125, simH * 0.25);
  path4.addPoint(simW * 0.8125, simH * 0.75);
  path4.addPoint(simW * 0.1875, simH * 0.75);
  path4.addPoint(simW * 0.1875, simH * 0.25);
  paths.add(path4);
  
  obstacles.add(new Obstacle(simW * 0.375, simH * 0.333, 35, 0));
  obstacles.add(new Obstacle(simW * 0.625, simH * 0.583, 40, 1));
  obstacles.add(new Obstacle(simW * 0.25, simH * 0.75, 38, 2));
  
  Genotype zombieGenotype = new Genotype();
  Genotype humanGenotype = new Genotype();
  
  agents.get(0).genotype = zombieGenotype.copy();
  
  for (int i = 1; i < agents.size(); i++) {
    agents.get(i).genotype = humanGenotype.copy();
  }
  
  evolution = new Evolution(agents, zombieGenotype, humanGenotype);
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
    
    // Usar área completa si no estamos en modo entrenamiento
    float maxX = (trainingMode || showTreeMode) ? simulationWidth - 50 : width - 50;
    
    for (int i = 0; i < TRIANGLE_COUNT; i++) {
      float x = random(50, maxX);
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
    // Reiniciar con dos genotipos separados
    Genotype zombieGenotype = new Genotype();
    Genotype humanGenotype = new Genotype();
    
    agents.get(0).genotype = zombieGenotype.copy();
    for (int i = 1; i < agents.size(); i++) {
      agents.get(i).genotype = humanGenotype.copy();
    }
    
    evolution = new Evolution(agents, zombieGenotype, humanGenotype);
    trainingMode = false;
    showTreeMode = false;
    trainingStepsCompleted = 0;
  }
  
  if (key == '-') {
    trainingMode = true;
    showTreeMode = false;
    trainingStepsCompleted = 0;
    
    println("Iniciando entrenamiento de " + TRAINING_STEPS + " generaciones...");
  }
}

void draw() {
  background(20, 20, 40);
  
  // Dibujar divisor si estamos en modo entrenamiento
  if (trainingMode || showTreeMode) {
    stroke(100, 100, 150);
    strokeWeight(3);
    line(dividerX, 0, dividerX, height);
  }
  
  if (showTreeMode) {
    // Mostrar mensaje en el área de simulación
    fill(255, 255, 0);
    textSize(24);
    textAlign(CENTER);
    text("Entrenamiento completado!", simulationWidth/2, height/2 - 20);
    textSize(16);
    text("Mira el árbol de evolución a la derecha", simulationWidth/2, height/2 + 20);
    
    // Mostrar árbol en el lado derecho
    drawTreePanel();
    return;
  }
  
  if (trainingMode) {
    evolution.updateTimer();
    
    if (evolution.isTimeUp()) {
      trainingStepsCompleted++;
      println("Generación " + trainingStepsCompleted + "/" + TRAINING_STEPS + " completada. Score: " + evolution.calculateGenerationScore());
      
      if (trainingStepsCompleted >= TRAINING_STEPS) {
        trainingMode = false;
        showTreeMode = true;
        println("Entrenamiento completado!");
        if (evolveZombie) {
          println("Mejor score (Zombies): " + evolution.zombieEvolutionTree.getBestNode().score);
        }
        if (evolveHuman) {
          println("Mejor score (Humanos): " + evolution.humanEvolutionTree.getBestNode().score);
        }
        return;
      } else {
        evolution.nextGeneration();
        
        resetAgentsWithGenotypes(evolution.zombieGenotype, evolution.humanGenotype);
      }
    }
    
    fill(255, 255, 0);
    textSize(20);
    textAlign(CENTER);
    text("ENTRENAMIENTO: " + trainingStepsCompleted + "/" + TRAINING_STEPS, simulationWidth/2, 30);
    text("Tiempo: " + nf(evolution.timeRemaining, 0, 1) + "s", simulationWidth/2, 55);
    textAlign(LEFT);
    
    // Mostrar árbol en el lado derecho durante el entrenamiento
    drawTreePanel();
  } else {
    evolution.updateTimer();
  }
  
  // Dibujar borde del área de simulación
  stroke(60, 60, 100); 
  strokeWeight(2);
  noFill();
  int offset = 20;
  if (trainingMode || showTreeMode) {
    // Solo el área de simulación
    rect(offset, offset, simulationWidth - 2 * offset, height - 2 * offset);
  } else {
    // Toda la pantalla cuando no hay entrenamiento
    rect(offset, offset, width - 2 * offset, height - 2 * offset);
  }
  
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
      force.add(a.pursueNearestHuman(agents).mult(a.genotype.pursueMultiplier));
      force.add(a.separateZombies(agents).mult(a.genotype.separationMultiplier));
      force.add(a.alignZombies(agents).mult(a.genotype.alignmentMultiplier));
      force.add(a.cohesionZombies(agents).mult(a.genotype.cohesionMultiplier));
    } else {
      force.add(a.evadeNearestZombie(agents).mult(a.genotype.evadeMultiplier));
    }
    if (a.behaviors.get("seek")) {
      force.add(a.seek(mouse).mult(a.genotype.seekMultiplier));
    }
    if (a.behaviors.get("flee")) {
      force.add(a.flee(mouse).mult(a.genotype.fleeMultiplier));
    }
    if (a.behaviors.get("arrive")) {
      force.add(a.arrive(mouse).mult(a.genotype.arriveMultiplier));
    }
    if (a.behaviors.get("wallAvoidance")) {
      force.add(a.wallAvoidance().mult(6));
    }
    if (a.behaviors.get("separation") && !a.isZombie) {
      force.add(a.separate(agents).mult(a.genotype.separationMultiplier));
    }
    if (a.behaviors.get("alignment") && !a.isZombie) {
      force.add(a.align(agents).mult(a.genotype.alignmentMultiplier));
    }
    if (a.behaviors.get("cohesion") && !a.isZombie) {
      force.add(a.cohesion(agents).mult(a.genotype.cohesionMultiplier));
    }
    if (a.behaviors.get("wander")) {
      force.add(a.wander().mult(a.genotype.wanderMultiplier));
    }
    if (a.behaviors.get("obstacleAvoidance")) {
      force.add(a.avoidObstacles(obstacles).mult(a.genotype.obstacleAvoidanceMultiplier));
    }
    if (a.behaviors.get("pathFollow")) {
      force.add(a.follow(paths.get(currentPathIndex)).mult(a.genotype.pathFollowMultiplier));
    }
    a.applyForce(force);
  }
}

void resetAgentsWithGenotypes(Genotype zombieGenotype, Genotype humanGenotype) {
  agents.clear();
  for (int i = 0; i < TRIANGLE_COUNT; i++) {
    float x = random(50, simulationWidth-50);
    float y = random(50, height-50);
    Agent agent = new Agent(#FF0000, new PVector(x, y));
    float angle = random(TWO_PI);
    float speed = random(2, 5);
    agent.velocity = new PVector(cos(angle) * speed, sin(angle) * speed);
    
    // El primer agente es zombie con su genotipo
    if (i == 0) {
      agent.genotype = zombieGenotype.copy();
    } else {
      // Los demás son humanos con su genotipo
      agent.genotype = humanGenotype.copy();
    }
    
    agents.add(agent);
  }
  if (agents.size() > 0) {
    agents.get(0).becomeZombie();
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
  yPos += lineHeight;

  if (!showTreeMode) {
    fill(255, 255, 0);
    text("TIEMPO: " + nf(evolution.timeRemaining, 0, 1) + "s", xPos, yPos);
    yPos += lineHeight;
  }
  
  if (humanCount == 0) {
    fill(255, 255, 0);
    textSize(18);
    text("¡LOS ZOMBIES HAN GANADO!", xPos, yPos);
    textSize(14);
    yPos += lineHeight + 10;
  }
  
  yPos += 10;
  
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
  yPos += lineHeight;
  text("- : Iniciar entrenamiento (" + TRAINING_STEPS + " generaciones)", xPos, yPos);
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

void drawTreePanel() {
  // Área del panel del árbol
  pushMatrix();
  translate(dividerX, 0);
  
  // Fondo del panel
  fill(30, 30, 50);
  noStroke();
  rect(0, 0, treeWidth, height);
  
  // Título
  fill(255, 255, 0);
  textSize(20);
  textAlign(CENTER);
  text("ÁRBOL DE EVOLUCIÓN", treeWidth/2, 30);
  
  // Estadísticas generales en la parte superior
  fill(200, 220, 255);
  textSize(12);
  textAlign(LEFT);
  text("Generación actual: " + evolution.generation, 10, height - 30);
  text("Entrenamiento: " + trainingStepsCompleted + "/" + TRAINING_STEPS, 10, height - 15);
  
  if (evolveZombie && evolution.zombieEvolutionTree != null) {
    fill(100, 255, 100);
    textSize(14);
    textAlign(CENTER);
    text("Evolución de Zombies", treeWidth/2, 55);
    
    // Calcular posición para centrar el árbol en el panel
    float treeX = treeWidth/2;
    float treeY = 90;
    
    // Dibujar el árbol dentro del panel (sin translate adicional)
    // Necesitamos ajustar las coordenadas del árbol para que se dibuje en el espacio del panel
    pushMatrix();
    // El árbol usa coordenadas absolutas, así que necesitamos compensar
    translate(-dividerX, 0);
    evolution.zombieEvolutionTree.display(dividerX + treeX, treeY, 18);
    popMatrix();
    
    // Información del árbol en la parte inferior del panel
    fill(40, 40, 60);
    noStroke();
    rect(0, height - 200, treeWidth, 170);
    
    fill(255, 255, 255);
    textSize(14);
    textAlign(CENTER);
    text("Información del Árbol", treeWidth/2, height - 185);
    
    textAlign(LEFT);
    textSize(11);
    fill(200, 220, 255);
    text("Total de nodos: " + evolution.zombieEvolutionTree.allNodes.size(), 15, height - 160);
    text("Generaciones: " + (evolution.zombieEvolutionTree.getMaxDepth() + 1), 15, height - 140);
    
    TreeNode best = evolution.zombieEvolutionTree.getBestNode();
    fill(100, 255, 100);
    text("Mejor Score: " + nf(best.score, 0, 2), 15, height - 120);
    text("En generación: " + best.generation, 15, height - 100);
    
    fill(200, 220, 255);
    text("Score Promedio: " + nf(evolution.zombieEvolutionTree.getAverageScore(), 0, 2), 15, height - 80);
    text("Score Mínimo: " + nf(evolution.zombieEvolutionTree.getMinScore(), 0, 2), 15, height - 60);
  }
  else if (evolveHuman && evolution.humanEvolutionTree != null) {
    fill(255, 100, 100);
    textSize(14);
    textAlign(CENTER);
    text("Evolución de Humanos", treeWidth/2, 55);
    
    // Calcular posición para centrar el árbol en el panel
    float treeX = treeWidth/2;
    float treeY = 90;
    
    // Dibujar el árbol dentro del panel
    pushMatrix();
    translate(-dividerX, 0);
    evolution.humanEvolutionTree.display(dividerX + treeX, treeY, 18);
    popMatrix();
    
    // Información del árbol en la parte inferior del panel
    fill(40, 40, 60);
    noStroke();
    rect(0, height - 200, treeWidth, 170);
    
    fill(255, 255, 255);
    textSize(14);
    textAlign(CENTER);
    text("Información del Árbol", treeWidth/2, height - 185);
    
    textAlign(LEFT);
    textSize(11);
    fill(200, 220, 255);
    text("Total de nodos: " + evolution.humanEvolutionTree.allNodes.size(), 15, height - 160);
    text("Generaciones: " + (evolution.humanEvolutionTree.getMaxDepth() + 1), 15, height - 140);
    
    TreeNode best = evolution.humanEvolutionTree.getBestNode();
    fill(255, 100, 100);
    text("Mejor Score: " + nf(best.score, 0, 2), 15, height - 120);
    text("En generación: " + best.generation, 15, height - 100);
    
    fill(200, 220, 255);
    text("Score Promedio: " + nf(evolution.humanEvolutionTree.getAverageScore(), 0, 2), 15, height - 80);
    text("Score Mínimo: " + nf(evolution.humanEvolutionTree.getMinScore(), 0, 2), 15, height - 60);
  }
  
  popMatrix();
}
