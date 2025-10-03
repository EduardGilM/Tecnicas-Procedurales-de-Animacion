int TRIANGLE_COUNT = 101;
float TRIANGLE_SIZE = 6;
int TRAINING_STEPS = 200;
boolean evolveZombie = true; 
boolean evolveHuman = false;
boolean countAgents = true; // Si es true, suma la cantidad de agentes del grupo al score 

// Configuración física de agentes
float ZOMBIE_BASE_SPEED = 7.0;   // Velocidad base de zombies
float ZOMBIE_BASE_FORCE = 0.12;  // Fuerza base de zombies
float HUMAN_BASE_SPEED = 7.0;    // Velocidad base de humanos (más rápidos)
float HUMAN_BASE_FORCE = 0.12;   // Fuerza base de humanos

ArrayList<Agent> agents = new ArrayList<Agent>();
ArrayList<Path> paths = new ArrayList<Path>();
int currentPathIndex = 0;
boolean showPath = false;
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
Evolution evolution;
boolean trainingMode = false;
boolean showTreeMode = false;
int trainingStepsCompleted = 0;

// Promedio móvil para la gráfica
int[] movingAverageOptions = {1, 5, 10, 20, 50, 100};
int movingAverageIndex = 0;
int movingAverageWindow = 1;

// Áreas de la pantalla
int simulationWidth;
int treeWidth = 450;
int dividerX;
float simulationBottomLimit; // Límite inferior para que los agentes no entren en la gráfica

void setup() {
  fullScreen();
  frameRate(60);
  
  // Calcular áreas
  simulationWidth = width - treeWidth;
  dividerX = simulationWidth;
  simulationBottomLimit = height; // Se actualizará cuando haya gráfica
  
  for (int i = 0; i < TRIANGLE_COUNT; i++) {
    float x = random(50, simulationWidth-50);
    float y = random(50, height-50);
    Agent agent = new Agent(#FF0000, new PVector(x, y));
    float angle = random(TWO_PI);
    float speed = random(2, 5);
    agent.velocity = new PVector(cos(angle) * speed, sin(angle) * speed);
    
    // Configurar valores base según el tipo
    if (i == 0) {
      agent.baseMaxSpeed = ZOMBIE_BASE_SPEED;
      agent.baseMaxForce = ZOMBIE_BASE_FORCE;
    } else {
      agent.baseMaxSpeed = HUMAN_BASE_SPEED;
      agent.baseMaxForce = HUMAN_BASE_FORCE;
    }
    agent.updatePhysicalAttributes();
    
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
  
  obstacles.add(new Obstacle(simW * 0.375, simH * 0.333, 35, 0)); // Círculo
  obstacles.add(new Obstacle(simW * 0.625, simH * 0.583, 40, 1)); // Cuadrado
  // Obstáculo triangular y hexagonal eliminados
  
  Genotype zombieGenotype = new Genotype();
  Genotype humanGenotype = new Genotype();
  
  agents.get(0).genotype = zombieGenotype.copy();
  
  for (int i = 1; i < agents.size(); i++) {
    agents.get(i).genotype = humanGenotype.copy();
  }
  
  evolution = new Evolution(agents, zombieGenotype, humanGenotype, countAgents);
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
  
  if (keyCode == UP) {
    movingAverageIndex++;
    if (movingAverageIndex >= movingAverageOptions.length) {
      movingAverageIndex = movingAverageOptions.length - 1;
    }
    movingAverageWindow = movingAverageOptions[movingAverageIndex];
    println("Promedio móvil: " + movingAverageWindow);
  }
  
  if (keyCode == DOWN) {
    movingAverageIndex--;
    if (movingAverageIndex < 0) {
      movingAverageIndex = 0;
    }
    movingAverageWindow = movingAverageOptions[movingAverageIndex];
    println("Promedio móvil: " + movingAverageWindow);
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
    
    evolution = new Evolution(agents, zombieGenotype, humanGenotype, countAgents);
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
  
  // Actualizar el límite inferior para los agentes ANTES de que se muevan
  if (trainingMode || showTreeMode) {
    // Calcular el límite basado en las dimensiones de la gráfica
    float graphHeight = 300;
    float graphY = height - graphHeight - 30;
    simulationBottomLimit = graphY - 20;
  } else {
    simulationBottomLimit = height; // Sin gráfica, usar toda la pantalla
  }
  
  // Dibujar divisor si estamos en modo entrenamiento
  if (trainingMode || showTreeMode) {
    stroke(100, 100, 150);
    strokeWeight(3);
    line(dividerX, 0, dividerX, height);
  }
  
  if (showTreeMode) {
    // Dibujar gráfica grande en pantalla completa
    drawLargeEvolutionGraph();
    
    // Texto de información
    fill(255, 255, 0);
    textSize(28);
    textAlign(CENTER);
    text("¡Entrenamiento completado!", width/2, 50);
    textSize(16);
    fill(200, 220, 255);
    text("Presiona 'R' para reiniciar", width/2, 90);
    
    return;
  }
  
  if (trainingMode) {
    evolution.updateTimer();
    
    if (evolution.isTimeUp()) {
      trainingStepsCompleted++;
      String scoreInfo = "";
      if (evolveZombie && evolveHuman) {
        scoreInfo = "Zombie Score: " + evolution.calculateZombieScore() + ", Human Score: " + evolution.calculateHumanScore();
      } else if (evolveZombie) {
        scoreInfo = "Zombie Score: " + evolution.calculateZombieScore();
      } else if (evolveHuman) {
        scoreInfo = "Human Score: " + evolution.calculateHumanScore();
      }
      println("Generación " + trainingStepsCompleted + "/" + TRAINING_STEPS + " completada. " + scoreInfo);
      
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
      force.add(a.separate(agents).mult(a.genotype.separationMultiplier));
      force.add(a.align(agents).mult(a.genotype.alignmentMultiplier));
      force.add(a.cohesion(agents).mult(a.genotype.cohesionMultiplier));

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
      force.add(a.wallAvoidance().mult(15)); // Aumentado de 6 a 15 para mayor fuerza
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
  
  // Dibujar gráfica de evolución en la parte inferior (solo en modo entrenamiento o árbol)
  if (trainingMode || showTreeMode) {
    drawEvolutionGraph();
  }
  
  // Dibujar borde del área de simulación DESPUÉS de la gráfica para que quede encima
  stroke(60, 60, 100); 
  strokeWeight(2);
  noFill();
  int offset = 20;
  if (trainingMode || showTreeMode) {
    // Solo el área de simulación, usando simulationBottomLimit para delimitar sobre la gráfica
    float rectHeight = simulationBottomLimit - 2 * offset;
    rect(offset, offset, simulationWidth - 2 * offset, rectHeight);
  } else {
    // Toda la pantalla cuando no hay entrenamiento
    rect(offset, offset, width - 2 * offset, height - 2 * offset);
  }
}

void resetAgentsWithGenotypes(Genotype zombieGenotype, Genotype humanGenotype) {
  agents.clear();
  for (int i = 0; i < TRIANGLE_COUNT; i++) {
    float x = random(50, simulationWidth-50);
    // Limitar la posición Y para evitar que aparezcan en el área de la gráfica
    float maxY = (trainingMode || showTreeMode) ? simulationBottomLimit - 50 : height - 50;
    float y = random(50, maxY);
    Agent agent = new Agent(#FF0000, new PVector(x, y));
    float angle = random(TWO_PI);
    float speed = random(2, 5);
    agent.velocity = new PVector(cos(angle) * speed, sin(angle) * speed);
    
    // El primer agente es zombie con su genotipo
    if (i == 0) {
      agent.genotype = zombieGenotype.copy();
      agent.baseMaxSpeed = ZOMBIE_BASE_SPEED;
      agent.baseMaxForce = ZOMBIE_BASE_FORCE;
      agent.updatePhysicalAttributes();
    } else {
      // Los demás son humanos con su genotipo
      agent.genotype = humanGenotype.copy();
      agent.baseMaxSpeed = HUMAN_BASE_SPEED;
      agent.baseMaxForce = HUMAN_BASE_FORCE;
      agent.updatePhysicalAttributes();
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
    evolution.zombieEvolutionTree.display(dividerX + treeX, treeY, 18, treeWidth);
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
    text("Mejor Score: " + nf(best.score, 0, 2) + " seg", 15, height - 120);
    text("En generación: " + best.generation, 15, height - 100);
    
    fill(150, 150, 200);
    textSize(9);
    text("(Score = tiempo restante al ganar)", 15, height - 85);
    textSize(11);
    
    fill(200, 220, 255);
    text("Score Promedio: " + nf(evolution.zombieEvolutionTree.getAverageScore(), 0, 2), 15, height - 70);
    text("Score Mínimo: " + nf(evolution.zombieEvolutionTree.getMinScore(), 0, 2), 15, height - 50);
    
    // Mostrar valores del genotipo del NODO ACTUAL (última generación)
    float rightColX = treeWidth / 2 + 20;
    textAlign(LEFT);
    textSize(10);
    fill(255, 200, 100);
    
    if (evolution.currentZombieNode != null) {
      text("Genotipo Actual (Gen " + evolution.currentZombieNode.generation + "):", rightColX, height - 160);
      
      // Obtener genotipo del padre si existe
      TreeNode current = evolution.currentZombieNode;
      Genotype parentGenotype = (current.parent != null) ? current.parent.genotype : null;
      
      textSize(9);
      int yPos = height - 145;
      int lineSpacing = 12;
      
      drawGenotypeValue("Speed", current.genotype.speedMultiplier, parentGenotype != null ? parentGenotype.speedMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Force", current.genotype.forceMultiplier, parentGenotype != null ? parentGenotype.forceMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Pursue", current.genotype.pursueMultiplier, parentGenotype != null ? parentGenotype.pursueMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Evade", current.genotype.evadeMultiplier, parentGenotype != null ? parentGenotype.evadeMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Separ.", current.genotype.separationMultiplier, parentGenotype != null ? parentGenotype.separationMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Align.", current.genotype.alignmentMultiplier, parentGenotype != null ? parentGenotype.alignmentMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Cohes.", current.genotype.cohesionMultiplier, parentGenotype != null ? parentGenotype.cohesionMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Wander", current.genotype.wanderMultiplier, parentGenotype != null ? parentGenotype.wanderMultiplier : 0, parentGenotype != null, rightColX, yPos);
    } else {
      text("Genotipo no disponible", rightColX, height - 160);
    }
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
    evolution.humanEvolutionTree.display(dividerX + treeX, treeY, 18, treeWidth);
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
    text("Mejor Score: " + nf(best.score, 0, 2) + " seg", 15, height - 120);
    text("En generación: " + best.generation, 15, height - 100);
    
    fill(150, 150, 200);
    textSize(9);
    text("(Score = tiempo sobrevivido)", 15, height - 85);
    textSize(11);
    
    fill(200, 220, 255);
    text("Score Promedio: " + nf(evolution.humanEvolutionTree.getAverageScore(), 0, 2), 15, height - 70);
    text("Score Mínimo: " + nf(evolution.humanEvolutionTree.getMinScore(), 0, 2), 15, height - 50);
    
    // Mostrar valores del genotipo del NODO ACTUAL (última generación)
    float rightColX = treeWidth / 2 + 20;
    textAlign(LEFT);
    textSize(10);
    fill(255, 200, 100);
    
    if (evolution.currentHumanNode != null) {
      text("Genotipo Actual (Gen " + evolution.currentHumanNode.generation + "):", rightColX, height - 160);
      
      // Obtener genotipo del padre si existe
      TreeNode current = evolution.currentHumanNode;
      Genotype parentGenotype = (current.parent != null) ? current.parent.genotype : null;
      
      textSize(9);
      int yPos = height - 145;
      int lineSpacing = 12;
      
      drawGenotypeValue("Speed", current.genotype.speedMultiplier, parentGenotype != null ? parentGenotype.speedMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Force", current.genotype.forceMultiplier, parentGenotype != null ? parentGenotype.forceMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Pursue", current.genotype.pursueMultiplier, parentGenotype != null ? parentGenotype.pursueMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Evade", current.genotype.evadeMultiplier, parentGenotype != null ? parentGenotype.evadeMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Separ.", current.genotype.separationMultiplier, parentGenotype != null ? parentGenotype.separationMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Align.", current.genotype.alignmentMultiplier, parentGenotype != null ? parentGenotype.alignmentMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Cohes.", current.genotype.cohesionMultiplier, parentGenotype != null ? parentGenotype.cohesionMultiplier : 0, parentGenotype != null, rightColX, yPos); yPos += lineSpacing;
      drawGenotypeValue("Wander", current.genotype.wanderMultiplier, parentGenotype != null ? parentGenotype.wanderMultiplier : 0, parentGenotype != null, rightColX, yPos);
    } else {
      text("Genotipo no disponible", rightColX, height - 160);
    }
  }
  
  popMatrix();
}

void drawEvolutionGraph() {
  // Dimensiones y posición de la gráfica
  float graphHeight = 300; // Aumentado de 200 a 300 para reducir el área de movimiento
  float graphWidth = simulationWidth - 100;
  float graphX = 50;
  float graphY = height - graphHeight - 30;
  float padding = 40;
  
  // Fondo de la gráfica
  fill(30, 30, 50, 230);
  stroke(100, 100, 150);
  strokeWeight(2);
  rect(graphX, graphY, graphWidth, graphHeight);
  
  // Área de dibujo de la gráfica (con padding)
  float plotX = graphX + padding;
  float plotY = graphY + padding;
  float plotWidth = graphWidth - 2 * padding;
  float plotHeight = graphHeight - 2 * padding;
  
  // Obtener datos
  ArrayList<Float> zombieScores = null;
  ArrayList<Float> humanScores = null;
  int maxGenerations = 0;
  float maxScore = 0;
  float minScore = Float.MAX_VALUE;
  
  if (evolveZombie && evolution.zombieEvolutionTree != null) {
    zombieScores = evolution.zombieEvolutionTree.getBestScoresByGeneration();
    zombieScores = applyMovingAverage(zombieScores, movingAverageWindow);
    maxGenerations = max(maxGenerations, zombieScores.size());
    for (float score : zombieScores) {
      maxScore = max(maxScore, score);
      minScore = min(minScore, score);
    }
  }
  
  if (evolveHuman && evolution.humanEvolutionTree != null) {
    humanScores = evolution.humanEvolutionTree.getBestScoresByGeneration();
    humanScores = applyMovingAverage(humanScores, movingAverageWindow);
    maxGenerations = max(maxGenerations, humanScores.size());
    for (float score : humanScores) {
      maxScore = max(maxScore, score);
      minScore = min(minScore, score);
    }
  }
  
  if (maxGenerations == 0) return;
  
  // Agregar un pequeño margen a los valores
  float scoreRange = maxScore - minScore;
  if (scoreRange < 0.1) scoreRange = 1.0;
  minScore -= scoreRange * 0.1;
  maxScore += scoreRange * 0.1;
  
  // Dibujar ejes
  stroke(150, 150, 180);
  strokeWeight(2);
  line(plotX, plotY, plotX, plotY + plotHeight); // Eje Y
  line(plotX, plotY + plotHeight, plotX + plotWidth, plotY + plotHeight); // Eje X
  
  // Título
  fill(255, 255, 0);
  textSize(14);
  textAlign(CENTER);
  String title = "Evolución del Mejor Score por Generación";
  if (movingAverageWindow > 1) {
    title += " (Promedio: " + movingAverageWindow + ")";
  }
  text(title, graphX + graphWidth/2, graphY + 15);
  
  // Etiquetas del eje Y
  fill(200, 220, 255);
  textSize(10);
  textAlign(RIGHT, CENTER);
  for (int i = 0; i <= 4; i++) {
    float y = plotY + plotHeight - (i * plotHeight / 4);
    float value = minScore + (maxScore - minScore) * i / 4;
    text(nf(value, 0, 1), plotX - 5, y);
    
    // Líneas de guía
    stroke(80, 80, 100, 100);
    strokeWeight(1);
    line(plotX, y, plotX + plotWidth, y);
  }
  
  // Etiquetas del eje X
  textAlign(CENTER, TOP);
  int step = max(1, maxGenerations / 10);
  for (int i = 0; i <= maxGenerations; i += step) {
    float x = maxGenerations > 1 ? plotX + (i * plotWidth / (maxGenerations - 1)) : plotX;
    text(i, x, plotY + plotHeight + 5);
  }
  
  // Etiqueta del eje X
  textSize(11);
  text("Generación", graphX + graphWidth/2, graphY + graphHeight - 5);
  
  // Etiqueta del eje Y
  pushMatrix();
  translate(graphX + 10, graphY + graphHeight/2);
  rotate(-HALF_PI);
  text("Score Máximo", 0, 0);
  popMatrix();
  
  // Dibujar líneas de evolución
  strokeWeight(3);
  noFill();
  
  // Línea de zombies (verde)
  if (zombieScores != null && zombieScores.size() > 0) {
    stroke(100, 255, 100);
    if (zombieScores.size() > 1) {
      beginShape();
      for (int i = 0; i < zombieScores.size(); i++) {
        float x = plotX + (i * plotWidth / (maxGenerations - 1));
        float normalizedScore = map(zombieScores.get(i), minScore, maxScore, 0, 1);
        float y = plotY + plotHeight - (normalizedScore * plotHeight);
        vertex(x, y);
      }
      endShape();
    }
    
    // Puntos
    fill(100, 255, 100);
    noStroke();
    for (int i = 0; i < zombieScores.size(); i++) {
      float x = zombieScores.size() > 1 ? plotX + (i * plotWidth / (maxGenerations - 1)) : plotX;
      float normalizedScore = map(zombieScores.get(i), minScore, maxScore, 0, 1);
      float y = plotY + plotHeight - (normalizedScore * plotHeight);
      ellipse(x, y, 6, 6);
    }
  }
  
  // Línea de humanos (rojo)
  if (humanScores != null && humanScores.size() > 0) {
    stroke(255, 100, 100);
    noFill();
    if (humanScores.size() > 1) {
      beginShape();
      for (int i = 0; i < humanScores.size(); i++) {
        float x = plotX + (i * plotWidth / (maxGenerations - 1));
        float normalizedScore = map(humanScores.get(i), minScore, maxScore, 0, 1);
        float y = plotY + plotHeight - (normalizedScore * plotHeight);
        vertex(x, y);
      }
      endShape();
    }
    
    // Puntos
    fill(255, 100, 100);
    noStroke();
    for (int i = 0; i < humanScores.size(); i++) {
      float x = humanScores.size() > 1 ? plotX + (i * plotWidth / (maxGenerations - 1)) : plotX;
      float normalizedScore = map(humanScores.get(i), minScore, maxScore, 0, 1);
      float y = plotY + plotHeight - (normalizedScore * plotHeight);
      ellipse(x, y, 6, 6);
    }
  }
  
  // Leyenda
  float legendX = plotX + plotWidth - 120;
  float legendY = plotY + 10;
  
  if (zombieScores != null) {
    fill(100, 255, 100);
    ellipse(legendX, legendY, 10, 10);
    fill(200, 220, 255);
    textAlign(LEFT, CENTER);
    textSize(11);
    text("Zombies", legendX + 10, legendY);
    legendY += 20;
  }
  
  if (humanScores != null) {
    fill(255, 100, 100);
    ellipse(legendX, legendY, 10, 10);
    fill(200, 220, 255);
    textAlign(LEFT, CENTER);
    textSize(11);
    text("Humanos", legendX + 10, legendY);
  }
}

void drawLargeEvolutionGraph() {
  // Dimensiones para gráfica grande (pantalla completa)
  float margin = 80;
  float graphWidth = width - 2 * margin;
  float graphHeight = height - 180;
  float graphX = margin;
  float graphY = 120;
  float padding = 60;
  
  // Fondo de la gráfica
  fill(30, 30, 50, 250);
  stroke(100, 100, 150);
  strokeWeight(3);
  rect(graphX, graphY, graphWidth, graphHeight);
  
  // Área de dibujo de la gráfica (con padding)
  float plotX = graphX + padding;
  float plotY = graphY + padding;
  float plotWidth = graphWidth - 2 * padding;
  float plotHeight = graphHeight - 2 * padding;
  
  // Obtener datos
  ArrayList<Float> zombieScores = null;
  ArrayList<Float> humanScores = null;
  int maxGenerations = 0;
  float maxScore = 0;
  float minScore = Float.MAX_VALUE;
  
  if (evolveZombie && evolution.zombieEvolutionTree != null) {
    zombieScores = evolution.zombieEvolutionTree.getBestScoresByGeneration();
    zombieScores = applyMovingAverage(zombieScores, movingAverageWindow);
    maxGenerations = max(maxGenerations, zombieScores.size());
    for (float score : zombieScores) {
      maxScore = max(maxScore, score);
      minScore = min(minScore, score);
    }
  }
  
  if (evolveHuman && evolution.humanEvolutionTree != null) {
    humanScores = evolution.humanEvolutionTree.getBestScoresByGeneration();
    humanScores = applyMovingAverage(humanScores, movingAverageWindow);
    maxGenerations = max(maxGenerations, humanScores.size());
    for (float score : humanScores) {
      maxScore = max(maxScore, score);
      minScore = min(minScore, score);
    }
  }
  
  if (maxGenerations == 0) return;
  
  // Agregar un pequeño margen a los valores
  float scoreRange = maxScore - minScore;
  if (scoreRange < 0.1) scoreRange = 1.0;
  minScore -= scoreRange * 0.1;
  maxScore += scoreRange * 0.1;
  
  // Dibujar ejes
  stroke(150, 150, 180);
  strokeWeight(3);
  line(plotX, plotY, plotX, plotY + plotHeight); // Eje Y
  line(plotX, plotY + plotHeight, plotX + plotWidth, plotY + plotHeight); // Eje X
  
  // Título
  fill(255, 255, 100);
  textSize(20);
  textAlign(CENTER);
  String title = "Evolución del Mejor Score por Generación";
  if (movingAverageWindow > 1) {
    title += " (Promedio: " + movingAverageWindow + ")";
  }
  text(title, graphX + graphWidth/2, graphY + 25);
  
  // Etiquetas del eje Y
  fill(200, 220, 255);
  textSize(14);
  textAlign(RIGHT, CENTER);
  for (int i = 0; i <= 5; i++) {
    float y = plotY + plotHeight - (i * plotHeight / 5);
    float value = minScore + (maxScore - minScore) * i / 5;
    text(nf(value, 0, 1), plotX - 10, y);
    
    // Líneas de guía
    stroke(80, 80, 100, 100);
    strokeWeight(1);
    line(plotX, y, plotX + plotWidth, y);
  }
  
  // Etiquetas del eje X
  textAlign(CENTER, TOP);
  int step = max(1, maxGenerations / 15);
  for (int i = 0; i <= maxGenerations; i += step) {
    float x = maxGenerations > 1 ? plotX + (i * plotWidth / (maxGenerations - 1)) : plotX;
    text(i, x, plotY + plotHeight + 10);
  }
  
  // Etiqueta del eje X
  textSize(16);
  text("Generación", graphX + graphWidth/2, graphY + graphHeight - 15);
  
  // Etiqueta del eje Y
  pushMatrix();
  translate(graphX + 15, graphY + graphHeight/2);
  rotate(-HALF_PI);
  text("Score Máximo", 0, 0);
  popMatrix();
  
  // Dibujar líneas de evolución
  strokeWeight(4);
  noFill();
  
  // Línea de zombies (verde)
  if (zombieScores != null && zombieScores.size() > 0) {
    stroke(100, 255, 100);
    if (zombieScores.size() > 1) {
      beginShape();
      for (int i = 0; i < zombieScores.size(); i++) {
        float x = plotX + (i * plotWidth / (maxGenerations - 1));
        float normalizedScore = map(zombieScores.get(i), minScore, maxScore, 0, 1);
        float y = plotY + plotHeight - (normalizedScore * plotHeight);
        vertex(x, y);
      }
      endShape();
    }
    
    // Puntos
    fill(100, 255, 100);
    for (int i = 0; i < zombieScores.size(); i++) {
      float x = plotX + (i * plotWidth / (maxGenerations - 1));
      float normalizedScore = map(zombieScores.get(i), minScore, maxScore, 0, 1);
      float y = plotY + plotHeight - (normalizedScore * plotHeight);
      ellipse(x, y, 8, 8);
    }
  }
  
  // Línea de humanos (rojo)
  if (humanScores != null && humanScores.size() > 0) {
    stroke(255, 100, 100);
    noFill();
    if (humanScores.size() > 1) {
      beginShape();
      for (int i = 0; i < humanScores.size(); i++) {
        float x = plotX + (i * plotWidth / (maxGenerations - 1));
        float normalizedScore = map(humanScores.get(i), minScore, maxScore, 0, 1);
        float y = plotY + plotHeight - (normalizedScore * plotHeight);
        vertex(x, y);
      }
      endShape();
    }
    
    // Puntos
    fill(255, 100, 100);
    for (int i = 0; i < humanScores.size(); i++) {
      float x = plotX + (i * plotWidth / (maxGenerations - 1));
      float normalizedScore = map(humanScores.get(i), minScore, maxScore, 0, 1);
      float y = plotY + plotHeight - (normalizedScore * plotHeight);
      ellipse(x, y, 8, 8);
    }
  }
  
  // Leyenda
  float legendX = plotX + plotWidth - 150;
  float legendY = plotY + 20;
  
  if (zombieScores != null) {
    fill(100, 255, 100);
    ellipse(legendX, legendY, 15, 15);
    fill(200, 220, 255);
    textAlign(LEFT, CENTER);
    textSize(14);
    text("Zombies (Mejor: " + nf(evolution.zombieEvolutionTree.getBestNode().score, 0, 1) + ")", legendX + 15, legendY);
    legendY += 30;
  }
  
  if (humanScores != null) {
    fill(255, 100, 100);
    ellipse(legendX, legendY, 15, 15);
    fill(200, 220, 255);
    textAlign(LEFT, CENTER);
    textSize(14);
    text("Humanos (Mejor: " + nf(evolution.humanEvolutionTree.getBestNode().score, 0, 1) + ")", legendX + 15, legendY);
  }
  
  // Instrucciones
  fill(180, 180, 220);
  textAlign(CENTER);
  textSize(12);
  text("Usa ↑↓ para cambiar el promedio móvil (actual: " + movingAverageWindow + ")", width/2, height - 20);
}

ArrayList<Float> applyMovingAverage(ArrayList<Float> data, int windowSize) {
  if (data == null || data.size() == 0 || windowSize <= 1) {
    return data;
  }
  
  ArrayList<Float> smoothed = new ArrayList<Float>();
  
  for (int i = 0; i < data.size(); i++) {
    float sum = 0;
    int count = 0;
    
    int halfWindow = windowSize / 2;
    int start = max(0, i - halfWindow);
    int end = min(data.size() - 1, i + halfWindow);
    
    for (int j = start; j <= end; j++) {
      sum += data.get(j);
      count++;
    }
    
    smoothed.add(sum / count);
  }
  
  return smoothed;
}

// Función helper para dibujar un valor de genotipo con su delta
void drawGenotypeValue(String label, float value, float parentValue, boolean hasParent, float x, float y) {
  fill(180, 180, 220);
  textAlign(LEFT);
  textSize(9);
  text(label + ": " + nf(value, 0, 2), x, y);
  
  if (hasParent) {
    float delta = value - parentValue;
    if (abs(delta) > 0.01) { // Solo mostrar si hay cambio significativo
      float deltaX = x + 85;
      
      // Color según si subió o bajó
      if (delta > 0) {
        fill(100, 255, 100); // Verde para aumento
        text("+" + nf(delta, 0, 2), deltaX, y);
      } else {
        fill(255, 100, 100); // Rojo para disminución
        text(nf(delta, 0, 2), deltaX, y);
      }
    }
  }
}
