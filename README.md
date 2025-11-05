# arkanoid-assembly

Arkanoid implementado en Assembly MIPS para "Instalación y Reemplazo de Componentes Internos" de 6to año Informática del IPS

## Integrantes

- Bueno, Luciana Maylen
- Bravi, Juan Alberto
- Di Lella, Giuliana Camilo
- Mondino, Franco
- Novoa, Galo Cristian

## Instrucciones

- Abrir solo src/main.asm en MARS:
- Abrir Keyboard and Display MMIO Simulator y poner delay lenght en 1

- Abrir Bitmap Display, configuración:
  - Unit width y height: 2
  - Display width y height: 512
  - Base address for display: static data

- Conect to MIPS en ambos.

- Compilar y ejecutar.
- El paddle se controla ingresando A y D en el keyboard simulator.

En la terminal se pueden ver las vidas restantes y puntuación al final de la partida.

## Historial de versiones

### Versión 1

- Paleta en la parte inferior de la pantalla que se mueve de izquierda a derecha con las teclas A y D.
- Matriz de bloques destructibles.
- Pelota que rebota contra bordes y bloques destruyéndolos.

### Versión 2

- La pelota ahora puede rebotar en varios ángulos dependiendo de la parte de la paleta sobre la que rebote.
- Ahora se puede perder cuando la pelota toca la parte inferior de la pantalla y se pierden tres vidas (la cantidad de vidas restantes se imprime en la consola).
- Al final de la partida se imprime Game Over o Victoria en la consola, y los puntos obtenidos.

### Versión 3

- Sistema de buffer de colisiones implementado (separamos el calculo lógico de hitbox de la impresión en el buffer de video).
- Ajustamos el tamaño de los objetos a los sprites que pensamos meter a futuro.

### Versión 4

- Cargamos y metimos los sprites en el juego :D
