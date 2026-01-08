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
int n_ancho_tela = 30;
int n_alto_tela = 30;
float densidad_tela = 0.1; // kg/m^2 Podría ser tela gruesa de algodón, 100g/m^2
float sphere_size_tela = ancho_tela/n_ancho_tela*0.4;

// Stiffness separados para cada tipo de restricción
float stiffness_struct = 0.3;  // Structural
float stiffness_shear = 0.9;  // Shear
float stiffness_bend = 0.3;   // Bending


// Propiedades esfera
PVector spherePos = new PVector(0,0,0);
float sphereRadius = 0.15;
SphereCollisionConstraint sphereConstraint;
float sceneStartTime = 0; // Tiempo de inicio de la escena actual

int current_scene = 1; // 1: Solo tela, 2: Tela+Shear, 3: Tela+Bending, 4: Tela+Shear+Bending

// Configuración de escenas
boolean viento_enabled = false;
boolean esfera_enabled = false;

boolean[] active_constraints = {true, false, false}; // 0: Struct, 1: Shear, 2: Bend

void setup(){

  size(960,540,P3D);

  cam = new PeasyCam(this,scale_px);
  cam.setMinimumDistance(1);
  // OJO!! Se le cambia el signo a la y, porque los px aumentan hacia abajo
  cam.pan(0.5*ancho_tela*scale_px, - 0.5*alto_tela*scale_px + 200);

  setup_scene();
}

void setup_scene() {
  // Reiniciar tiempo de la escena
  sceneStartTime = millis();

  // Configurar restricciones según escena
  switch(current_scene) {
    case 1: // Solo tela (solo structural)
      active_constraints[0] = true;
      active_constraints[1] = false;
      active_constraints[2] = false;
      break;
    case 2: // Tela + shear
      active_constraints[0] = true;
      active_constraints[1] = true;
      active_constraints[2] = false;
      break;
    case 3: // Tela + bending
      active_constraints[0] = true;
      active_constraints[1] = false;
      active_constraints[2] = true;
      break;
    case 4: // Tela + shear + bending
      active_constraints[0] = true;
      active_constraints[1] = true;
      active_constraints[2] = true;
      break;
    case 5: // Tela sobre esfera (caída libre)
      active_constraints[0] = true;
      active_constraints[1] = true;
      active_constraints[2] = true;
      break;
  }

  // Crear tela (sin fijar esquinas en escena 5, horizontal en escena 5)
  boolean fijar_esquinas = (current_scene != 5);
  boolean horizontal = (current_scene == 5);
  float y_offset = horizontal ? alto_tela * 1.5 : 0; // En escena 5, tela más arriba para caer sobre esfera
  system = crea_tela(alto_tela,
                      ancho_tela,
                      densidad_tela,
                      n_alto_tela,
                      n_ancho_tela,
                      stiffness_struct,
                      stiffness_shear,
                      stiffness_bend,
                      sphere_size_tela,
                      fijar_esquinas,
                      horizontal,
                      y_offset);

  system.set_n_iters(15);

  // Crear esfera: en escena 5 siempre, en otras solo si está habilitada
  if(current_scene == 5 || esfera_enabled) {
    if(current_scene == 5) {
      spherePos.set(ancho_tela/2, alto_tela * 0.1, 0); // Esfera debajo de la tela horizontal
    } else {
      spherePos.set(0, 0, 0); // Reiniciar posición de la esfera
    }
    sphereConstraint = new SphereCollisionConstraint(system.particles, spherePos, sphereRadius);
    system.add_constraint(sphereConstraint);
  } else {
    sphereConstraint = null;
  }

  // Configurar viento si está habilitado (solo magnitud, dirección desde cámara)
  if(viento_enabled) {
    vel_viento.set(0.05, 0, 0); // Magnitud inicial del viento (solo X importa)
  } else {
    vel_viento.set(0, 0, 0);
  }
}

void aplica_viento(){
  // Aplicamos una fuerza que es proporcional al área.
  // El área se calcula como el área total, entre el número de partículas
  int npart = system.particles.size();
  float area_total = ancho_tela*alto_tela;
  float area = area_total/npart;

  float[] camPos = cam.getPosition();
  PVector telaCenter = new PVector(ancho_tela/2, alto_tela/2, 0);
  PVector camPosVec = new PVector(camPos[0], camPos[1], camPos[2]);
  PVector windDir = PVector.sub(telaCenter, camPosVec);
  windDir.normalize();

  // Aplicar magnitud del viento (usamos la magnitud del vector vel_viento actual)
  float windMagnitude = vel_viento.mag();
  if(windMagnitude < 0.001) windMagnitude = 1.0; // Valor mínimo si está en cero

  for(int i = 0; i < npart; i++){
    // Variación aleatoria para efecto de turbulencia
    float variation = 0.8 + random(0.4); // Entre 0.8 y 1.2

    float x = windDir.x * windMagnitude * variation * area;
    float y = windDir.y * windMagnitude * variation * area;
    float z = windDir.z * windMagnitude * variation * area;
    PVector fv = new PVector(x,y,z);
    system.particles.get(i).force.add(fv);
  }


}

void draw(){
  background(20,20,55);
  lights();

  // Mover esfera
  if((esfera_enabled || current_scene == 5) && sphereConstraint != null) {
    if(current_scene == 5) {
      // Escena 5: Esfera fija en el centro debajo de la tela horizontal
      spherePos.set(ancho_tela/2, alto_tela * 0.1, alto_tela/2);
    } else {
      // Otras escenas: Esfera moviéndose adelante/atrás
      float time = (millis() - sceneStartTime) / 1000.0 + 1.5;
      // Posición media-baja de la tela, moviéndose adelante/atrás (eje Z)
      spherePos.set(ancho_tela/2, alto_tela * 0.3, sin(time) * 0.3);
    }
    sphereConstraint.spherePos = spherePos; // Actualizar en constraint
  }

  // Actualizar estado de restricciones
  for(Constraint c : system.constraints){
     if(c.type >= 0 && c.type <= 2){
        c.active = active_constraints[c.type];
     }
  }

  system.apply_gravity(new PVector(0.0,-0.81,0.0));
  if(viento_enabled) {
    aplica_viento();
  }

  system.run(dt);

  display();

  stats();

}



void stats(){
  // Texto de UI desactivado
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
 // Cambiar escenas (1-5)
 if(key == '1') { current_scene = 1; setup_scene(); }
 if(key == '2') { current_scene = 2; setup_scene(); }
 if(key == '3') { current_scene = 3; setup_scene(); }
 if(key == '4') { current_scene = 4; setup_scene(); }
 if(key == '5') { current_scene = 5; setup_scene(); }

 // Activar/Desactivar viento y esfera
 if(key == 'v' || key == 'V') { viento_enabled = !viento_enabled; setup_scene(); }
 if(key == 'e' || key == 'E') { esfera_enabled = !esfera_enabled; setup_scene(); }

  // Reiniciar escena
  if(key == 'r' || key == 'R') { setup_scene(); }

  // Control de stiffness (requiere reiniciar)
  if(key == 'q') { stiffness_struct = min(1.0, stiffness_struct + 0.05); setup_scene(); }
  if(key == 'w') { stiffness_struct = max(0.0, stiffness_struct - 0.05); setup_scene(); }
  if(key == 'a') { stiffness_shear = min(1.0, stiffness_shear + 0.05); setup_scene(); }
  if(key == 's') { stiffness_shear = max(0.0, stiffness_shear - 0.05); setup_scene(); }
  if(key == 'z') { stiffness_bend = min(1.0, stiffness_bend + 0.05); setup_scene(); }
  if(key == 'x') { stiffness_bend = max(0.0, stiffness_bend - 0.05); setup_scene(); }

   // Control de viento (solo magnitud, dirección desde cámara)
   if(viento_enabled) {
     float currentMagnitude = vel_viento.mag();
     if(key == 'f' || key == 'F'){
       float delta = (key == 'F') ? 0.02 : -0.02;
       float newMagnitude = max(0, currentMagnitude + delta);
       vel_viento.set(newMagnitude, 0, 0);
     }
   }

}