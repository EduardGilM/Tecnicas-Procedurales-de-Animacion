class Evolution {
  ArrayList<Agent> agents = new ArrayList<Agent>();
  Genotype zombieGenotype; 
  Genotype humanGenotype;
  int generation;
  float reward;
  float mutationRate;
  float crossoverRate;
  float bestScore;
  float evolutionType;
  float evolutionRate;
  Tree zombieEvolutionTree;
  Tree humanEvolutionTree;
  TreeNode currentZombieNode;
  TreeNode currentHumanNode;
  TreeNode secondZombieParent;
  TreeNode secondHumanParent;
  float timeRemaining; 
  float maxTime; 
  int startTime;
  boolean countAgents; 

  Evolution(ArrayList<Agent> agents, Genotype initialZombieGenotype, Genotype initialHumanGenotype, boolean countAgents) {
    this.agents = agents;
    this.generation = 0;
    this.reward = 0;
    this.mutationRate = 0.8;
    this.crossoverRate = 0.5;
    this.bestScore = 0;
    this.evolutionType = 0.5; // Menor a 0.5 favorece mutaciones, mayor a 0.5 cruces
    this.evolutionRate = 0.5;
    this.zombieGenotype = initialZombieGenotype;
    this.humanGenotype = initialHumanGenotype;
    this.maxTime = 20.0;
    this.timeRemaining = this.maxTime;
    this.startTime = millis();
    this.countAgents = countAgents;
    
    if (agents.size() > 0) {
      this.zombieEvolutionTree = new Tree(0, this.zombieGenotype);
      this.currentZombieNode = this.zombieEvolutionTree.root;
      this.humanEvolutionTree = new Tree(0, this.humanGenotype);
      this.currentHumanNode = this.humanEvolutionTree.root;
    }
  }
  
  void updateTimer() {
    int currentTime = millis();
    float elapsed = (currentTime - this.startTime) / 1000.0;
    this.timeRemaining = this.maxTime - elapsed;
    
    if (this.timeRemaining <= 0) {
      this.timeRemaining = 0;
    }
  }
  
  void resetTimer() {
    this.startTime = millis();
    this.timeRemaining = this.maxTime;
  }
  
  boolean isTimeUp() {
    if (this.timeRemaining <= 0) {
      return true;
    }
    
    if (this.agents == null || this.agents.size() == 0) {
      return true;
    }
    
    int humanCount = 0;
    for (Agent a : this.agents) {
      if (a != null && !a.isZombie) {
        humanCount++;
      }
    }
    
    if (humanCount == 0) {
      return true;
    }
    
    return false;
  }

  void nextGeneration() {
    updateTimer();
    
    float zombieScore = calculateZombieScore();
    float humanScore = calculateHumanScore();
    
    TreeNode bestZombieNode = null;
    TreeNode bestHumanNode = null;

    if (evolveZombie && this.zombieEvolutionTree != null && this.agents.size() > 0) {
      TreeNode parentNode = this.currentZombieNode != null ? this.currentZombieNode : this.zombieEvolutionTree.root;

      TreeNode newNode = this.zombieEvolutionTree.addNode(
        parentNode,
        this.generation + 1, 
        zombieScore, 
        this.zombieGenotype.copy(),
        "evaluation"
      );
      
      if (newNode != null) {
        this.currentZombieNode = newNode;
      }
    }
    
    if (evolveHuman && this.humanEvolutionTree != null && this.agents.size() > 0) {
      TreeNode parentNode = this.currentHumanNode != null ? this.currentHumanNode : this.humanEvolutionTree.root;
      
      TreeNode newNode = this.humanEvolutionTree.addNode(
        parentNode,
        this.generation + 1, 
        humanScore, 
        this.humanGenotype.copy(),
        "evaluation"
      );
      
      if (newNode != null) {
        this.currentHumanNode = newNode;
      }
    }

    if (evolveZombie && this.zombieEvolutionTree != null) {
      bestZombieNode = this.zombieEvolutionTree.getBestNode();
      if (bestZombieNode != null) {
        this.zombieGenotype = bestZombieNode.genotype.copy();
        this.currentZombieNode = bestZombieNode;
      }
    }
    
    if (evolveHuman && this.humanEvolutionTree != null) {
      bestHumanNode = this.humanEvolutionTree.getBestNode();
      if (bestHumanNode != null) {
        this.humanGenotype = bestHumanNode.genotype.copy();
        this.currentHumanNode = bestHumanNode;
      }
    }

    if (evolveZombie) {
      this.secondZombieParent = null;
      if (this.crossoverRate > 0 && random(1.0) < this.evolutionType) {
        this.crossoverZombies();
      } else {
        this.mutateZombies();
      }
    }
    
    if (evolveHuman) {
      this.secondHumanParent = null;
      if (this.crossoverRate > 0 && random(1.0) < this.evolutionType) {
        this.crossoverHumans();
      } else {
        this.mutateHumans();
      }
    }
    
    this.generation++;
    resetTimer(); 
  }
  
  float calculateZombieScore() {
    float score = this.timeRemaining;
    
    if (this.countAgents) {
      int zombieCount = 0;
      for (Agent a : this.agents) {
        if (a != null && a.isZombie) {
          zombieCount++;
        }
      }
      score += zombieCount;
    }
    
    return score;
  }
  
  float calculateHumanScore() {
    // Los humanos reciben mejor score mientras MÁS tiempo sobreviven
    float score = this.timeRemaining;
    
    if (this.countAgents) {
      int humanCount = 0;
      for (Agent a : this.agents) {
        if (a != null && !a.isZombie) {
          humanCount++;
        }
      }
      // Añadimos un bonus por el número de humanos que sobreviven
      score += humanCount * 2; // Multiplicador mayor para premiar supervivencia
    }
    
    return score;
  }

  void crossoverZombies() {
    if (this.zombieEvolutionTree == null || this.zombieEvolutionTree.allNodes.size() < 2) return;
    
    TreeNode parent1 = this.zombieEvolutionTree.getBestNode();
    TreeNode parent2 = this.zombieEvolutionTree.allNodes.get(int(random(this.zombieEvolutionTree.allNodes.size())));
    this.secondZombieParent = parent2;
    
    Genotype offspring = new Genotype();
    
    offspring.alignmentMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.alignmentMultiplier : parent2.genotype.alignmentMultiplier;
    offspring.cohesionMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.cohesionMultiplier : parent2.genotype.cohesionMultiplier;
    offspring.fleeMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.fleeMultiplier : parent2.genotype.fleeMultiplier;
    offspring.seekMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.seekMultiplier : parent2.genotype.seekMultiplier;
    offspring.arriveMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.arriveMultiplier : parent2.genotype.arriveMultiplier;
    offspring.wanderMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.wanderMultiplier : parent2.genotype.wanderMultiplier;
    offspring.pursueMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.pursueMultiplier : parent2.genotype.pursueMultiplier;
    offspring.evadeMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.evadeMultiplier : parent2.genotype.evadeMultiplier;
    offspring.pathFollowMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.pathFollowMultiplier : parent2.genotype.pathFollowMultiplier;
    offspring.obstacleAvoidanceMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.obstacleAvoidanceMultiplier : parent2.genotype.obstacleAvoidanceMultiplier;
    offspring.separationMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.separationMultiplier : parent2.genotype.separationMultiplier;
    offspring.speedMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.speedMultiplier : parent2.genotype.speedMultiplier;
    offspring.forceMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.forceMultiplier : parent2.genotype.forceMultiplier;
    
    this.zombieGenotype = offspring;
  }

  void crossoverHumans() {
    if (this.humanEvolutionTree == null || this.humanEvolutionTree.allNodes.size() < 2) return;
    
    TreeNode parent1 = this.humanEvolutionTree.getBestNode();
    TreeNode parent2 = this.humanEvolutionTree.allNodes.get(int(random(this.humanEvolutionTree.allNodes.size())));
    this.secondHumanParent = parent2;
    
    Genotype offspring = new Genotype();
    
    offspring.alignmentMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.alignmentMultiplier : parent2.genotype.alignmentMultiplier;
    offspring.cohesionMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.cohesionMultiplier : parent2.genotype.cohesionMultiplier;
    offspring.fleeMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.fleeMultiplier : parent2.genotype.fleeMultiplier;
    offspring.seekMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.seekMultiplier : parent2.genotype.seekMultiplier;
    offspring.arriveMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.arriveMultiplier : parent2.genotype.arriveMultiplier;
    offspring.wanderMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.wanderMultiplier : parent2.genotype.wanderMultiplier;
    offspring.pursueMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.pursueMultiplier : parent2.genotype.pursueMultiplier;
    offspring.evadeMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.evadeMultiplier : parent2.genotype.evadeMultiplier;
    offspring.pathFollowMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.pathFollowMultiplier : parent2.genotype.pathFollowMultiplier;
    offspring.obstacleAvoidanceMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.obstacleAvoidanceMultiplier : parent2.genotype.obstacleAvoidanceMultiplier;
    offspring.separationMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.separationMultiplier : parent2.genotype.separationMultiplier;
    offspring.speedMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.speedMultiplier : parent2.genotype.speedMultiplier;
    offspring.forceMultiplier = (random(1.0) < this.crossoverRate) ? 
      parent1.genotype.forceMultiplier : parent2.genotype.forceMultiplier;
    
    this.humanGenotype = offspring;
  }

  void mutateZombies() {
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.alignmentMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.alignmentMultiplier = constrain(this.zombieGenotype.alignmentMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.cohesionMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.cohesionMultiplier = constrain(this.zombieGenotype.cohesionMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.fleeMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.fleeMultiplier = constrain(this.zombieGenotype.fleeMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.seekMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.seekMultiplier = constrain(this.zombieGenotype.seekMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.arriveMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.arriveMultiplier = constrain(this.zombieGenotype.arriveMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.wanderMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.wanderMultiplier = constrain(this.zombieGenotype.wanderMultiplier, 0.5, 3);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.pursueMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.pursueMultiplier = constrain(this.zombieGenotype.pursueMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.evadeMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.evadeMultiplier = constrain(this.zombieGenotype.evadeMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.pathFollowMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.pathFollowMultiplier = constrain(this.zombieGenotype.pathFollowMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.obstacleAvoidanceMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.obstacleAvoidanceMultiplier = constrain(this.zombieGenotype.obstacleAvoidanceMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.separationMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.separationMultiplier = constrain(this.zombieGenotype.separationMultiplier, 2, 8);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.speedMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.speedMultiplier = constrain(this.zombieGenotype.speedMultiplier, 0.7, 3);
    }
    if (random(1.0) < this.mutationRate) {
      this.zombieGenotype.forceMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.zombieGenotype.forceMultiplier = constrain(this.zombieGenotype.forceMultiplier, 0.7, 2);
    }
  }

  void mutateHumans() {
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.alignmentMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.alignmentMultiplier = constrain(this.humanGenotype.alignmentMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.cohesionMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.cohesionMultiplier = constrain(this.humanGenotype.cohesionMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.fleeMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.fleeMultiplier = constrain(this.humanGenotype.fleeMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.seekMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.seekMultiplier = constrain(this.humanGenotype.seekMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.arriveMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.arriveMultiplier = constrain(this.humanGenotype.arriveMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.wanderMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.wanderMultiplier = constrain(this.humanGenotype.wanderMultiplier, 0.5, 3);
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.pursueMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.pursueMultiplier = constrain(this.humanGenotype.pursueMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.evadeMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.evadeMultiplier = constrain(this.humanGenotype.evadeMultiplier, 0.5, 8); // Rango mayor para evasión
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.pathFollowMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.pathFollowMultiplier = constrain(this.humanGenotype.pathFollowMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.obstacleAvoidanceMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.obstacleAvoidanceMultiplier = constrain(this.humanGenotype.obstacleAvoidanceMultiplier, 0.5, 6);
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.separationMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.separationMultiplier = constrain(this.humanGenotype.separationMultiplier, 2, 8);
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.speedMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.speedMultiplier = constrain(this.humanGenotype.speedMultiplier, 0.8, 3); // Rango más amplio de velocidad
    }
    if (random(1.0) < this.mutationRate) {
      this.humanGenotype.forceMultiplier += random(-this.evolutionRate, this.evolutionRate);
      this.humanGenotype.forceMultiplier = constrain(this.humanGenotype.forceMultiplier, 0.8, 2.5); // Rango más amplio de fuerza
    }
  }
  
  void displayTree(float x, float y) {
    if (evolveZombie && this.zombieEvolutionTree != null) {
      this.zombieEvolutionTree.display(x, y, 30);
      this.zombieEvolutionTree.displayInfo(10, 10);
    }

    else if (evolveHuman && this.humanEvolutionTree != null) {
      this.humanEvolutionTree.display(x, y, 30);
      this.humanEvolutionTree.displayInfo(10, 10);
    }
  }
}
