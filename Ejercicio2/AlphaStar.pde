Grid grid;
AStar astar;
AStarVisualizer pathfinder;
ArrayList<Node> path;
ArrayList<Boid> boids;
ArrayList<Node> exploredNodes;
ArrayList<Node> openNodes;
int gridSize = 20;
int cellSize;
int mode = 0;
boolean showBoids = false;
boolean showPathfindingVisualization = true;
boolean calculatingPath = false;
int stepsPerFrame = 5;

Node startNode;
Node goalNode;
ArrayList<BenchmarkResult> benchmarkResults;
boolean benchmarkRunning = false;
int currentBenchmarkSize = 20;
int maxBenchmarkSize = 150;
int benchmarkStep = 10;
int benchmarkIterations = 100;
int currentIteration = 0;
ArrayList<Float> currentSizeTimes;
ArrayList<Integer> currentSizeExploredNodes;
float benchmarkObstaclePercentage = 0.2; // Porcentaje de obstáculos para el benchmark

void setup() {
  size(800, 800);
  cellSize = width / gridSize;
  
  grid = new Grid(gridSize, 0.03);
  astar = new AStar(grid);
  boids = new ArrayList<Boid>();
  exploredNodes = new ArrayList<Node>();
  openNodes = new ArrayList<Node>();
  benchmarkResults = new ArrayList<BenchmarkResult>();
  currentSizeTimes = new ArrayList<Float>();
  currentSizeExploredNodes = new ArrayList<Integer>();
  
  startNode = grid.getNode(0, 0);
  goalNode = grid.getNode(gridSize - 1, gridSize - 1);
  
  calculatePath();
  
  if (path != null && path.size() > 0) {
    boids.add(new Boid(path.get(0).x * cellSize + cellSize/2, 
                       path.get(0).y * cellSize + cellSize/2, path, boids));
  }
}

void draw() {
  background(255);
  
  if (mode == 0) {
    // Mostrar progreso del cálculo si está en marcha
    if (calculatingPath && pathfinder != null) {
      // Ejecutar múltiples pasos de la búsqueda
      for (int i = 0; i < stepsPerFrame && calculatingPath; i++) {
        calculatingPath = pathfinder.step();
      }
      
      // Si terminó, guardar el resultado
      if (!calculatingPath) {
        path = pathfinder.getPath();
        exploredNodes = pathfinder.getExploredNodes();
        openNodes = pathfinder.getOpenNodes();
        
        // Actualizar boids con el nuevo camino
        for (Boid b : boids) {
          b.setPath(path);
        }
      }
      
      // Actualizar nodos explorados y abiertos en tiempo real
      exploredNodes = pathfinder.getExploredNodes();
      openNodes = pathfinder.getOpenNodes();
    }
    
    drawGrid();
    drawPath();
    
    if (showBoids) {
      for (Boid b : boids) {
        b.update();
        b.display();
      }
    }
    
    fill(0);
    textAlign(LEFT);
    textSize(11);
    text("Click: nuevo destino | 'O': añadir obstáculo | 'C': limpiar obstáculos", 10, height - 100);
    text("'↑/↓': cambiar tamaño grid (±10) | '-': crear bandada | 'R': reiniciar", 10, height - 80);
    text("'+': iniciar benchmark | 'V': mostrar/ocultar visualización A*", 10, height - 60);
    text("'1-9': cambiar % obstáculos benchmark (1-90%) | Obstáculos benchmark: " + nf(benchmarkObstaclePercentage * 100, 0, 1) + "%", 10, height - 40);
    text("Grid: " + gridSize + "x" + gridSize + " | Obstáculos: " + grid.getObstacleCount() + 
         " | Flocks: " + boids.size() + (showBoids ? " activos" : " inactivos"), 10, height - 20);
    if (showPathfindingVisualization) {
      text("Explorados: " + exploredNodes.size() + " | Abiertos: " + openNodes.size(), 10, height - 40);
    }
    if (calculatingPath) {
      fill(255, 0, 0);
      textSize(14);
      textAlign(CENTER);
      text("CALCULANDO CAMINO...", width/2, 30);
    }
    
  } else if (mode == 1) {
    if (benchmarkRunning) {
      runBenchmark();
    } else {
      displayBenchmarkResults();
    }
  }
}

void calculatePath() {
  if (startNode == null) {
    startNode = grid.getNode(0, 0);
  }
  if (goalNode == null) {
    goalNode = grid.getNode(gridSize - 1, gridSize - 1);
  }
  
  exploredNodes.clear();
  openNodes.clear();
  
  if (startNode != null && goalNode != null && !startNode.isObstacle && !goalNode.isObstacle) {
    path = astar.findPathWithVisualization(startNode, goalNode, exploredNodes, openNodes);
  } else {
    path = null;
  }
}

void drawGrid() {
  strokeWeight(1);
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      Node n = grid.getNode(i, j);
      if (n.isObstacle) {
        fill(50);
      } else {
        fill(240);
      }
      
      stroke(200);
      rect(i * cellSize, j * cellSize, cellSize, cellSize);
    }
  }
  
  fill(0, 255, 0, 100);
  if (startNode != null) {
    rect(startNode.x * cellSize, startNode.y * cellSize, cellSize, cellSize);
  }
  fill(255, 0, 0, 100);
  if (goalNode != null) {
    rect(goalNode.x * cellSize, goalNode.y * cellSize, cellSize, cellSize);
  }
}

void drawPath() {
  // Dibujar nodos explorados (cerrados)
  if (exploredNodes != null && exploredNodes.size() > 0) {
    fill(200, 200, 100, 120);
    noStroke();
    for (Node n : exploredNodes) {
      rect(n.x * cellSize, n.y * cellSize, cellSize, cellSize);
    }
  }
  
  // Dibujar nodos abiertos
  if (openNodes != null && openNodes.size() > 0) {
    fill(100, 200, 255, 150);
    noStroke();
    for (Node n : openNodes) {
      rect(n.x * cellSize, n.y * cellSize, cellSize, cellSize);
    }
  }
  
  // Dibujar camino final
  if (path != null && path.size() > 0) {
    fill(100, 150, 255, 100);
    noStroke();
    for (Node n : path) {
      rect(n.x * cellSize, n.y * cellSize, cellSize, cellSize);
    }
    
    stroke(0, 0, 255);
    strokeWeight(3);
    noFill();
    beginShape();
    for (Node n : path) {
      vertex(n.x * cellSize + cellSize/2, n.y * cellSize + cellSize/2);
    }
    endShape();
  }
}

void mousePressed() {
  if (mode == 0) {
    int gx = mouseX / cellSize;
    int gy = mouseY / cellSize;
    
    if (gx >= 0 && gx < gridSize && gy >= 0 && gy < gridSize) {
      goalNode = grid.getNode(gx, gy);
      
      if (goalNode != null && !goalNode.isObstacle) {
        // Iniciar cálculo del camino con visualización
        pathfinder = new AStarVisualizer(grid, startNode, goalNode);
        calculatingPath = true;
        exploredNodes.clear();
        openNodes.clear();
      }
    }
  }
}

void keyPressed() {
  if (mode == 0) {
    if (key == 'o' || key == 'O') {
      grid.addRandomObstacle();
      calculatePath();
      for (Boid b : boids) {
        b.setPath(path);
      }
    } else if (key == 'c' || key == 'C') {
      grid.clearObstacles();
      calculatePath();
      for (Boid b : boids) {
        b.setPath(path);
      }
    } else if (key == 'r' || key == 'R') {
      setup();
    } else if (key == 'v' || key == 'V') {
      showPathfindingVisualization = !showPathfindingVisualization;
      println("Visualización A*: " + (showPathfindingVisualization ? "ACTIVADA" : "DESACTIVADA"));
    } else if (key == '-') {
      if (path != null && path.size() > 0) {
        boids.clear();
        for (int i = 0; i < 10; i++) {
          float offsetX = random(-cellSize, cellSize);
          float offsetY = random(-cellSize, cellSize);
          boids.add(new Boid(path.get(0).x * cellSize + cellSize/2 + offsetX, 
                             path.get(0).y * cellSize + cellSize/2 + offsetY, path, boids));
        }
        showBoids = true;
        println("Bandada de " + boids.size() + " flocks creada!");
      }
    } else if (keyCode == UP) {
      gridSize = min(150, gridSize + 10);
      cellSize = width / gridSize;
      grid = new Grid(gridSize, 0.03);
      astar = new AStar(grid);
      startNode = grid.getNode(0, 0);
      goalNode = grid.getNode(gridSize - 1, gridSize - 1);
      calculatePath();
      boids.clear();
      showBoids = false;
      println("Tamaño del grid: " + gridSize + "x" + gridSize);
    } else if (keyCode == DOWN) {
      gridSize = max(10, gridSize - 10);
      cellSize = width / gridSize;
      grid = new Grid(gridSize, 0.03);
      astar = new AStar(grid);
      startNode = grid.getNode(0, 0);
      goalNode = grid.getNode(gridSize - 1, gridSize - 1);
      calculatePath();
      boids.clear();
      showBoids = false;
      println("Tamaño del grid: " + gridSize + "x" + gridSize);
    }
  }
  
  if (key == '+') {
    mode = 1;
    benchmarkRunning = true;
    benchmarkResults.clear();
    currentSizeTimes.clear();
    currentSizeExploredNodes.clear();
    currentBenchmarkSize = 20;
    currentIteration = 0;
    println("\n========================================");
    println("INICIANDO BENCHMARK COMPLETO");
    println("Rango: 20x20 hasta 150x150 (paso 10)");
    println("Iteraciones por tamaño: 100");
    println("% Obstáculos: " + nf(benchmarkObstaclePercentage * 100, 0, 1) + "%");
    println("========================================\n");
  } else if (key == 'n' || key == 'N') {
    mode = 0;
    benchmarkRunning = false;
  } else if (key >= '1' && key <= '9') {
    // Cambiar porcentaje de obstáculos (1-9 corresponde a 10%-90%)
    int percentage = int(key) * 10;
    benchmarkObstaclePercentage = percentage / 100.0;
    println("Porcentaje de obstáculos para benchmark: " + nf(benchmarkObstaclePercentage * 100, 0, 1) + "%");
  }
}

// ====================================
// BENCHMARK (TAREA A)
// ====================================

void runBenchmark() {
  background(255);
  fill(0);
  textAlign(CENTER);
  textSize(20);
  text("Ejecutando Benchmark...", width/2, height/2 - 60);
  text("Tamaño actual: " + currentBenchmarkSize + "x" + currentBenchmarkSize, width/2, height/2 - 20);
  text("Iteración: " + (currentIteration + 1) + "/" + benchmarkIterations, width/2, height/2 + 20);
  
  int totalSizes = ((maxBenchmarkSize - 20) / benchmarkStep) + 1;
  int currentSizeIndex = ((currentBenchmarkSize - 20) / benchmarkStep) + 1;
  text("Tamaño: " + currentSizeIndex + "/" + totalSizes, width/2, height/2 + 60);
  
  Grid testGrid = new Grid(currentBenchmarkSize, benchmarkObstaclePercentage);
  AStar testAStar = new AStar(testGrid);
  
  testGrid.getNode(0, 0).isObstacle = false;
  testGrid.getNode(currentBenchmarkSize-1, currentBenchmarkSize-1).isObstacle = false;
  
  Node start = testGrid.getNode(0, 0);
  Node goal = testGrid.getNode(currentBenchmarkSize - 1, currentBenchmarkSize - 1);
  
  long startTime = System.nanoTime();
  ArrayList<Node> testPath = testAStar.findPath(start, goal);
  long endTime = System.nanoTime();
  
  if (testPath == null || testPath.size() == 0) {
    println("  [Advertencia] No se encontró path en iteración " + (currentIteration + 1));
  }
  
  float timeMs = (endTime - startTime) / 1000000.0;
  currentSizeTimes.add(timeMs);
  
  // Contar nodos explorados (nodos en lista cerrada)
  int exploredCount = 0;
  for (int i = 0; i < testGrid.size; i++) {
    for (int j = 0; j < testGrid.size; j++) {
      Node n = testGrid.getNode(i, j);
      if (n.g != 0 || n.h != 0 || n.f != 0) {
        exploredCount++;
      }
    }
  }
  currentSizeExploredNodes.add(exploredCount);
  
  currentIteration++;
  
  if (currentIteration >= benchmarkIterations) {
    float sum = 0;
    for (float t : currentSizeTimes) {
      sum += t;
    }
    float avg = sum / currentSizeTimes.size();
    
    float sumSq = 0;
    for (float t : currentSizeTimes) {
      sumSq += pow(t - avg, 2);
    }
    float stdDev = sqrt(sumSq / currentSizeTimes.size());
    
    // Calcular promedio y desviación de nodos explorados
    int sumExplored = 0;
    for (int e : currentSizeExploredNodes) {
      sumExplored += e;
    }
    int avgExplored = sumExplored / currentSizeExploredNodes.size();
    
    int sumSqExplored = 0;
    for (int e : currentSizeExploredNodes) {
      sumSqExplored += (e - avgExplored) * (e - avgExplored);
    }
    int stdDevExplored = (int)sqrt(sumSqExplored / (float)currentSizeExploredNodes.size());
    
    BenchmarkResult result = new BenchmarkResult(currentBenchmarkSize, avg, stdDev, avgExplored, stdDevExplored);
    benchmarkResults.add(result);
    
    println("Completado " + currentBenchmarkSize + "x" + currentBenchmarkSize + ": " + 
            "Media = " + nf(avg, 0, 3) + " ms, StdDev = " + nf(stdDev, 0, 3) + " ms, " +
            "Nodos explorados = " + avgExplored + " ± " + stdDevExplored);
    
    currentSizeTimes.clear();
    currentSizeExploredNodes.clear();
    currentIteration = 0;
    currentBenchmarkSize += benchmarkStep;
    
    if (currentBenchmarkSize > maxBenchmarkSize) {
      benchmarkRunning = false;
      saveBenchmarkData();
      println("\n========================================");
      println("BENCHMARK COMPLETADO!");
      println("Total de tamaños evaluados: " + benchmarkResults.size());
      println("========================================\n");
    }
  }
}

BenchmarkResult benchmarkGridSize(int size, int iterations) {
  ArrayList<Float> times = new ArrayList<Float>();
  ArrayList<Integer> exploredNodesList = new ArrayList<Integer>();
  
  for (int i = 0; i < iterations; i++) {
    Grid testGrid = new Grid(size, benchmarkObstaclePercentage);
    AStar testAStar = new AStar(testGrid);
    
    testGrid.getNode(0, 0).isObstacle = false;
    testGrid.getNode(size-1, size-1).isObstacle = false;
    
    Node start = testGrid.getNode(0, 0);
    Node goal = testGrid.getNode(size - 1, size - 1);
    
    long startTime = System.nanoTime();
    ArrayList<Node> testPath = testAStar.findPath(start, goal);
    long endTime = System.nanoTime();
    
    if (testPath != null && testPath.size() > 0) {
    }
    
    float timeMs = (endTime - startTime) / 1000000.0;
    times.add(timeMs);
    
    // Contar nodos explorados
    int exploredCount = 0;
    for (int x = 0; x < testGrid.size; x++) {
      for (int y = 0; y < testGrid.size; y++) {
        Node n = testGrid.getNode(x, y);
        if (n.g != 0 || n.h != 0 || n.f != 0) {
          exploredCount++;
        }
      }
    }
    exploredNodesList.add(exploredCount);
  }
  
  float sum = 0;
  for (float t : times) {
    sum += t;
  }
  float avg = sum / times.size();
  
  float sumSq = 0;
  for (float t : times) {
    sumSq += pow(t - avg, 2);
  }
  float stdDev = sqrt(sumSq / times.size());
  
  // Calcular promedio y desviación de nodos explorados
  int sumExplored = 0;
  for (int e : exploredNodesList) {
    sumExplored += e;
  }
  int avgExplored = sumExplored / exploredNodesList.size();
  
  int sumSqExplored = 0;
  for (int e : exploredNodesList) {
    sumSqExplored += (e - avgExplored) * (e - avgExplored);
  }
  int stdDevExplored = (int)sqrt(sumSqExplored / (float)exploredNodesList.size());
  
  return new BenchmarkResult(size, avg, stdDev, avgExplored, stdDevExplored);
}

void displayBenchmarkResults() {
  background(255);
  
  if (benchmarkResults.size() == 0) {
    fill(0);
    textAlign(CENTER);
    textSize(16);
    text("No hay resultados de benchmark", width/2, height/2 - 20);
    text("Presiona '+' para ejecutar benchmark completo", width/2, height/2 + 20);
    text("(20x20 a 150x150, 100 iteraciones cada uno)", width/2, height/2 + 50);
    textSize(12);
    text("Presiona 'N' para volver al modo navegación", width/2, height/2 + 100);
    return;
  }
  
  float marginX = 80;
  float marginY = 80;
  
  float maxSize = 0;
  float maxTime = 0;
  for (BenchmarkResult r : benchmarkResults) {
    maxSize = max(maxSize, r.gridSize);
    maxTime = max(maxTime, r.avgTime + r.stdDev);
  }
  
  stroke(0);
  strokeWeight(2);
  line(marginX, height - marginY, width - marginX, height - marginY);
  line(marginX, marginY, marginX, height - marginY);
  
  fill(0);
  textAlign(CENTER);
  textSize(14);
  text("Tamaño del Grid (n x n)", width/2, height - 20);
  
  pushMatrix();
  translate(20, height/2);
  rotate(-HALF_PI);
  text("Tiempo promedio (ms)", 0, 0);
  popMatrix();
  
  textSize(18);
  text("Rendimiento de A* - 100 iteraciones por tamaño", width/2, 30);
  textSize(12);
  text("Rango: 20x20 a 150x150 (" + nf(benchmarkObstaclePercentage * 100, 0, 1) + "% obstáculos)", width/2, 50);
  
  stroke(0, 100, 255);
  strokeWeight(2);
  fill(0, 100, 255);
  
  for (int i = 0; i < benchmarkResults.size(); i++) {
    BenchmarkResult r = benchmarkResults.get(i);
    
    float x = map(r.gridSize, 20, maxSize, marginX, width - marginX);
    float y = map(r.avgTime, 0, maxTime * 1.1, height - marginY, marginY);
    
    float yTop = map(r.avgTime - r.stdDev, 0, maxTime * 1.1, height - marginY, marginY);
    float yBottom = map(r.avgTime + r.stdDev, 0, maxTime * 1.1, height - marginY, marginY);
    
    stroke(150);
    strokeWeight(1);
    line(x, yTop, x, yBottom);
    line(x - 3, yTop, x + 3, yTop);
    line(x - 3, yBottom, x + 3, yBottom);
    
    fill(0, 100, 255);
    noStroke();
    ellipse(x, y, 8, 8);
    
    if (i < benchmarkResults.size() - 1) {
      BenchmarkResult next = benchmarkResults.get(i + 1);
      float nextX = map(next.gridSize, 20, maxSize, marginX, width - marginX);
      float nextY = map(next.avgTime, 0, maxTime * 1.1, height - marginY, marginY);
      
      stroke(0, 100, 255);
      strokeWeight(2);
      line(x, y, nextX, nextY);
    }
  }
  
  fill(0);
  textSize(10);
  textAlign(RIGHT);
  for (int i = 0; i <= 5; i++) {
    float val = (maxTime * 1.1) * i / 5.0;
    float y = map(val, 0, maxTime * 1.1, height - marginY, marginY);
    text(nf(val, 0, 1), marginX - 10, y + 5);
    
    stroke(220);
    strokeWeight(1);
    line(marginX, y, width - marginX, y);
  }
  
  textAlign(CENTER);
  int step = benchmarkResults.size() > 8 ? 2 : 1;
  for (int i = 0; i < benchmarkResults.size(); i += step) {
    BenchmarkResult r = benchmarkResults.get(i);
    float x = map(r.gridSize, 20, maxSize, marginX, width - marginX);
    fill(0);
    text(r.gridSize, x, height - marginY + 20);
    
    stroke(220);
    strokeWeight(1);
    line(x, marginY, x, height - marginY);
  }
  
  fill(0);
  textAlign(LEFT);
  textSize(12);
  text("Presiona 'N' para volver al modo navegación", 10, height - 20);
  
  textAlign(RIGHT);
  text("Total de puntos: " + benchmarkResults.size(), width - 10, height - 20);
}

void saveBenchmarkData() {
  PrintWriter output = createWriter("benchmark_data.txt");
  output.println("# GridSize AvgTime(ms) StdDev(ms) AvgExploredNodes StdDevExplored");
  output.println("# Benchmark de A*: 20x20 a 150x150, 100 iteraciones por tamaño");
  output.println("# " + nf(benchmarkObstaclePercentage * 100, 0, 1) + "% de obstáculos por grid");
  
  for (BenchmarkResult r : benchmarkResults) {
    output.println(r.gridSize + " " + r.avgTime + " " + r.stdDev + " " + r.avgExploredNodes + " " + r.stdDevExplored);
  }
  
  output.flush();
  output.close();
  
  println("Datos guardados en benchmark_data.txt");
  
  PrintWriter gnuplot = createWriter("plot_benchmark.gnuplot");
  gnuplot.println("# Script de gnuplot para visualizar resultados de A*");
  gnuplot.println("set terminal png size 1200,800 enhanced font 'Arial,12'");
  gnuplot.println("set output 'benchmark_plot.png'");
  gnuplot.println("");
  gnuplot.println("set title 'Rendimiento del Algoritmo A* (" + benchmarkIterations + " iteraciones por tamaño)' font 'Arial,16'");
  gnuplot.println("set xlabel 'Tamaño del Grid (n x n)' font 'Arial,14'");
  gnuplot.println("set ylabel 'Tiempo promedio (ms)' font 'Arial,14'");
  gnuplot.println("");
  gnuplot.println("set grid");
  gnuplot.println("set key top left");
  gnuplot.println("set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5");
  gnuplot.println("set style line 2 lc rgb '#0060ad' lt 1 lw 1");
  gnuplot.println("");
  gnuplot.println("# Configurar rangos");
  gnuplot.println("set xrange [15:155]");
  gnuplot.println("set yrange [0:*]");
  gnuplot.println("");
  gnuplot.println("# Plotear con barras de error y línea");
  gnuplot.println("plot 'benchmark_data.txt' using 1:2:3 with errorbars ls 1 title 'A* (media ± desv. típica)', \\");
  gnuplot.println("     'benchmark_data.txt' using 1:2 with lines ls 2 notitle");
  
  gnuplot.flush();
  gnuplot.close();
  
  println("Script de gnuplot guardado en plot_benchmark.gnuplot");
  println("\nPara generar las gráficas PNG, ejecuta en terminal:");
  println("  gnuplot plot_benchmark.gnuplot");
  println("\nSe generarán los archivos:");
  println("  - benchmark_plot_time.png (Tiempo de ejecución)");
  println("  - benchmark_plot_nodes.png (Nodos explorados)");
  println("  - benchmark_plot_comparison.png (Comparación con dos ejes)");
}

class BenchmarkResult {
  int gridSize;
  float avgTime;
  float stdDev;
  int avgExploredNodes;
  int stdDevExplored;
  
  BenchmarkResult(int size, float avg, float std, int exploredAvg, int exploredStd) {
    gridSize = size;
    avgTime = avg;
    stdDev = std;
    avgExploredNodes = exploredAvg;
    stdDevExplored = exploredStd;
  }
}

class Node {
  int x, y;
  boolean isObstacle;
  float g, h, f;
  Node parent;
  
  Node(int x, int y) {
    this.x = x;
    this.y = y;
    this.isObstacle = false;
    this.g = 0;
    this.h = 0;
    this.f = 0;
    this.parent = null;
  }
  
  void reset() {
    g = 0;
    h = 0;
    f = 0;
    parent = null;
  }
  
  boolean equals(Node other) {
    return this.x == other.x && this.y == other.y;
  }
}

class Grid {
  int size;
  Node[][] nodes;
  float obstaclePercentage;
  
  Grid(int size, float obstaclePercentage) {
    this.size = size;
    this.obstaclePercentage = obstaclePercentage;
    nodes = new Node[size][size];
    
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        nodes[i][j] = new Node(i, j);
      }
    }
    
    generateObstacles();
  }
  
  void generateObstacles() {
    int totalCells = size * size;
    int numObstacles = (int)(totalCells * obstaclePercentage);
    
    for (int i = 0; i < numObstacles; i++) {
      int x = (int)random(size);
      int y = (int)random(size);
      
      if ((x == 0 && y == 0) || (x == size-1 && y == size-1)) {
        i--;
        continue;
      }
      
      nodes[x][y].isObstacle = true;
    }
  }
  
  void addRandomObstacle() {
    int x = (int)random(size);
    int y = (int)random(size);
    
    if ((x == 0 && y == 0) || (x == size-1 && y == size-1)) {
      return;
    }
    
    nodes[x][y].isObstacle = true;
  }
  
  void clearObstacles() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        nodes[i][j].isObstacle = false;
      }
    }
  }
  
  Node getNode(int x, int y) {
    if (x >= 0 && x < size && y >= 0 && y < size) {
      return nodes[x][y];
    }
    return null;
  }
  
  ArrayList<Node> getNeighbors(Node node) {
    ArrayList<Node> neighbors = new ArrayList<Node>();
    
    int[][] dirs = {{0,1}, {1,0}, {0,-1}, {-1,0}, {1,1}, {1,-1}, {-1,1}, {-1,-1}};
    
    for (int[] dir : dirs) {
      int newX = node.x + dir[0];
      int newY = node.y + dir[1];
      
      Node neighbor = getNode(newX, newY);
      if (neighbor != null && !neighbor.isObstacle) {
        neighbors.add(neighbor);
      }
    }
    
    return neighbors;
  }
  
  int getObstacleCount() {
    int count = 0;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (nodes[i][j].isObstacle) count++;
      }
    }
    return count;
  }
  
  void resetNodes() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        nodes[i][j].reset();
      }
    }
  }
}

class AStar {
  Grid grid;
  
  AStar(Grid grid) {
    this.grid = grid;
  }
  
  ArrayList<Node> findPath(Node start, Node goal) {
    grid.resetNodes();
    
    ArrayList<Node> openList = new ArrayList<Node>();
    ArrayList<Node> closedList = new ArrayList<Node>();
    
    openList.add(start);
    start.g = 0;
    start.h = heuristic(start, goal);
    start.f = start.g + start.h;
    
    while (openList.size() > 0) {
      Node current = openList.get(0);
      int currentIndex = 0;
      
      for (int i = 1; i < openList.size(); i++) {
        if (openList.get(i).f < current.f) {
          current = openList.get(i);
          currentIndex = i;
        }
      }
      
      if (current.equals(goal)) {
        return reconstructPath(current);
      }
      
      openList.remove(currentIndex);
      closedList.add(current);
      
      ArrayList<Node> neighbors = grid.getNeighbors(current);
      
      for (Node neighbor : neighbors) {
        if (isInList(neighbor, closedList)) {
          continue;
        }
        
        float tentativeG = current.g + distance(current, neighbor);
        
        boolean inOpenList = isInList(neighbor, openList);
        
        if (!inOpenList || tentativeG < neighbor.g) {
          neighbor.parent = current;
          neighbor.g = tentativeG;
          neighbor.h = heuristic(neighbor, goal);
          neighbor.f = neighbor.g + neighbor.h;
          
          if (!inOpenList) {
            openList.add(neighbor);
          }
        }
      }
    }
    
    return null;
  }
  
  ArrayList<Node> findPathWithVisualization(Node start, Node goal, ArrayList<Node> explored, ArrayList<Node> open) {
    grid.resetNodes();
    
    ArrayList<Node> openList = new ArrayList<Node>();
    ArrayList<Node> closedList = new ArrayList<Node>();
    
    openList.add(start);
    start.g = 0;
    start.h = heuristic(start, goal);
    start.f = start.g + start.h;
    
    while (openList.size() > 0) {
      Node current = openList.get(0);
      int currentIndex = 0;
      
      for (int i = 1; i < openList.size(); i++) {
        if (openList.get(i).f < current.f) {
          current = openList.get(i);
          currentIndex = i;
        }
      }
      
      if (current.equals(goal)) {
        // Guardar estado final de exploración
        explored.clear();
        explored.addAll(closedList);
        open.clear();
        open.addAll(openList);
        return reconstructPath(current);
      }
      
      openList.remove(currentIndex);
      closedList.add(current);
      
      ArrayList<Node> neighbors = grid.getNeighbors(current);
      
      for (Node neighbor : neighbors) {
        if (isInList(neighbor, closedList)) {
          continue;
        }
        
        float tentativeG = current.g + distance(current, neighbor);
        
        boolean inOpenList = isInList(neighbor, openList);
        
        if (!inOpenList || tentativeG < neighbor.g) {
          neighbor.parent = current;
          neighbor.g = tentativeG;
          neighbor.h = heuristic(neighbor, goal);
          neighbor.f = neighbor.g + neighbor.h;
          
          if (!inOpenList) {
            openList.add(neighbor);
          }
        }
      }
    }
    
    // Guardar estado final incluso si no hay camino
    explored.clear();
    explored.addAll(closedList);
    open.clear();
    open.addAll(openList);
    
    return null;
  }
  
  float heuristic(Node a, Node b) {
    return abs(a.x - b.x) + abs(a.y - b.y);
  }
  
  float distance(Node a, Node b) {
    float dx = abs(a.x - b.x);
    float dy = abs(a.y - b.y);
    return sqrt(dx*dx + dy*dy);
  }
  
  boolean isInList(Node node, ArrayList<Node> list) {
    for (Node n : list) {
      if (n.equals(node)) {
        return true;
      }
    }
    return false;
  }
  
  ArrayList<Node> reconstructPath(Node current) {
    ArrayList<Node> path = new ArrayList<Node>();
    
    while (current != null) {
      path.add(0, current);
      current = current.parent;
    }
    
    return path;
  }
}

class Boid {
  PVector position;
  PVector velocity;
  PVector acceleration;
  ArrayList<Node> path;
  int currentWaypoint;
  ArrayList<Boid> flock; // Referencia a todos los boids de la bandada
  
  float maxSpeed = 3.0;
  float maxForce = 0.2;
  float perceptionRadius = 50;
  float separationRadius = 30;
  float waypointRadius;
  
  // Pesos de los comportamientos
  float separationWeight = 2;
  float alignmentWeight = 1.0;
  float cohesionWeight = 1.0;
  float pathWeight = 2.0;
  float avoidanceWeight = 2.0;
  
  Boid(float x, float y, ArrayList<Node> path, ArrayList<Boid> flock) {
    position = new PVector(x, y);
    velocity = new PVector(random(-1, 1), random(-1, 1));
    acceleration = new PVector(0, 0);
    this.path = path;
    this.flock = flock;
    currentWaypoint = 0;
    waypointRadius = max(cellSize * 0.5, 8);
  }
  
  void setPath(ArrayList<Node> newPath) {
    this.path = newPath;
    currentWaypoint = 0;
  }
  
  void update() {
    // Aplicar comportamientos de flocking
    PVector separation = separate();   // Separación de otros boids
    PVector alignment = align();       // Alineación con otros boids
    PVector cohesion = cohede();       // Cohesión con otros boids
    PVector pathFollowing = followPath(); // Seguimiento del camino
    PVector avoidance = avoidObstacles(); // Evasión de obstáculos
    
    // Aplicar pesos a cada comportamiento
    separation.mult(separationWeight);
    alignment.mult(alignmentWeight);
    cohesion.mult(cohesionWeight);
    pathFollowing.mult(pathWeight);
    avoidance.mult(avoidanceWeight);
    
    // Sumar todas las fuerzas
    applyForce(separation);
    applyForce(alignment);
    applyForce(cohesion);
    applyForce(pathFollowing);
    applyForce(avoidance);
    
    // Actualizar velocidad y posición
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    acceleration.mult(0);
    
    position.x = constrain(position.x, 0, width);
    position.y = constrain(position.y, 0, height);
  }
  
  // Separación: evitar que otros boids se acerquen demasiado
  PVector separate() {
    PVector steer = new PVector(0, 0);
    int count = 0;
    
    for (Boid other : flock) {
      float d = PVector.dist(position, other.position);
      
      if (d > 0 && d < separationRadius) {
        // Calcular vector de repulsión
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);
        steer.add(diff);
        count++;
      }
    }
    
    if (count > 0) {
      steer.div(count);
      steer.normalize();
      steer.mult(maxSpeed);
      steer.sub(velocity);
      steer.limit(maxForce);
    }
    
    return steer;
  }
  
  // Alineación: intentar orientarse en la misma dirección que los vecinos
  PVector align() {
    PVector avg = new PVector(0, 0);
    int count = 0;
    
    for (Boid other : flock) {
      float d = PVector.dist(position, other.position);
      
      if (d > 0 && d < perceptionRadius) {
        avg.add(other.velocity);
        count++;
      }
    }
    
    if (count > 0) {
      avg.div(count);
      avg.normalize();
      avg.mult(maxSpeed);
      PVector steer = PVector.sub(avg, velocity);
      steer.limit(maxForce);
      return steer;
    }
    
    return new PVector(0, 0);
  }
  
  // Cohesión: intentar ir hacia el centroide de los vecinos
  PVector cohede() {
    PVector avg = new PVector(0, 0);
    int count = 0;
    
    for (Boid other : flock) {
      float d = PVector.dist(position, other.position);
      
      if (d > 0 && d < perceptionRadius) {
        avg.add(other.position);
        count++;
      }
    }
    
    if (count > 0) {
      avg.div(count);
      PVector desired = PVector.sub(avg, position);
      
      if (desired.mag() > 0) {
        desired.normalize();
        desired.mult(maxSpeed);
        PVector steer = PVector.sub(desired, velocity);
        steer.limit(maxForce);
        return steer;
      }
    }
    
    return new PVector(0, 0);
  }
  
  // Seguimiento del camino
  PVector followPath() {
    PVector steer = new PVector(0, 0);
    
    if (path != null && path.size() > 0) {
      // Actualizar waypoint si es necesario
      if (currentWaypoint < path.size()) {
        Node target = path.get(currentWaypoint);
        PVector targetPos = new PVector(target.x * cellSize + cellSize/2, 
                                         target.y * cellSize + cellSize/2);
        
        float d = PVector.dist(position, targetPos);
        
        // Avanzar al siguiente waypoint si estamos cerca
        if (d < waypointRadius && currentWaypoint < path.size() - 1) {
          currentWaypoint++;
        }
      }
      
      // Calcular dirección hacia el waypoint actual
      if (currentWaypoint < path.size()) {
        Node target = path.get(currentWaypoint);
        PVector targetPos = new PVector(target.x * cellSize + cellSize/2, 
                                         target.y * cellSize + cellSize/2);
        
        PVector desired = PVector.sub(targetPos, position);
        float d = desired.mag();
        
        if (d > 0) {
          desired.normalize();
          
          // Reducir velocidad al acercarse al final del camino
          if (currentWaypoint >= path.size() - 2) {
            float m = map(d, 0, cellSize * 3, 0, maxSpeed);
            desired.mult(m);
          } else {
            desired.mult(maxSpeed);
          }
          
          steer = PVector.sub(desired, velocity);
          steer.limit(maxForce);
        }
      }
    }
    
    return steer;
  }
  
  // Evasión de obstáculos
  PVector avoidObstacles() {
    PVector steer = new PVector(0, 0);
    float detectionDistance = 40;
    
    // Revisar celdas del grid alrededor del boid
    int gridX = (int)(position.x / cellSize);
    int gridY = (int)(position.y / cellSize);
    
    // Verificar un área cuadrada alrededor del boid
    for (int i = gridX - 2; i <= gridX + 2; i++) {
      for (int j = gridY - 2; j <= gridY + 2; j++) {
        if (i >= 0 && i < gridSize && j >= 0 && j < gridSize) {
          Node n = grid.getNode(i, j);
          if (n.isObstacle) {
            // Centro de la celda obstáculo
            PVector obsPos = new PVector(i * cellSize + cellSize/2, 
                                          j * cellSize + cellSize/2);
            float d = PVector.dist(position, obsPos);
            
            if (d < detectionDistance) {
              // Vector de repulsión proporcional a la proximidad
              PVector repulsion = PVector.sub(position, obsPos);
              repulsion.normalize();
              repulsion.mult(1.0 / (d + 1));
              steer.add(repulsion);
            }
          }
        }
      }
    }
    
    if (steer.mag() > 0) {
      steer.normalize();
      steer.mult(maxSpeed);
      steer.sub(velocity);
      steer.limit(maxForce);
    }
    
    return steer;
  }
  
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  
  void display() {
    pushMatrix();
    translate(position.x, position.y);
    
    float angle = velocity.heading();
    rotate(angle);
    
    fill(255, 100, 0);
    stroke(0);
    strokeWeight(1);
    beginShape();
    vertex(12, 0);
    vertex(-6, 4);
    vertex(-4, 0);
    vertex(-6, -4);
    endShape(CLOSE);
    
    popMatrix();
  }
}

// ====================================
// ASTAR VISUALIZER - Búsqueda paso a paso
// ====================================

class AStarVisualizer {
  Grid grid;
  Node start;
  Node goal;
  ArrayList<Node> openList;
  ArrayList<Node> closedList;
  ArrayList<Node> path;
  boolean finished;
  
  AStarVisualizer(Grid grid, Node start, Node goal) {
    this.grid = grid;
    this.start = start;
    this.goal = goal;
    this.openList = new ArrayList<Node>();
    this.closedList = new ArrayList<Node>();
    this.path = null;
    this.finished = false;
    
    grid.resetNodes();
    
    openList.add(start);
    start.g = 0;
    start.h = heuristic(start, goal);
    start.f = start.g + start.h;
  }
  
  // Ejecuta un paso de la búsqueda A*
  boolean step() {
    if (finished || openList.size() == 0) {
      finished = true;
      return false;
    }
    
    // Encontrar el nodo con menor f en la lista abierta
    Node current = openList.get(0);
    int currentIndex = 0;
    
    for (int i = 1; i < openList.size(); i++) {
      if (openList.get(i).f < current.f) {
        current = openList.get(i);
        currentIndex = i;
      }
    }
    
    // Si llegamos al objetivo, reconstruir camino
    if (current.equals(goal)) {
      path = reconstructPath(current);
      finished = true;
      return false;
    }
    
    // Mover nodo de abierto a cerrado
    openList.remove(currentIndex);
    closedList.add(current);
    
    // Expandir vecinos
    ArrayList<Node> neighbors = grid.getNeighbors(current);
    
    for (Node neighbor : neighbors) {
      if (isInList(neighbor, closedList)) {
        continue;
      }
      
      float tentativeG = current.g + distance(current, neighbor);
      
      boolean inOpenList = isInList(neighbor, openList);
      
      if (!inOpenList || tentativeG < neighbor.g) {
        neighbor.parent = current;
        neighbor.g = tentativeG;
        neighbor.h = heuristic(neighbor, goal);
        neighbor.f = neighbor.g + neighbor.h;
        
        if (!inOpenList) {
          openList.add(neighbor);
        }
      }
    }
    
    return true; // Sigue buscando
  }
  
  ArrayList<Node> getExploredNodes() {
    return new ArrayList<Node>(closedList);
  }
  
  ArrayList<Node> getOpenNodes() {
    return new ArrayList<Node>(openList);
  }
  
  ArrayList<Node> getPath() {
    return path;
  }
  
  boolean isFinished() {
    return finished;
  }
  
  float heuristic(Node a, Node b) {
    return abs(a.x - b.x) + abs(a.y - b.y);
  }
  
  float distance(Node a, Node b) {
    float dx = abs(a.x - b.x);
    float dy = abs(a.y - b.y);
    return sqrt(dx*dx + dy*dy);
  }
  
  boolean isInList(Node node, ArrayList<Node> list) {
    for (Node n : list) {
      if (n.equals(node)) {
        return true;
      }
    }
    return false;
  }
  
  ArrayList<Node> reconstructPath(Node current) {
    ArrayList<Node> reconstructedPath = new ArrayList<Node>();
    
    while (current != null) {
      reconstructedPath.add(0, current);
      current = current.parent;
    }
    
    return reconstructedPath;
  }
}
