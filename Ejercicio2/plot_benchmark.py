#!/usr/bin/env python3
"""
Script para generar gráficas del benchmark de A* usando matplotlib
"""

import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# Leer el archivo de datos
data_file = Path("benchmark_data.txt")

grid_sizes = []
avg_times = []
std_devs = []
avg_explored = []
std_devs_explored = []
obstacle_percentage = "40%"

with open(data_file, 'r') as f:
    for line in f:
        line = line.strip()
        
        # Extraer porcentaje de obstáculos del comentario
        if "de obstáculos" in line:
            parts = line.split("#")[1].strip().split()
            obstacle_percentage = parts[0]
            continue
        
        # Saltar líneas de comentario
        if line.startswith("#") or not line:
            continue
        
        # Parsear datos
        parts = line.split()
        if len(parts) >= 3:
            try:
                grid_sizes.append(int(parts[0]))
                avg_times.append(float(parts[1]))
                std_devs.append(float(parts[2]))
                # Nodos explorados (opcional, para compatibilidad con datos antiguos)
                if len(parts) >= 5:
                    avg_explored.append(int(parts[3]))
                    std_devs_explored.append(int(parts[4]))
            except ValueError:
                continue

# Crear figura con subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

# Gráfica 1: Tiempo promedio con barras de error
ax1.errorbar(grid_sizes, avg_times, yerr=std_devs, fmt='o-', 
             color='#0060ad', ecolor='#999999', elinewidth=1.5, markersize=8,
             capsize=5, capthick=1.5, label='A* (media ± desv. típica)')
ax1.set_xlabel('Tamaño del Grid (n × n)', fontsize=12, fontweight='bold')
ax1.set_ylabel('Tiempo promedio (ms)', fontsize=12, fontweight='bold')
ax1.set_title(f'Rendimiento del Algoritmo A* ({obstacle_percentage} obstáculos)', 
              fontsize=14, fontweight='bold')
ax1.grid(True, alpha=0.3)
ax1.legend(fontsize=11)
ax1.set_xlim(15, 155)

# Gráfica 2: Nodos explorados si están disponibles
if avg_explored:
    ax2.errorbar(grid_sizes, avg_explored, yerr=std_devs_explored, fmt='s-', 
                 color='#ad6600', ecolor='#999999', elinewidth=1.5, markersize=8,
                 capsize=5, capthick=1.5, label='Nodos explorados (media ± desv. típica)')
    ax2.set_xlabel('Tamaño del Grid (n × n)', fontsize=12, fontweight='bold')
    ax2.set_ylabel('Nodos explorados', fontsize=12, fontweight='bold')
    ax2.set_title(f'Nodos Explorados por A* ({obstacle_percentage} obstáculos)', 
                  fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    ax2.legend(fontsize=11)
    ax2.set_xlim(15, 155)
else:
    # Si no hay datos de nodos explorados, mostrar escala logarítmica de tiempo
    ax2.errorbar(grid_sizes, avg_times, yerr=std_devs, fmt='s-', 
                 color='#ad0000', ecolor='#999999', elinewidth=1.5, markersize=8,
                 capsize=5, capthick=1.5, label='A* (media ± desv. típica)')
    ax2.set_xlabel('Tamaño del Grid (n × n)', fontsize=12, fontweight='bold')
    ax2.set_ylabel('Tiempo promedio (ms) - Escala logarítmica', fontsize=12, fontweight='bold')
    ax2.set_title(f'Rendimiento A* - Escala Log ({obstacle_percentage} obstáculos)', 
                  fontsize=14, fontweight='bold')
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3, which='both')
    ax2.legend(fontsize=11)
    ax2.set_xlim(15, 155)

plt.tight_layout()
plt.savefig('benchmark_plot.png', dpi=150, bbox_inches='tight')
print("✓ Gráfica guardada: benchmark_plot.png")

# Crear una gráfica adicional con más análisis
fig2, ax3 = plt.subplots(figsize=(12, 7))

# Gráfica con más detalles
colors = np.linspace(0.3, 0.9, len(grid_sizes))
scatter = ax3.scatter(grid_sizes, avg_times, c=colors, cmap='viridis', 
                     s=200, alpha=0.7, edgecolors='black', linewidth=1.5)

# Añadir barras de error
for i, (x, y, err) in enumerate(zip(grid_sizes, avg_times, std_devs)):
    ax3.plot([x, x], [y - err, y + err], 'k-', linewidth=1.5, alpha=0.6)
    ax3.plot([x - 1, x + 1], [y - err, y - err], 'k-', linewidth=1, alpha=0.6)
    ax3.plot([x - 1, x + 1], [y + err, y + err], 'k-', linewidth=1, alpha=0.6)

# Línea de tendencia
z = np.polyfit(grid_sizes, avg_times, 3)
p = np.poly1d(z)
x_smooth = np.linspace(min(grid_sizes), max(grid_sizes), 100)
ax3.plot(x_smooth, p(x_smooth), '--', color='red', linewidth=2, alpha=0.7, label='Polinomio ajuste (grado 3)')

ax3.set_xlabel('Tamaño del Grid (n × n)', fontsize=13, fontweight='bold')
ax3.set_ylabel('Tiempo promedio (ms)', fontsize=13, fontweight='bold')
ax3.set_title(f'Análisis Detallado: Rendimiento de A* ({obstacle_percentage} obstáculos)', 
              fontsize=15, fontweight='bold')
ax3.grid(True, alpha=0.4, linestyle='--')
ax3.legend(fontsize=11, loc='upper left')
ax3.set_xlim(15, 155)

cbar = plt.colorbar(scatter, ax=ax3)
cbar.set_label('Progresión de tamaño', fontsize=11, fontweight='bold')

plt.tight_layout()
plt.savefig('benchmark_plot_detailed.png', dpi=150, bbox_inches='tight')
print("✓ Gráfica detallada guardada: benchmark_plot_detailed.png")

# Crear gráfica de nodos explorados si están disponibles
if avg_explored:
    fig3, ax4 = plt.subplots(figsize=(12, 7))
    
    colors = np.linspace(0.3, 0.9, len(grid_sizes))
    scatter = ax4.scatter(grid_sizes, avg_explored, c=colors, cmap='plasma', 
                         s=200, alpha=0.7, edgecolors='black', linewidth=1.5)
    
    # Añadir barras de error
    for i, (x, y, err) in enumerate(zip(grid_sizes, avg_explored, std_devs_explored)):
        ax4.plot([x, x], [y - err, y + err], 'k-', linewidth=1.5, alpha=0.6)
        ax4.plot([x - 1, x + 1], [y - err, y - err], 'k-', linewidth=1, alpha=0.6)
        ax4.plot([x - 1, x + 1], [y + err, y + err], 'k-', linewidth=1, alpha=0.6)
    
    # Línea de tendencia
    z = np.polyfit(grid_sizes, avg_explored, 2)
    p = np.poly1d(z)
    x_smooth = np.linspace(min(grid_sizes), max(grid_sizes), 100)
    ax4.plot(x_smooth, p(x_smooth), '--', color='red', linewidth=2, alpha=0.7, label='Ajuste polinómico (grado 2)')
    
    ax4.set_xlabel('Tamaño del Grid (n × n)', fontsize=13, fontweight='bold')
    ax4.set_ylabel('Nodos explorados', fontsize=13, fontweight='bold')
    ax4.set_title(f'Análisis: Nodos Explorados por A* ({obstacle_percentage} obstáculos)', 
                  fontsize=15, fontweight='bold')
    ax4.grid(True, alpha=0.4, linestyle='--')
    ax4.legend(fontsize=11, loc='upper left')
    ax4.set_xlim(15, 155)
    
    cbar = plt.colorbar(scatter, ax=ax4)
    cbar.set_label('Progresión de tamaño', fontsize=11, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('benchmark_plot_explored_nodes.png', dpi=150, bbox_inches='tight')
    print("✓ Gráfica de nodos explorados guardada: benchmark_plot_explored_nodes.png")

# Mostrar estadísticas
print("\n" + "="*50)
print("ESTADÍSTICAS DEL BENCHMARK")
print("="*50)
print(f"Tamaños evaluados: {len(grid_sizes)}")
print(f"Rango: {min(grid_sizes)}×{min(grid_sizes)} a {max(grid_sizes)}×{max(grid_sizes)}")
print(f"Porcentaje de obstáculos: {obstacle_percentage}")
print(f"\nTiempo promedio: {np.mean(avg_times):.4f} ms")
print(f"Tiempo mínimo: {np.min(avg_times):.4f} ms (Grid {grid_sizes[np.argmin(avg_times)]}×{grid_sizes[np.argmin(avg_times)]})")
print(f"Tiempo máximo: {np.max(avg_times):.4f} ms (Grid {grid_sizes[np.argmax(avg_times)]}×{grid_sizes[np.argmax(avg_times)]})")
print(f"Desviación típica promedio: {np.mean(std_devs):.4f} ms")

if avg_explored:
    print(f"\nNodos explorados promedio: {np.mean(avg_explored):.0f}")
    print(f"Nodos mín. explorados: {np.min(avg_explored):.0f} (Grid {grid_sizes[np.argmin(avg_explored)]}×{grid_sizes[np.argmin(avg_explored)]})")
    print(f"Nodos máx. explorados: {np.max(avg_explored):.0f} (Grid {grid_sizes[np.argmax(avg_explored)]}×{grid_sizes[np.argmax(avg_explored)]})")

print("="*50)

plt.show()
