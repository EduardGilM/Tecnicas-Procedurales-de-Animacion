class TreeNode {
  int generation;
  float score;
  Genotype genotype;
  TreeNode parent;
  TreeNode secondParent;
  ArrayList<TreeNode> children;
  String mutationType; // "root", "mutation", "crossover"
  
  TreeNode(int generation, float score, Genotype genotype) {
    this.generation = generation;
    this.score = score;
    this.genotype = genotype.copy();
    this.parent = null;
    this.secondParent = null;
    this.children = new ArrayList<TreeNode>();
    this.mutationType = "root";
  }
  
  TreeNode(int generation, float score, Genotype genotype, String mutationType) {
    this.generation = generation;
    this.score = score;
    this.genotype = genotype.copy();
    this.parent = null;
    this.secondParent = null;
    this.children = new ArrayList<TreeNode>();
    this.mutationType = mutationType;
  }
  
  void addChild(TreeNode child) {
    child.parent = this;
    this.children.add(child);
  }
}

class Tree {
  TreeNode root;
  ArrayList<TreeNode> allNodes;
  
  Tree(float initialScore, Genotype initialGenotype) {
    this.root = new TreeNode(0, initialScore, initialGenotype);
    this.allNodes = new ArrayList<TreeNode>();
    this.allNodes.add(this.root);
  }
  
  TreeNode addNode(TreeNode parent, int generation, float score, Genotype genotype, String mutationType) {
    TreeNode newNode = new TreeNode(generation, score, genotype, mutationType);
    parent.addChild(newNode);
    this.allNodes.add(newNode);
    return newNode;
  }
  
  TreeNode addNode(TreeNode parent, TreeNode secondParent, int generation, float score, Genotype genotype, String mutationType) {
    TreeNode newNode = new TreeNode(generation, score, genotype, mutationType);
    parent.addChild(newNode);
    newNode.secondParent = secondParent;
    this.allNodes.add(newNode);
    return newNode;
  }
  
  TreeNode getBestNode() {
    TreeNode best = this.root;
    for (TreeNode node : this.allNodes) {
      if (node.score > best.score) {
        best = node;
      }
    }
    return best;
  }
  
  int getMaxDepth() {
    return getDepth(this.root);
  }
  
  private int getDepth(TreeNode node) {
    if (node.children.isEmpty()) {
      return 0;
    }
    int maxChildDepth = 0;
    for (TreeNode child : node.children) {
      maxChildDepth = max(maxChildDepth, getDepth(child));
    }
    return 1 + maxChildDepth;
  }
  
  ArrayList<TreeNode> getNodesAtGeneration(int generation) {
    ArrayList<TreeNode> nodes = new ArrayList<TreeNode>();
    for (TreeNode node : this.allNodes) {
      if (node.generation == generation) {
        nodes.add(node);
      }
    }
    return nodes;
  }
  
  void display(float x, float y, float nodeSize) {
    display(x, y, nodeSize, width);
  }
  
  void display(float x, float y, float nodeSize, float availableWidth) {
    HashMap<TreeNode, PVector> positions = calculatePositions(x, y, nodeSize, availableWidth);
    
    stroke(100, 100, 100, 150);
    strokeWeight(1);
    for (TreeNode node : this.allNodes) {
      PVector nodePos = positions.get(node);
      if (nodePos != null) {
        for (TreeNode child : node.children) {
          PVector childPos = positions.get(child);
          if (childPos != null) {
            line(nodePos.x, nodePos.y, childPos.x, childPos.y);
          }
        }
      }
    }
    
    stroke(150, 100, 200, 150);
    strokeWeight(1);
    for (TreeNode node : this.allNodes) {
      if (node.secondParent != null) {
        PVector nodePos = positions.get(node);
        PVector secondParentPos = positions.get(node.secondParent);
        if (nodePos != null && secondParentPos != null) {
          line(secondParentPos.x, secondParentPos.y, nodePos.x, nodePos.y);
        }
      }
    }
    
    for (TreeNode node : this.allNodes) {
      PVector pos = positions.get(node);
      if (pos != null) {
        drawNode(node, pos.x, pos.y, nodeSize);
      }
    }
  }
  
private HashMap<TreeNode, PVector> calculatePositions(float startX, float startY, float nodeSize, float availableWidth) {
    HashMap<TreeNode, PVector> positions = new HashMap<TreeNode, PVector>();
    
    positions.put(this.root, new PVector(startX, startY));
    
    HashMap<Integer, Integer> depthCounter = new HashMap<Integer, Integer>();
    assignDepthsAndPositions(this.root, 0, positions, startX, startY, nodeSize, availableWidth, depthCounter);
    
    return positions;
}

private void assignDepthsAndPositions(TreeNode node, int depth, HashMap<TreeNode, PVector> positions, 
                                       float startX, float startY, float nodeSize, float availableWidth,
                                       HashMap<Integer, Integer> depthCounter) {
    if (node == null) return;
    
    int maxDepth = getMaxDepth();
    float verticalSpacing = max((height - startY - 100) / (maxDepth + 1), nodeSize * 2);
    
    if (node.children.isEmpty()) return;
    
    float y = startY + (depth + 1) * verticalSpacing;
    PVector parentPos = positions.get(node);
    
    if (parentPos != null) {
        int siblingCount = node.children.size();
        
        for (int i = 0; i < siblingCount; i++) {
            TreeNode child = node.children.get(i);
            
            if (siblingCount > 1) {
                float spreadWidth = min(200, availableWidth * 0.3);
                float offsetPerChild = spreadWidth / (siblingCount - 1);
                float offset = (i - (siblingCount - 1) / 2.0) * offsetPerChild;
                positions.put(child, new PVector(parentPos.x + offset, y));
            } else {
                positions.put(child, new PVector(parentPos.x, y));
            }
            
            assignDepthsAndPositions(child, depth + 1, positions, startX, startY, nodeSize, availableWidth, depthCounter);
        }
    }
}
  
  private void drawNode(TreeNode node, float x, float y, float size) {
    float maxScore = getBestNode().score;
    float minScore = getMinScore();
    float normalizedScore = 0.5;
    if (maxScore != minScore) {
      normalizedScore = map(node.score, minScore, maxScore, 0, 1);
    }
    
    color nodeColor = lerpColor(color(255, 100, 100), color(100, 255, 100), normalizedScore);
    
    fill(nodeColor);
    stroke(0);
    strokeWeight(2);
    ellipse(x, y, size, size);
    
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(10);
    text(nf(node.score, 0, 1), x, y);
    
    textSize(8);
    text("G" + node.generation, x, y + size/2 + 10);
    
    if (!node.mutationType.equals("root")) {
      fill(100, 100, 255);
      textSize(7);
      String mutText = node.mutationType.equals("mutation") ? "MUT" : "CRO";
      text(mutText, x, y + size/2 + 20);
    }
  }

  private float getMinScore() {
    float minScore = this.root.score;
    for (TreeNode node : this.allNodes) {
      if (node.score < minScore) {
        minScore = node.score;
      }
    }
    return minScore;
  }
  
  void displayInfo(float x, float y) {
    fill(255);
    rect(x, y, 250, 150);
    
    fill(0);
    textAlign(LEFT, TOP);
    textSize(12);
    text("Información del Árbol Evolutivo", x + 10, y + 10);
    textSize(10);
    text("Total de nodos: " + this.allNodes.size(), x + 10, y + 35);
    text("Generaciones: " + (getMaxDepth() + 1), x + 10, y + 50);
    
    TreeNode best = getBestNode();
    text("Mejor Score: " + nf(best.score, 0, 2), x + 10, y + 65);
    text("Generación: " + best.generation, x + 10, y + 80);
    
    text("Score Promedio: " + nf(getAverageScore(), 0, 2), x + 10, y + 95);
    text("Score Mínimo: " + nf(getMinScore(), 0, 2), x + 10, y + 110);
  }
  
  private float getAverageScore() {
    float sum = 0;
    for (TreeNode node : this.allNodes) {
      sum += node.score;
    }
    return sum / this.allNodes.size();
  }
  
  ArrayList<TreeNode> getBestPath() {
    ArrayList<TreeNode> path = new ArrayList<TreeNode>();
    TreeNode current = getBestNode();
    
    while (current != null) {
      path.add(0, current);
      current = current.parent;
    }
    
    return path;
  }

  ArrayList<Float> getBestScoresByGeneration() {
    ArrayList<Float> bestScores = new ArrayList<Float>();
    
    int maxGeneration = 0;
    for (TreeNode node : this.allNodes) {
      if (node.generation > maxGeneration) {
        maxGeneration = node.generation;
      }
    }
    
    for (int gen = 0; gen <= maxGeneration; gen++) {
      ArrayList<TreeNode> nodesAtGen = getNodesAtGeneration(gen);
      if (nodesAtGen.size() > 0) {
        float bestScore = nodesAtGen.get(0).score;
        for (TreeNode node : nodesAtGen) {
          if (node.score > bestScore) {
            bestScore = node.score;
          }
        }
        bestScores.add(bestScore);
      } else {
        bestScores.add(0.0);
      }
    }
    
    return bestScores;
  }
}