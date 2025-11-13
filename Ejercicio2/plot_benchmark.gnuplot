# Script de gnuplot para visualizar resultados de A*
set terminal png size 1200,800 enhanced font 'Arial,12'
set output 'benchmark_plot.png'

set title 'Rendimiento del Algoritmo A* (100 iteraciones por tamaño)' font 'Arial,16'
set xlabel 'Tamaño del Grid (n x n)' font 'Arial,14'
set ylabel 'Tiempo promedio (ms)' font 'Arial,14'

set grid
set key top left
set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5
set style line 2 lc rgb '#0060ad' lt 1 lw 1

# Configurar rangos
set xrange [15:155]
set yrange [0:*]

# Plotear con barras de error y línea
plot 'benchmark_data.txt' using 1:2:3 with errorbars ls 1 title 'A* (media ± desv. típica)', \
     'benchmark_data.txt' using 1:2 with lines ls 2 notitle
