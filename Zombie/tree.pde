class TreeNode {
  int generation;
  float score;
  Genotype genotype;
  TreeNode parent;
  ArrayList<TreeNode> children;
  
  TreeNode(int generation, float score, Genotype genotype) {
    this.generation = generation;
    this.score = score;
    this.genotype = genotype.copy();
    this.parent = null;
    this.children = new ArrayList<TreeNode>();
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
  
  TreeNode addNode(TreeNode parent, int generation, float score, Genotype genotype) {
    TreeNode newNode = new TreeNode(generation, score, genotype);
    parent.addChild(newNode);
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
    HashMap<TreeNode, PVector> positions = calculatePositions(x, y, nodeSize);
    
    stroke(100, 100, 100, 150);
    strokeWeight(1);
    for (TreeNode node : this.allNodes) {
      PVector nodePos = positions.get(node);
      for (TreeNode child : node.children) {
        PVector childPos = positions.get(child);
        line(nodePos.x, nodePos.y, childPos.x, childPos.y);
      }
    }
    
    for (TreeNode node : this.allNodes) {
      PVector pos = positions.get(node);
      drawNode(node, pos.x, pos.y, nodeSize);
    }
  }
  
private HashMap<TreeNode, PVector> calculatePositions(float startX, float startY, float nodeSize) {
    HashMap<TreeNode, PVector> positions = new HashMap<TreeNode, PVector>();
    int maxDepth = getMaxDepth();
    
    if (maxDepth == 0) {
        positions.put(this.root, new PVector(startX, startY));
        return positions;
    }
    
    float verticalSpacing = max((height - startY - 100) / (maxDepth + 1), nodeSize);
    
    for (int gen = 0; gen <= maxDepth; gen++) {
        ArrayList<TreeNode> nodesAtGen = getNodesAtGeneration(gen);
        float y = startY + gen * verticalSpacing;
        
        if (nodesAtGen.size() > 0) {
            float horizontalSpacing = max((width - 200) / (nodesAtGen.size() + 1), nodeSize);
            for (int i = 0; i < nodesAtGen.size(); i++) {
                float x = 100 + (i + 1) * horizontalSpacing;
                positions.put(nodesAtGen.get(i), new PVector(x, y));
            }
        }
    }
    
    return positions;
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
}