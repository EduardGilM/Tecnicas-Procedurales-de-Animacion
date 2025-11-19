import peasy.*;

PeasyCam cam;
float scale_px = 1000;

boolean debug = false;

PBDSystem system;

float dt = 0.02;

PVector vel_viento= new PVector(0,0,0);

//modulo de la intensidad del viento
float viento;


// Propiedades tela
float ancho_tela = 0.5;
float alto_tela = 0.5;
int n_ancho_tela = 10;
int n_alto_tela = 10;
float densidad_tela = 0.1; // kg/m^2 Podría ser tela gruesa de algodón, 100g/m^2
float sphere_size_tela = ancho_tela/n_ancho_tela*0.4;
float stiffness = 0.95;


// Propiedades esfera
PVector spherePos = new PVector(0,0,0);
float sphereRadius = 0.15;
SphereCollisionConstraint sphereConstraint;

boolean[] active_constraints = {true, true, true}; // 0: Struct, 1: Shear, 2: Bend

void setup(){

  size(720,480,P3D);

  cam = new PeasyCam(this,scale_px);
  cam.setMinimumDistance(1);
  // OJO!! Se le cambia el signo a la y, porque los px aumentan hacia abajo
  cam.pan(0.5*ancho_tela*scale_px, - 0.5*alto_tela*scale_px);
  
  
  system = crea_tela(alto_tela,
                      ancho_tela,
                      densidad_tela,
                      n_alto_tela,
                      n_ancho_tela,
                      stiffness,
                      sphere_size_tela);
                      
  system.set_n_iters(10);
  
  // Crear restriccion de colision con esfera
  sphereConstraint = new SphereCollisionConstraint(system.particles, spherePos, sphereRadius);
  system.add_constraint(sphereConstraint);
}

void aplica_viento(){
  // Aplicamos una fuerza que es proporcional al área.
  // No calculamos la normal. Se deja como ejercicio
  // El área se calcula como el área total, entre el número de partículas
  int npart = system.particles.size();
  float area_total = ancho_tela*alto_tela;
  float area = area_total/npart;
  for(int i = 0; i < npart; i++){
    float x = (0.5 + random(0.5))*vel_viento.x * area;
    float y = (0.5 + random(0.5))*vel_viento.y * area;
    float z = (0.5 + random(0.5))*vel_viento.z * area;
    PVector fv = new PVector(x,y,z); 
    system.particles.get(i).force.add(fv);
  }
  
  
}

void draw(){
  background(20,20,55);
  lights();

  // Mover esfera
  float time = millis() / 1000.0;
  spherePos.set(ancho_tela/2, alto_tela/2, sin(time) * 0.3);
  sphereConstraint.spherePos = spherePos; // Actualizar en constraint

  // Actualizar estado de restricciones
  for(Constraint c : system.constraints){
     if(c.type >= 0 && c.type <= 2){
        c.active = active_constraints[c.type];
     }
  }

  system.apply_gravity(new PVector(0.0,-0.81,0.0));
  aplica_viento();

  system.run(dt);  

  display();

  stats();
  
}



void stats(){
  

//escribe en la pantalla el numero de particulas actuales
  int npart = system.particles.size();
  fill(255);
  text("Frame-Rate: " + int(frameRate), -175, 15);

  text("Vel. Viento=("+vel_viento.x+", "+vel_viento.y+", "+vel_viento.x+")",-175,35);
  text("s - Arriba",-175,55);
  text("x - Abajo",-175,75);
  text("c - Derecha",-175,95);
  text("z - Izquierda",-175,115);
  
  text("1: Struct (" + active_constraints[0] + ")", -175, 135);
  text("2: Shear (" + active_constraints[1] + ")", -175, 155);
  text("3: Bend (" + active_constraints[2] + ")", -175, 175);



 //--->lo mismo se puede indicar para el viento
}

void display(){
  int npart = system.particles.size();
  int nconst = system.constraints.size();

  for(int i = 0; i < npart; i++){
    system.particles.get(i).display(scale_px);
  }
  
  for(int i = 0; i < nconst; i++)
      system.constraints.get(i).display(scale_px);
      
}



//Podeis usar esta funcion para controlar el lanzamiento delcastillo
//cada vez que se pulse el ratn se lanza otro cohete
//puede haber simultaneamente varios cohetes  (castillo = vector de cohetes )
void mousePressed(){
  PVector pos = new PVector(mouseX, height);
   //--->definir un color.Puede ser aleatorio usando random()
  color miColor = color(200,0,0);
//--->definir el tipo de cohete (circular, cono,eliptico,....)
//int tipo = int(random(1,6));


}
void keyPressed()
{
 // Tipo de restricciones
 if(key == '1') active_constraints[0] = !active_constraints[0];
 if(key == '2') active_constraints[1] = !active_constraints[1];
 if(key == '3') active_constraints[2] = !active_constraints[2];

 // Viento
  if(key == 'Y'){
    vel_viento.y -= 0.001;
  }else if(key == 'y'){
    vel_viento.y += 0.001;
  }else if(key == 'z'){
    vel_viento.z -= 0.001;
  }else if(key == 'Z'){
    vel_viento.z += 0.001;
  }else if(key == 'X'){
    vel_viento.x += 0.001;
  }else if(key == 'x'){
    vel_viento.x -= 0.001;
  }
  
}  