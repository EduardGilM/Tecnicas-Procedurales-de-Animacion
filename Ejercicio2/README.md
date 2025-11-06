# Path Planning con A* en Processing

Sistema completo de path planning usando el algoritmo A* con benchmarking y flocking.

## 📋 Características

### Tarea A: Benchmarking de Rendimiento
- **100 iteraciones** por cada tamaño de grid
- Rango: **20×20** hasta **150×150** (pasos de 10)
- Cada iteración genera un grid nuevo con **3% de obstáculos** en posiciones aleatorias
- Calcula **media** y **desviación estándar** para cada tamaño
- Genera archivos para visualización con **gnuplot**

### Tarea B: Flocking con Comportamiento Seek
- Boids que siguen el path generado por A*
- Comportamiento **seek** hacia waypoints sucesivos
- Activación/desactivación con tecla **`-`**

## 🎮 Controles

### Modo Navegación
| Tecla | Acción |
|-------|--------|
| **Click izquierdo** | Establecer nuevo destino |
| **O** | Añadir obstáculo aleatorio |
| **C** | Limpiar todos los obstáculos |
| **-** | **Activar/Desactivar flocks** (toggle) |
| **+** | **Iniciar benchmark completo** (20×20 a 150×150) |
| **R** | Reiniciar escena |

### Modo Benchmark
| Tecla | Acción |
|-------|--------|
| **N** | Volver al modo navegación |

## 🚀 Ejecución

1. Abre `AlphaStar.pde` en Processing
2. Ejecuta el programa (▶️ Run)
3. Presiona **`+`** para iniciar el benchmark completo

### Proceso del Benchmark

El benchmark ejecutará automáticamente:
- 100 iteraciones de 20×20
- 100 iteraciones de 30×30
- 100 iteraciones de 40×40
- ...
- 100 iteraciones de 150×150

**Total**: 14 tamaños × 100 iteraciones = **1,400 ejecuciones de A***

⏱️ **Tiempo estimado**: 2-5 minutos (dependiendo del hardware)

## 📊 Generación de Gráficas

Al finalizar el benchmark, se generan automáticamente:

### Archivos Generados

1. **`benchmark_data.txt`**: Datos en formato texto
   ```
   # GridSize AvgTime(ms) StdDev(ms)
   20 0.523 0.142
   30 1.234 0.287
   40 2.456 0.432
   ...
   ```

2. **`plot_benchmark.gnuplot`**: Script para gnuplot

### Crear Gráfica PNG con Gnuplot

```bash
gnuplot plot_benchmark.gnuplot
```

Esto generará **`benchmark_plot.png`** con:
- Eje X: Tamaño del grid (n × n)
- Eje Y: Tiempo promedio en milisegundos
- Puntos con barras de error (media ± desviación estándar)
- Línea continua conectando los puntos

## 🧩 Algoritmo A*

### Implementación
- **Heurística**: Distancia Manhattan
- **Costo de movimiento**: Distancia euclidiana (permite diagonales)
- **Estructura**: Listas open y closed
- **Vecinos**: 8 direcciones (incluye movimiento diagonal)

### Fórmula
```
f(n) = g(n) + h(n)

donde:
- g(n) = costo desde inicio hasta nodo n
- h(n) = estimación de costo desde n hasta objetivo (Manhattan)
- f(n) = costo total estimado
```

## 🐦 Sistema de Flocking (Tarea B)

### Comportamiento Seek
El boid implementa steering behavior para seguir waypoints:

```
desired = targetPosition - currentPosition
desired.normalize()
desired *= maxSpeed
steer = desired - velocity
steer.limit(maxForce)
```

### Características
- **Velocidad máxima**: 3.0 píxeles/frame
- **Fuerza máxima**: 0.1 (suavizado)
- **Radio de waypoint**: cellSize/2
- Avanza automáticamente al siguiente waypoint al alcanzar el actual

## 📈 Visualización

### Colores en el Grid
- 🟩 **Verde**: Punto de inicio (0,0)
- 🟥 **Rojo**: Punto de destino
- ⬛ **Negro**: Obstáculos
- 🔵 **Azul**: Path calculado por A*
- 🟧 **Naranja**: Boid (triángulo direccional)
- 🔴 **Círculo rojo**: Waypoint actual del boid

### Gráfica de Benchmark
- Barras de error que muestran la desviación estándar
- Línea continua conectando medias
- Cuadrícula para fácil lectura
- Escala automática según datos

## 🔧 Configuración

Puedes modificar estos valores en el código:

```processing
int gridSize = 20;           // Tamaño inicial del grid
float obstaclePercentage = 0.03;  // 3% de obstáculos

// Benchmark
int currentBenchmarkSize = 20;    // Inicio
int maxBenchmarkSize = 150;       // Fin
int benchmarkStep = 10;           // Incremento
int benchmarkIterations = 100;    // Iteraciones por tamaño

// Boid
float maxSpeed = 3.0;             // Velocidad máxima
float maxForce = 0.1;             // Fuerza de steering
```

## 📝 Notas

- El benchmark es **automático e incremental**: ejecuta una iteración por frame para mantener la interfaz responsive
- Los obstáculos se regeneran aleatoriamente en cada iteración del benchmark
- Los puntos de inicio (0,0) y destino (n-1,n-1) **nunca** son obstáculos
- El path se recalcula automáticamente al añadir/eliminar obstáculos o cambiar el destino

## 🎓 Técnicas Implementadas

1. **Path Planning**: Algoritmo A* completo con heurística y costos
2. **Benchmarking**: Análisis estadístico de rendimiento
3. **Steering Behaviors**: Seek para navegación fluida
4. **Visualización**: Representación gráfica interactiva
5. **Exportación de datos**: Integración con herramientas externas (gnuplot)

---

**Autor**: Sistema de Path Planning con A*  
**Framework**: Processing 4.x  
**Lenguaje**: Java (Processing)
