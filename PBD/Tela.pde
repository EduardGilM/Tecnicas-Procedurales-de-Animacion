

PBDSystem crea_tela(float alto,
    float ancho,
    float dens,
    int n_alto,
    int n_ancho,
    float stiffness_struct,
    float stiffness_shear,
    float stiffness_bend,
    float display_size,
    boolean fijar_esquinas,
    boolean horizontal,
    float y_offset){
   
  int N = n_alto*n_ancho;
  float masa = dens*alto*ancho;
  PBDSystem tela = new PBDSystem(N,masa/N);
  
  float dx = ancho/(n_ancho-1.0);
  float dy = alto/(n_alto-1.0);
  
  int id = 0;
  for (int i = 0; i< n_ancho;i++){
    for(int j = 0; j< n_alto;j++){
      Particle p = tela.particles.get(id);
      if(horizontal) {
        // Tela horizontal en el plano XZ
        p.location.set(dx*i, y_offset, dy*j);
      } else {
        // Tela vertical en el plano XY
        p.location.set(dx*i, dy*j, 0);
      }
      p.display_size = display_size;

      id++;
    }
  }
  
  /**
   * Creo restricciones de distancia. Aquí sólo se crean restricciones de estructura.
   * Faltarían las de shear y las de bending.
   */
  /**
   * Creo restricciones de distancia.
   * 0: Structural, 1: Shear, 2: Bending
   */
  id = 0;
  for (int i = 0; i< n_ancho;i++){
    for(int j = 0; j< n_alto;j++){
      // println("id: "+id+" (i,j) = ("+i+","+j+")");
      Particle p = tela.particles.get(id);
      
      // --- STRUCTURAL (Type 0) ---
      if(i>0){
        int idx = id - n_alto;
        Particle px = tela.particles.get(idx);
        Constraint c = new DistanceConstraint(p,px,dx,stiffness_struct, 0);
        tela.add_constraint(c);
      }

      if(j>0){
        int idy = id - 1;
        Particle py = tela.particles.get(idy);
        Constraint c = new DistanceConstraint(p,py,dy,stiffness_struct, 0);
        tela.add_constraint(c);
      }
      
      // --- SHEAR (Type 1) ---
      // Diagonal (i-1, j-1)
      if(i>0 && j>0){
         int id_diag = (i-1)*n_alto + (j-1);
         Particle p_diag = tela.particles.get(id_diag);
         float diag_dist = sqrt(dx*dx + dy*dy);
         Constraint c = new DistanceConstraint(p, p_diag, diag_dist, stiffness_shear, 1);
         tela.add_constraint(c);
      }
      // Diagonal (i+1, j-1)
      if(i>0 && j < n_alto-1){
         int id_diag2 = (i-1)*n_alto + (j+1);
         Particle p_diag2 = tela.particles.get(id_diag2);
         float diag_dist = sqrt(dx*dx + dy*dy);
         Constraint c = new DistanceConstraint(p, p_diag2, diag_dist, stiffness_shear, 1);
         tela.add_constraint(c);
      }
      
      // --- BENDING (Type 2) ---
      if(i < n_ancho-1 && j > 0 && j < n_alto-1){
         Particle p1 = tela.particles.get(id); // (i,j)
         Particle p2 = tela.particles.get(id + n_alto); // (i+1,j)
         Particle p3 = tela.particles.get(id - 1); // (i,j-1)
         Particle p4 = tela.particles.get(id + 1); // (i,j+1)

         Constraint c = new DihedralBendingConstraint(p1, p2, p3, p4, stiffness_bend, 2);
         tela.add_constraint(c);
      }

      if(j < n_alto-1 && i > 0 && i < n_ancho-1){
         Particle p1 = tela.particles.get(id); // (i,j)
         Particle p2 = tela.particles.get(id + 1); // (i,j+1)
         Particle p3 = tela.particles.get(id - n_alto); // (i-1,j)
         Particle p4 = tela.particles.get(id + n_alto); // (i+1,j)

         Constraint c = new DihedralBendingConstraint(p1, p2, p3, p4, stiffness_bend, 2);
         tela.add_constraint(c);
      }

      id++;
    }
  }

  // Fijamos dos esquinas solo si está habilitado
  if(fijar_esquinas){
    id = n_alto-1;
    tela.particles.get(id).set_bloqueada(true);

    id = N-1;
    tela.particles.get(id).set_bloqueada(true);
  }

  print("Tela creada con " + tela.particles.size() + " partículas y " + tela.constraints.size() + " restricciones.");

  return tela;
}
