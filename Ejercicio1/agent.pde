class Agent {
    color c = #FF0000; // Color rojo
    float r = 6;
    float maxspeed = 8;
    PVector velocity = new PVector(0, 0);
    PVector acceleration = new PVector(0, 0);
    PVector position = new PVector(0, 0);
    float maxforce = 0.2;
    HashMap<String, Boolean> behaviors = new HashMap<String, Boolean>();

  Agent(color c, PVector position) {
    this.c = c;
    this.position = position;
    this.r = TRIANGLE_SIZE;
    this.behaviors.put("seek", false);
    this.behaviors.put("flee", false);
    this.behaviors.put("arrive", false);
    this.behaviors.put("wander", false);
    this.behaviors.put("pursue", false);
    this.behaviors.put("evade", false);
    this.behaviors.put("pathFollow", false);
    this.behaviors.put("obstacleAvoidance", false);
    this.behaviors.put("wallAvoidance", false);
    this.behaviors.put("separation", false);
    this.behaviors.put("alignment", false);
    this.behaviors.put("cohesion", false);
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
    PVector desired = PVector.sub(this.position, target);
    desired.setMag(this.maxspeed);
    PVector steer = PVector.sub(desired, this.velocity);
    steer.limit(this.maxforce);
    return steer;
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

}