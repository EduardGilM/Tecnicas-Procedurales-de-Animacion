
abstract class Constraint{

  ArrayList<Particle> particles;
  float stiffness;    // k en el paper de Muller
  float k_coef;       // k' en el paper de Muller
  float C;
  
  int type; // 0: Structural, 1: Shear, 2: Bending, 3: Collision
  boolean active = true;

  Constraint(){
    particles = new ArrayList<Particle>();
  }
  
  void  compute_k_coef(int n){
    k_coef = 1.0 - pow((1.0-stiffness),1.0/float(n));
    // println("Fijamos "+n+" iteraciones   -->  k = "+stiffness+"    k' = "+k_coef+".");
  }

  abstract void proyecta_restriccion();
  abstract void display(float scale_px);
}

class DistanceConstraint extends Constraint{

  float d;
  
  DistanceConstraint(Particle p1,Particle p2,float dist,float k, int t){
    super();
    d = dist;
    particles.add(p1);
    particles.add(p2);
    stiffness = k;
    k_coef = stiffness;
    C=0;
    type = t;
  }
  
  void proyecta_restriccion(){
    if(!active) return;

    Particle p1 = particles.get(0); 
    Particle p2 = particles.get(1);
    
    PVector delta = PVector.sub(p1.location, p2.location);
    float current_dist = delta.mag();
    
    // Evitar division por cero
    if(current_dist < 1e-6) return;

    float correction = (current_dist - d) / current_dist;
    
    // PBD Correction: delta_p = (w / (w1 + w2)) * C(p) * grad(C)
    // C(p) = |p1 - p2| - d
    // grad(C) es la direccion normalizada
    
    PVector corrVector = PVector.mult(delta, k_coef * correction);
    
    float w1 = p1.w;
    float w2 = p2.w;
    float wTotal = w1 + w2;
    
    if(wTotal > 0){
       PVector move1 = PVector.mult(corrVector, -w1 / wTotal);
       PVector move2 = PVector.mult(corrVector, w2 / wTotal);
       
       p1.location.add(move1);
       p2.location.add(move2);
    }
    
    C = current_dist - d; // Para visualizacion
  }
  
  void display(float scale_px){
    if(!active) return;
    
    PVector p1 = particles.get(0).location; 
    PVector p2 = particles.get(1).location; 
    strokeWeight(1);
    
    // Color segun tipo
    if(type == 0) stroke(255, 255, 255); // Estructural: Blanco
    else if(type == 1) stroke(255, 0, 0); // Shear: Rojo
    else if(type == 2) stroke(0, 255, 0); // Bending: Verde
    else stroke(200);

    line(scale_px*p1.x, -scale_px*p1.y, scale_px*p1.z,  scale_px*p2.x, -scale_px*p2.y, scale_px*p2.z);
  };
  
}

class SphereCollisionConstraint extends Constraint {
  PVector spherePos;
  float sphereRadius;
  
  SphereCollisionConstraint(ArrayList<Particle> parts, PVector pos, float r){
    super();
    particles = parts;
    spherePos = pos;
    sphereRadius = r;
    type = 3;
    stiffness = 1.0; // Colision dura
  }
  
  void proyecta_restriccion(){
    // No tiene active flag controlado por usuario directamente, o si? 
    // El usuario pidio activar restricciones 1, 2, 3. La colision es implicita con la esfera.
    // Asumiremos que siempre esta activa si la esfera esta ahi.
    
    for(Particle p : particles){
      PVector dir = PVector.sub(p.location, spherePos);
      float dist = dir.mag();
      
      if(dist < sphereRadius){
        // Colision detectada
        // Proyectar al borde de la esfera
        dir.normalize();
        PVector target = PVector.add(spherePos, PVector.mult(dir, sphereRadius));
        
        // Mover particula directamente (asumiendo masa infinita de la esfera)
        if(p.w > 0){
           p.location.set(target);
           
           // Opcional: Friccion
           // PVector velocity = p.velocity;
           // ...
        }
      }
    }
  }
  
  void display(float scale_px){
    pushMatrix();
    noStroke();
    fill(100, 100, 255, 150);
    translate(scale_px*spherePos.x, -scale_px*spherePos.y, scale_px*spherePos.z);
    sphere(scale_px*sphereRadius);
    popMatrix();
  }
}

class DihedralBendingConstraint extends Constraint {
  
  float phi0; // Rest angle
  
  DihedralBendingConstraint(Particle p1, Particle p2, Particle p3, Particle p4, float k, int t){
    super();
    particles.add(p1); // Shared 1
    particles.add(p2); // Shared 2
    particles.add(p3); // Wing 1
    particles.add(p4); // Wing 2
    stiffness = k;
    k_coef = stiffness; // Simplified for now
    type = t;
    
    // Calculate rest angle
    PVector p1_pos = p1.location;
    PVector p2_pos = p2.location;
    PVector p3_pos = p3.location;
    PVector p4_pos = p4.location;
    
    PVector n1 = PVector.sub(p2_pos, p1_pos).cross(PVector.sub(p3_pos, p1_pos));
    PVector n2 = PVector.sub(p2_pos, p1_pos).cross(PVector.sub(p4_pos, p1_pos));
    n1.normalize();
    n2.normalize();
    
    float d = n1.dot(n2);
    d = constrain(d, -1.0, 1.0);
    phi0 = acos(d);
  }
  
  void proyecta_restriccion(){
    if(!active) return;
    
    Particle p1 = particles.get(0);
    Particle p2 = particles.get(1);
    Particle p3 = particles.get(2);
    Particle p4 = particles.get(3);
    
    PVector p1_pos = p1.location;
    PVector p2_pos = p2.location;
    PVector p3_pos = p3.location;
    PVector p4_pos = p4.location;
    
    PVector p2_p1 = PVector.sub(p2_pos, p1_pos);
    PVector p3_p1 = PVector.sub(p3_pos, p1_pos);
    PVector p4_p1 = PVector.sub(p4_pos, p1_pos);
    
    // Normals
    PVector n1 = p2_p1.cross(p3_p1);
    PVector n2 = p2_p1.cross(p4_p1);
    
    float l_n1 = n1.mag();
    float l_n2 = n2.mag();
    
    if(l_n1 < 1e-6 || l_n2 < 1e-6) return;
    
    n1.div(l_n1);
    n2.div(l_n2);
    
    float d = n1.dot(n2);
    d = constrain(d, -1.0, 1.0);

    float current_phi = acos(d);

    float cross_mag = (n1.cross(n2)).mag();
    if(cross_mag < 1e-6) return; // 0 or 180 degrees
    
    float factor = -1.0 / sqrt(1.0 - d*d);

    PVector q3 = p2_p1.cross(n1);
    q3.div(l_n1 * l_n1);
    
    PVector q4 = p2_p1.cross(n2);
    q4.div(l_n2 * l_n2);
    
    PVector q2 = p3_p1.cross(n1);
    q2.div(l_n1 * l_n1);
    PVector t = p4_p1.cross(n2);
    t.div(l_n2 * l_n2);
    q2.add(t);
    q2.mult(-1);
    
    PVector q1 = PVector.add(q2, q3);
    q1.add(q4);
    q1.mult(-1);
    
    // Calculate C
    float C = acos(d) - phi0;
    
    // Scaling factor
    float sum_w = 
      p1.w * q1.magSq() +
      p2.w * q2.magSq() +
      p3.w * q3.magSq() +
      p4.w * q4.magSq();
      
    if(sum_w < 1e-6) return;
    
    float s = -stiffness * C / sum_w;
    
    if(p1.w > 0) p1.location.add(PVector.mult(q1, s * p1.w));
    if(p2.w > 0) p2.location.add(PVector.mult(q2, s * p2.w));
    if(p3.w > 0) p3.location.add(PVector.mult(q3, s * p3.w));
    if(p4.w > 0) p4.location.add(PVector.mult(q4, s * p4.w));
  }
  
  void display(float scale_px){
    if(!active) return;
    Particle p3 = particles.get(2);
    Particle p4 = particles.get(3);
    
    stroke(0, 255, 0);
    strokeWeight(1);
    line(scale_px*p3.location.x, -scale_px*p3.location.y, scale_px*p3.location.z,
         scale_px*p4.location.x, -scale_px*p4.location.y, scale_px*p4.location.z);
  }
}
