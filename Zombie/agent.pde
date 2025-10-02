class Agent {
    color c = #FF0000;
    float r = 6;
    float maxspeed = 8;
    PVector velocity = new PVector(0, 0);
    PVector acceleration = new PVector(0, 0);
    PVector position = new PVector(0, 0);
    float maxforce = 0.2;
    HashMap<String, Boolean> behaviors = new HashMap<String, Boolean>();
    float wanderTheta = 0;
    float wanderRadius = 25;
    float wanderDistance = 80;
    float wanderChange = 0.3;
    
    boolean isZombie = false;
    float captureRadius = 15;
    
    float seekMultiplier;
    float fleeMultiplier;
    float arriveMultiplier;
    float wanderMultiplier;
    float pursueMultiplier;
    float evadeMultiplier;
    float pathFollowMultiplier;
    float obstacleAvoidanceMultiplier;
    float separationMultiplier;
    float alignmentMultiplier;
    float cohesionMultiplier;

  Agent(color c, PVector position) {
    this.c = c;
    this.position = position;
    this.r = TRIANGLE_SIZE;
    this.behaviors.put("seek", false);
    this.behaviors.put("flee", false);
    this.behaviors.put("arrive", false);
    this.behaviors.put("wander", true);
    this.behaviors.put("pursue", false);
    this.behaviors.put("evade", false);
    this.behaviors.put("pathFollow", false);
    this.behaviors.put("obstacleAvoidance", true);
    this.behaviors.put("wallAvoidance", true);
    this.behaviors.put("separation", false);
    this.behaviors.put("alignment", false);
    this.behaviors.put("cohesion", false);
    
    this.seekMultiplier = random(0.5, 2.0);
    this.fleeMultiplier = random(0.8, 2.5);
    this.arriveMultiplier = random(0.5, 1.8);
    this.wanderMultiplier = random(0.1, 0.3);
    this.pursueMultiplier = random(0.8, 2.2);
    this.evadeMultiplier = random(1.0, 2.5);
    this.pathFollowMultiplier = random(0.7, 1.5);
    this.obstacleAvoidanceMultiplier = random(2.0, 4.0);
    this.separationMultiplier = random(1.0, 2.5);
    this.alignmentMultiplier = random(0.5, 1.5);
    this.cohesionMultiplier = random(0.8, 2.0);
  }

  void setBehavior(String behavior) {
    if (this.behaviors.containsKey(behavior)) {
      this.behaviors.put(behavior, !this.behaviors.get(behavior));
    }
  }

  void update() {
    this.velocity.add(this.acceleration);
    this.velocity.limit(this.maxspeed);
    this.position.add(this.velocity);
    this.acceleration.mult(0);
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, this.position);
    desired.setMag(this.maxspeed);
    PVector steer = PVector.sub(desired, this.velocity);
    steer.limit(this.maxforce);
    return steer;
  }

  PVector flee(PVector target) {
    return this.seek(target).mult(-1);
  }

  PVector arrive(PVector target) {
    PVector desired = PVector.sub(target, this.position);
    float d = desired.mag();

    if (d < 100) {

      float m = map(d, 0, 100, 0, this.maxspeed);
      desired.setMag(m);
    } else {
      desired.setMag(this.maxspeed);
    }

    PVector steer = PVector.sub(desired, this.velocity);
    steer.limit(this.maxforce);
    return steer;
  }

  PVector wallAvoidance() {
    PVector desired = null;
    PVector steer = new PVector(0, 0);
    float offset = 20;
    if (this.position.x < offset) {
      desired = new PVector(this.maxspeed, this.velocity.y);
    } else if (this.position.x > width - offset) {
      desired = new PVector(-this.maxspeed, this.velocity.y);
    }
    if (this.position.y < offset) {
      desired = new PVector(this.velocity.x, this.maxspeed);
    } else if (this.position.y > height - offset) {
      desired = new PVector(this.velocity.x, -this.maxspeed);
    }
    if (desired != null) {
      desired.normalize();
      desired.mult(this.maxspeed);
      steer = PVector.sub(desired, this.velocity);
      steer.limit(this.maxforce);
    }
    return steer;
  }

  PVector separate(ArrayList<Agent> agents) {
    float desiredSeparation = this.r * 5;
    PVector sum = new PVector(0, 0);
    PVector steer = new PVector(0, 0);
    int count = 0;
    for (Agent other : agents) {
      float d = PVector.dist(this.position, other.position);
      if (this != other && d < desiredSeparation) {
        PVector diff = PVector.sub(this.position, other.position);
        diff.setMag(1.0 / d);
        sum.add(diff);
        count++;
      }
    }
    if (count > 0) {
      sum.setMag(this.maxspeed);
      steer = PVector.sub(sum, this.velocity);
      steer.limit(this.maxforce);
    }
    return steer;
  }

  PVector align(ArrayList<Agent> agents) {
    float neighborDistance = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Agent other : agents) {
      float d = PVector.dist(this.position, other.position);
      if (this != other && d < neighborDistance) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.setMag(this.maxspeed);
      PVector steer = PVector.sub(sum, this.velocity);
      steer.limit(this.maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  PVector cohesion(ArrayList<Agent> agents) {
    float neighborDistance = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Agent other : agents) {
      float d = PVector.dist(this.position, other.position);
      if (this != other && d < neighborDistance) {
        sum.add(other.position);
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return this.seek(sum);
    } else {
      return new PVector(0, 0);
    }
  }

  PVector wander() {
    this.wanderTheta += random(-this.wanderChange, this.wanderChange);
    PVector circlePos = this.velocity.copy();
    circlePos.normalize();
    circlePos.mult(this.wanderDistance);
    circlePos.add(this.position);
    
    float h = this.velocity.heading();
    PVector circleOffset = new PVector(this.wanderRadius * cos(this.wanderTheta + h), 
                                        this.wanderRadius * sin(this.wanderTheta + h));
    PVector target = PVector.add(circlePos, circleOffset);
    return this.seek(target);
  }

  PVector avoidObstacles(ArrayList<Obstacle> obstacles) {
    float maxSeeAhead = 50;
    PVector ahead = this.velocity.copy();
    ahead.normalize();
    ahead.mult(maxSeeAhead);
    ahead.add(this.position);
    
    PVector ahead2 = this.velocity.copy();
    ahead2.normalize();
    ahead2.mult(maxSeeAhead * 0.5);
    ahead2.add(this.position);
    
    Obstacle mostThreatening = null;
    float minDistance = Float.MAX_VALUE;
    
    for (Obstacle obstacle : obstacles) {
      float distance1 = PVector.dist(ahead, obstacle.position);
      float distance2 = PVector.dist(ahead2, obstacle.position);
      float distance3 = PVector.dist(this.position, obstacle.position);
      float minDist = min(distance1, min(distance2, distance3));
      
      if (minDist < obstacle.radius + this.r && minDist < minDistance) {
        minDistance = minDist;
        mostThreatening = obstacle;
      }
    }
    
    PVector avoidance = new PVector(0, 0);
    if (mostThreatening != null) {
      avoidance = PVector.sub(ahead, mostThreatening.position);
      avoidance.normalize();
      avoidance.mult(this.maxspeed);
    }
    return avoidance;
  }

  PVector follow(Path p) {
    PVector predict = this.velocity.copy();
    predict.normalize();
    predict.mult(25);
    PVector predictPos = PVector.add(this.position, predict);
    
    PVector target = null;
    float worldRecord = 1000000;
    
    for (int i = 0; i < p.points.size() - 1; i++) {
      PVector a = p.points.get(i);
      PVector b = p.points.get(i + 1);
      PVector normalPoint = getNormalPoint(predictPos, a, b);
      
      if (normalPoint.x < min(a.x, b.x) || normalPoint.x > max(a.x, b.x) ||
          normalPoint.y < min(a.y, b.y) || normalPoint.y > max(a.y, b.y)) {
        normalPoint = b.copy();
      }
      
      float distance = PVector.dist(predictPos, normalPoint);
      if (distance < worldRecord) {
        worldRecord = distance;
        target = normalPoint.copy();
        
        PVector dir = PVector.sub(b, a);
        dir.normalize();
        dir.mult(10);
        target.add(dir);
      }
    }
    
    if (worldRecord > p.radius) {
      return this.seek(target);
    }
    return new PVector(0, 0);
  }

  PVector getNormalPoint(PVector p, PVector a, PVector b) {
    PVector ap = PVector.sub(p, a);
    PVector ab = PVector.sub(b, a);
    ab.normalize();
    ab.mult(ap.dot(ab));
    PVector normalPoint = PVector.add(a, ab);
    return normalPoint;
  }

  void applyForce(PVector force) {
    this.acceleration.add(force);
  }

  void show() {
    float angle = this.velocity.heading();
    fill(this.c);
    stroke(0);
    push();
    translate(this.position.x, this.position.y);
    rotate(angle);
    beginShape();
    vertex(this.r * 2, 0);
    vertex(-this.r * 2, -this.r);
    vertex(-this.r * 2, this.r);
    endShape(CLOSE);
    pop();
  }
  
  void becomeZombie() {
    this.isZombie = true;
    this.c = color(0, 255, 0);
    this.behaviors.put("separation", true);
    this.behaviors.put("alignment", true);
    this.behaviors.put("cohesion", true);
  }
  
  PVector pursueNearestHuman(ArrayList<Agent> agents) {
    Agent target = null;
    float minDistance = Float.MAX_VALUE;
    
    for (Agent other : agents) {
      if (!other.isZombie && other != this) {
        float d = PVector.dist(this.position, other.position);
        if (d < minDistance) {
          minDistance = d;
          target = other;
        }
      }
    }
    
    if (target != null) {
      return this.seek(target.position);
    }
    return new PVector(0, 0);
  }
  
  PVector evadeNearestZombie(ArrayList<Agent> agents) {
    Agent threat = null;
    float minDistance = Float.MAX_VALUE;
    
    for (Agent other : agents) {
      if (other.isZombie && other != this) {
        float d = PVector.dist(this.position, other.position);
        if (d < minDistance) {
          minDistance = d;
          threat = other;
        }
      }
    }
    
    if (threat != null) {
      return this.flee(threat.position);
    }
    return new PVector(0, 0);
  }
  
  void checkCapture(ArrayList<Agent> agents) {
    if (this.isZombie) {
      for (Agent other : agents) {
        if (!other.isZombie) {
          float d = PVector.dist(this.position, other.position);
          if (d < this.captureRadius) {
            other.becomeZombie();
          }
        }
      }
    }
  }
  
  PVector separateZombies(ArrayList<Agent> agents) {
    float desiredSeparation = this.r * 4;
    PVector sum = new PVector(0, 0);
    PVector steer = new PVector(0, 0);
    int count = 0;
    for (Agent other : agents) {
      if (other.isZombie && other != this) {
        float d = PVector.dist(this.position, other.position);
        if (d < desiredSeparation) {
          PVector diff = PVector.sub(this.position, other.position);
          diff.setMag(1.0 / d);
          sum.add(diff);
          count++;
        }
      }
    }
    if (count > 0) {
      sum.setMag(this.maxspeed);
      steer = PVector.sub(sum, this.velocity);
      steer.limit(this.maxforce);
    }
    return steer;
  }
  
  PVector alignZombies(ArrayList<Agent> agents) {
    float neighborDistance = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Agent other : agents) {
      if (other.isZombie && other != this) {
        float d = PVector.dist(this.position, other.position);
        if (d < neighborDistance) {
          sum.add(other.velocity);
          count++;
        }
      }
    }
    if (count > 0) {
      sum.setMag(this.maxspeed);
      PVector steer = PVector.sub(sum, this.velocity);
      steer.limit(this.maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }
  
  PVector cohesionZombies(ArrayList<Agent> agents) {
    float neighborDistance = 60;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Agent other : agents) {
      if (other.isZombie && other != this) {
        float d = PVector.dist(this.position, other.position);
        if (d < neighborDistance) {
          sum.add(other.position);
          count++;
        }
      }
    }
    if (count > 0) {
      sum.div(count);
      return this.seek(sum);
    } else {
      return new PVector(0, 0);
    }
  }

}