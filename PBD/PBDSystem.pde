class PBDSystem {
  // Partículas del sistema
  ArrayList<Particle> particles;
  ArrayList<Constraint> constraints;
  
  int niters;


  PBDSystem(int n,float mass) {
    //array de particulas luminosas.Aun NO SE CREAN las particulas concretas
    particles = new ArrayList<Particle>(n);
    constraints = new ArrayList<Constraint>();
    
    niters = 5;
    
    PVector p = new PVector(0,0,0);
    PVector v = new PVector(0,0,0);
 
    for(int i=0;i<n;i++){
      particles.add(new Particle(p,v,mass));
    }
  }

  void set_n_iters(int n){
   niters = n;
   for(int i = 0; i< constraints.size(); i++)
     constraints.get(i).compute_k_coef(n);
  }

  void add_constraint(Constraint c){
     constraints.add(c);
     c.compute_k_coef(niters);
  }

  void apply_gravity(PVector g){
    Particle p;
    for(int i = 0 ; i<particles.size() ; i++){
      p = particles.get(i);
      if(p.w > 0) // Si la masa en infinito, no se aplica
        p.force.add(PVector.mult(g,p.masa));
    }
  }

  void run(float dt) {
    //Simulacion
    for (int i = 0; i < particles.size(); i++)
      particles.get(i).update(dt);

    for(int it = 0; it< niters; it++)
      for(int i = 0; i< constraints.size(); i++)
        constraints.get(i).proyecta_restriccion();
     
    for (int i = 0; i < particles.size(); i++)
      particles.get(i).update_pbd_vel(dt);
    
  }

}