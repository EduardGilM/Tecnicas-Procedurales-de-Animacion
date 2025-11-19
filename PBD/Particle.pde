class Particle {

  PVector acceleration;
  PVector force;
  PVector velocity;
  PVector location;
  PVector last_location;
  
  float masa;
  float w;
  
  boolean bloqueada;
  
  float display_size;

  Particle(PVector l, PVector v, float ma) {
    acceleration = new PVector(0.0f,0.0f,0.0f);
    force = new PVector(0.0f,0.0f,0.0f);
    velocity = v.get();
    location = l.get();
    
    masa = ma;
    w = 1.0f/ma;   
    
    display_size = 0.1;
  }

  void set_bloqueada(boolean bl){
    bloqueada = true;
    w = 0;
    masa = Float.POSITIVE_INFINITY;
  }

  void update_pbd_vel(float dt){
   velocity = PVector.sub(location, last_location).div(dt);
  }

  // Method to update location
  void update(float dt) {

    //--->actualizar la aceleracion de la particula con la fuerza actual
    acceleration.add(force.mult(w));
    
    //--->guardamos posicion anterior, para PBD 
    last_location = location.copy();

    //---> Predicción de PBD
    //---> Utilizar euler semiimplicito para calcular velocidad y posicion
    velocity.add(acceleration.mult(dt));
    location.add(velocity.mult(dt)); 
    
    //---> Limpieza de fuerzas y aceleraciones
    acceleration = new PVector(0.0f,0.0f,0.0f);
    force = new PVector(0.0f,0.0f,0.0f);
  }
  
  PVector getLocation(){
    return location;
  }

  PVector getLastLocation(){
    return last_location;
  }

  void display(float scale_px){
    strokeWeight(1);
    stroke(125);
    pushMatrix();
      fill(220);
      translate(scale_px*location.x,
                  -scale_px*location.y, // OJO!! Se le cambia el signo, porque los px aumentan hacia abajo
                  scale_px*location.z);
      sphereDetail(12);
      sphere(scale_px*display_size);
    popMatrix();
      
  }

}