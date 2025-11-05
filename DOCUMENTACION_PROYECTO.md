# Documentación del Proyecto - Arkanoid en MIPS Assembly

## Índice

1. [Descripción General](#descripción-general)
2. [Arquitectura de Software](#arquitectura-de-software)
3. [Sistema de Buffers](#sistema-de-buffers)
4. [Sistema de Sprites](#sistema-de-sprites)
5. [Módulos y Funciones](#módulos-y-funciones)
6. [Flujo de Ejecución](#flujo-de-ejecución)
7. [Estructuras de Datos](#estructuras-de-datos)

---

## Descripción General

Este proyecto es una implementación del clásico juego **Breakout** (Arkanoid) desarrollado en **MIPS Assembly**. El juego utiliza un sistema de doble buffer para manejar gráficos y colisiones de manera eficiente, con sprites detallados para todos los elementos visuales.

### Características Principales

- Resolución: 256x256 píxeles
- 60 bloques destructibles organizados en 6 filas
- Sistema de vidas (3 vidas)
- Sistema de puntuación
- Física de rebote avanzada con ángulos variables
- Detección de colisiones mediante matriz dedicada
- **Sprites pixelados de alta calidad** para paleta, pelota y bloques
- **Sistema de renderizado basado en sprites** con transparencia

---

## Arquitectura de Software

El proyecto sigue una arquitectura modular dividida en capas funcionales:

```
┌─────────────────────────────────────────┐
│           MAIN LOOP (main.asm)          │
│  - Inicialización                       │
│  - Bucle principal del juego            │
└──────────────┬──────────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
┌───▼────────┐    ┌──────▼──────┐
│  DISPLAY   │    │    LOGIC    │
│  (Gráficos)│    │  (Física)   │
└───┬────────┘    └──────┬──────┘
    │                    │
┌───▼────────┐    ┌──────▼──────────┐
│  - blocks  │    │  - physics      │
│  - graphics│    │  - collisions   │
└────────────┘    │  - collision_   │
                  │    matrix       │
                  └─────────────────┘
         ┌────────────┐
         │   DATA     │
         │  (Datos)   │
         └────────────┘
         │  - game_data    │
         │  - messages     │
         │  - objects_id   │
         │  - sprites/     │
         │    - paddle     │
         │    - blocks     │
         │    - ball       │
         └─────────────────┘
```

### Módulos del Sistema

#### 1. **Data (Datos)**

Contiene todas las constantes, variables, configuraciones y **sprites del juego**.

#### 2. **Display (Visualización)**

Maneja todo lo relacionado con el renderizado gráfico en el buffer de video, incluyendo la **renderización de sprites**.

#### 3. **Input (Entrada)**

Procesa las entradas del teclado del usuario.

#### 4. **Logic (Lógica)**

Implementa la física del juego, detección de colisiones y matriz de colisiones.

---

## Sistema de Buffers

El proyecto utiliza **dos buffers independientes** para optimizar el rendimiento y separar responsabilidades:

### Buffer 1: Buffer de Video (Display Address)

- **Dirección**: `0x10010000`
- **Tamaño**: 256×256 píxeles × 4 bytes = 262,144 bytes
- **Propósito**: Renderizado gráfico visible para el usuario

**Características:**

- Almacena colores en formato RGB (4 bytes por píxel)
- Actualizado constantemente para mostrar el estado visual del juego
- Contiene: paleta, pelota, bloques, fondo
- **Renderiza sprites píxel por píxel con soporte de transparencia**

**Cálculo de offset:**

```assembly
offset = (y * 256 + x) * 4 + displayAddress
```

### Buffer 2: Buffer de Colisiones (Collision Matrix)

- **Dirección**: `0x10050000`
- **Tamaño**: 256×256 bytes = 65,536 bytes
- **Propósito**: Detección de colisiones mediante IDs de objetos

**Características:**

- Cada píxel almacena un byte con el ID del objeto presente
- No se renderiza visualmente
- Permite detección O(1) de colisiones
- IDs disponibles: 0-255

**Cálculo de offset:**

```assembly
offset = (y * 256 + x) + collisionMatrix
```

### Ventajas del Sistema de Doble Buffer

| Aspecto | Ventaja |
|---------|---------|
| **Rendimiento** | Detección de colisiones en tiempo constante O(1) |
| **Separación de Responsabilidades** | Gráficos y lógica independientes |
| **Escalabilidad** | Fácil agregar nuevos tipos de objetos |
| **Debugging** | Problemas gráficos no afectan la lógica de colisiones |
| **Calidad Visual** | Sprites detallados sin impactar la lógica del juego |

---

## Sistema de Sprites

El juego utiliza un sistema avanzado de sprites que permite renderizar gráficos pixelados de alta calidad para todos los elementos del juego.

### Tipos de Sprites

#### 1. **Sprite de Pelota** (`ball_sprite.asm`)

- **Dimensiones**: 6×6 píxeles
- **Formato**: Array de words (4 bytes por píxel) en formato RGB
- **Características**:
  - Diseño esférico con sombreado
  - Degradados en escala de grises para efecto 3D
  - Bordes suavizados con píxeles de transición
  - Negro (#000000) usado como color transparente

**Estructura del sprite:**

```assembly
ball_sprite: .word
    # Fila 1
    0x000000, 0x848484, 0x848484, 0x848484, 0x848484, 0x000000,
    # Fila 2
    0x848484, 0xdcdcdc, 0xebebeb, 0xebebeb, 0xdcdcdc, 0x848484,
    # ... (6 filas totales)
```

**Paleta de colores:**

- `0x000000`: Transparente (negro)
- `0x707070`: Sombra oscura
- `0x848484`: Sombra media
- `0xa4a4a4` a `0xebebeb`: Gradientes de luz

#### 2. **Sprite de Paleta** (`paddle_sprites.asm`)

- **Dimensiones**: 35×9 píxeles (ajustado desde 35×22 original)
- **Formato**: Array de words con degradados azules
- **Características**:
  - Diseño con profundidad usando gradientes
  - Colores azules océano (#000537 a #0017ff)
  - Bordes definidos con transparencia
  - Forma aerodinámica

**Procesamiento del sprite:**

- **Original**: 35×22 píxeles (770 píxeles)
- **Filas eliminadas**: Primeras 13 filas y últimas 13 filas
- **Resultado final**: 35×9 píxeles (315 píxeles)
- **Motivo**: Optimizar tamaño y mejorar hitbox

**Paleta de colores:**

- `0x000000`: Transparente
- `0x000537`: Azul muy oscuro (bordes)
- `0x00095d`: Azul oscuro
- `0x000a6c`: Azul medio-oscuro
- `0x000e9b`: Azul medio
- `0x0010b5` a `0x0017ff`: Degradados azul brillante (centro)

#### 3. **Sprites de Bloques** (`block_sprites.asm`)

- **Dimensiones**: 20×8 píxeles cada bloque
- **Cantidad**: 7 variaciones de color
- **Formato**: Arrays individuales por color con efectos de luz

**Tipos de bloques disponibles:**

##### Bloque Púrpura (`purple_block_sprite`)

- Colores: `#430635` (oscuro) a `#d12ec1` (brillante)
- Uso: Fila 0 (OBJ_BLOCK_RED = 1)

##### Bloque Rojo (`red_block_sprite`)

- Colores: `#4a0000` (oscuro) a `#e90000` (brillante)
- Uso: Fila 4 (OBJ_BLOCK_MAGENTA = 5)

##### Bloque Amarillo (`yellow_block_sprite`)

- Colores: `#e0a400` (oscuro) a `#fff642` (brillante)
- Uso: Fila 1 (OBJ_BLOCK_YELLOW = 2)

##### Bloque Verde (`green_block_sprite`)

- Colores: `#006e14` (oscuro) a `#00ff2f` (brillante)
- Uso: Fila 3 (OBJ_BLOCK_GREEN = 4)

##### Bloque Azul/Cyan (`blue_block_sprite`)

- Colores: `#0c5954` (oscuro) a `#3bd3c9` (brillante)
- Uso: Fila 2 (OBJ_BLOCK_BLUE = 3)

##### Bloque Blanco (`white_block_sprite`)

- Colores: `#7b7b7b` (gris) a `#ffffff` (blanco)
- Uso: Fila 5 (OBJ_BLOCK_WHITE = 6)

##### Bloque Naranja (`orange_block_sprite`)

- Colores: `#9f4a00` (oscuro) a `#ffff40` (brillante)
- Uso: Bloques especiales/power-ups

**Estructura de un bloque:**

```assembly
purple_block_sprite: .word
    # Fila 1 (borde superior)
    0x000000, 0x750b5e, ..., 0x000000,
    # Filas 2-7 (cuerpo con degradados)
    0x590747, 0xbb31ae, 0xd12ec1, ...,
    # Fila 8 (borde inferior)
    0x000000, 0x430635, ..., 0x000000
```

**Técnica de sombreado:**

- **Borde exterior**: Negro transparente (#000000)
- **Borde oscuro**: Tono base oscuro
- **Degradado central**: 3-4 tonos del color principal
- **Highlight**: Tono más brillante en el centro-superior
- **Sombra inferior**: Tono medio-oscuro

#### 4. **Tabla de Sprites de Bloques**

Permite acceso eficiente a los sprites según el ID del bloque:

```assembly
block_sprites_table: .word
    white_block_sprite,     # ID 1
    yellow_block_sprite,    # ID 2
    blue_block_sprite,      # ID 3
    green_block_sprite,     # ID 4
    red_block_sprite,       # ID 5
    purple_block_sprite,    # ID 6
    red_block_sprite,       # ID 7 (armored)
    yellow_block_sprite,    # ID 8 (armored)
    blue_block_sprite,      # ID 9 (armored)
    green_block_sprite,     # ID 10 (armored)
    orange_block_sprite,    # ID 11 (armored)
    white_block_sprite,     # ID 12 (armored)
    purple_block_sprite     # ID 13 (indestructible)
```

### Sistema de Renderizado de Sprites

#### Algoritmo de Dibujo

El renderizado de sprites sigue este proceso:

1. **Cargar dirección base** del sprite
2. **Iterar sobre cada píxel** (y × ancho + x)
3. **Leer color** del array del sprite
4. **Verificar transparencia** (si color == 0x000000, saltar)
5. **Calcular offset** en buffer de video: `(y * 256 + x) * 4`
6. **Escribir color** en el buffer

**Pseudocódigo:**

```
Para cada fila Y del sprite (0 a alto-1):
    Para cada columna X del sprite (0 a ancho-1):
        color = sprite[Y * ancho + X]
        Si color != 0x000000:  # No transparente
            screen_x = posX + X
            screen_y = posY + Y
            offset = (screen_y * 256 + screen_x) * 4
            displayBuffer[offset] = color
```

#### Ventajas del Sistema de Sprites

| Característica | Beneficio |
|---------------|-----------|
| **Transparencia** | Negro (#000000) permite bordes suaves |
| **Modularidad** | Fácil cambiar diseños sin tocar lógica |
| **Calidad Visual** | Degradados y sombreados profesionales |
| **Reutilización** | Mismos sprites para bloques normales y blindados |
| **Optimización** | Sprites pequeños (6×6, 20×8, 35×9) minimizan memoria |

---

## Módulos y Funciones

### 1. Data Module (`data/`)

#### `game_data.asm`

Define todas las variables y constantes del juego.

**Variables Principales:**

```assembly
displayAddress:    .word 0x10010000  # Dirección del buffer de video
collisionMatrix:   .word 0x10050000  # Dirección del buffer de colisiones
screenWidth:       .word 256          # Ancho de pantalla
screenHeight:      .word 256          # Alto de pantalla
```

**Colores:**

- `bgColor`: Negro (0x00000000)
- `paddleColor`: Blanco (0x00FFFFFF) - **Ya no se usa, reemplazado por sprite**
- `ballColor`: Rojo (0x00FF0000) - **Ya no se usa, reemplazado por sprite**
- `blockColor1-4`: Magenta, Cyan, Amarillo, Verde - **Ya no se usan, reemplazados por sprites**

**Configuración de la Paleta:**

- Posición inicial: (110, 240)
- **Tamaño**: 35×9 píxeles (desde sprite)
- Velocidad: 4 píxeles/frame

**Configuración de la Pelota:**

- Posición inicial: (128, 128)
- **Tamaño**: 6×6 píxeles (desde sprite)
- Velocidad inicial: (1, -1)

**Configuración de Bloques:**

- **Tamaño**: 20×8 píxeles (desde sprites)
- Matriz: 10 columnas × 6 filas = 60 bloques
- Posición inicial: (28, 30)

#### `messages.asm`

Contiene los mensajes de texto del juego.

**Mensajes:**

- `msgGameOver`: "=== GAME OVER ==="
- `msgWin`: "=== VICTORIA ==="
- `msgScore`: "Puntuacion final: "
- `msgLives`: "Vidas restantes: "

#### `objects_id.asm`

Define los identificadores únicos para cada tipo de objeto en la matriz de colisiones.

**IDs de Objetos:**

```assembly
OBJ_EMPTY:              0   # Espacio vacío
OBJ_BLOCK_RED:          1   # Bloque rojo normal
OBJ_BLOCK_YELLOW:       2   # Bloque amarillo normal
OBJ_BLOCK_BLUE:         3   # Bloque azul normal
OBJ_BLOCK_GREEN:        4   # Bloque verde normal
OBJ_BLOCK_MAGENTA:      5   # Bloque magenta normal
OBJ_BLOCK_WHITE:        6   # Bloque blanco normal
OBJ_BALL:              14   # Pelota
OBJ_PADDLE:            15   # Paleta
OBJ_WALL:              20   # Paredes
```

#### `sprites/` (Nuevo - Submódulo de Sprites)

##### `ball_sprite.asm`

Define el sprite de la pelota con efecto 3D.

**Estructura:**

- Array de 36 words (6×6 píxeles)
- Formato RGB de 4 bytes por píxel
- Transparencia mediante negro (#000000)

##### `paddle_sprites.asm`

Define el sprite de la paleta con degradados azules.

**Estructura:**

- Array de 315 words (35×9 píxeles)
- Colores azules con gradiente del borde al centro
- Procesado desde un sprite original de 35×22 píxeles

**Nota importante:** Se eliminaron 13 filas superiores e inferiores para optimización.

##### `block_sprites.asm`

Define 7 sprites de bloques de diferentes colores.

**Estructura por sprite:**

- Array de 160 words (20×8 píxeles)
- Degradados de oscuro (bordes) a brillante (centro)
- Borde negro transparente

**Tabla de acceso:**

- `block_sprites_table`: Array de direcciones para acceso O(1)

---

### 2. Display Module (`display/`)

#### `graphics.asm`

Funciones de renderizado rápido en el buffer de video con soporte de sprites.

##### `drawPaddleFast`

**Propósito**: Dibuja la paleta usando su sprite pixelado.

**Algoritmo:**

1. Carga sprite desde `paddle_sprite`
2. Itera sobre 35×9 píxeles
3. Para cada píxel:
   - Lee color del sprite
   - Si no es negro (transparente), dibuja en pantalla
4. Calcula offset: `(y * 256 + x) * 4`

**Optimizaciones:**

- No usa pila (función hoja)
- Salto condicional para píxeles transparentes
- Cálculo de offset optimizado con shifts

**Complejidad**: O(315) = O(ancho × alto)

##### `clearPaddleFast`

**Propósito**: Borra la paleta del buffer de video.

**Funcionamiento**:

- Similar a `drawPaddleFast` pero pinta todo con `bgColor`
- No verifica transparencia (borra todo el rectángulo 35×9)

##### `drawBallFast`

**Propósito**: Dibuja la pelota usando su sprite con efecto 3D.

**Algoritmo:**

1. Carga sprite desde `ball_sprite`
2. Itera sobre 6×6 píxeles
3. Para cada píxel:
   - Lee color del sprite: `sprite[(y * 6 + x) * 4]`
   - Si no es negro (#000000), dibuja
4. Aplica sombreado según el sprite

**Características especiales:**

- Efecto esférico mediante degradados
- Bordes suavizados con píxeles de transición
- Soporte de transparencia

**Complejidad**: O(36) = O(6 × 6)

##### `clearBallFast`

**Propósito**: Borra la pelota del buffer de video.

**Funcionamiento**:

- Recorre área de 6×6 píxeles
- Pinta todo con `bgColor`

#### `blocks.asm`

Funciones especializadas para el manejo de bloques con sprites.

##### `drawAllBlocks`

**Propósito**: Dibuja todos los bloques activos al inicio del juego usando sprites.

**Algoritmo:**

```
Para cada fila (0 a 5):
    Para cada columna (0 a 9):
        Si blocks[fila][columna] == 1:
            drawBlockWithSprite(columna, fila)
```

**Cambio importante**: Ahora llama a `drawBlockWithSprite` en lugar de dibujar rectángulos sólidos.

**Complejidad**: O(filas × columnas) = O(60)

##### `drawBlockWithSprite`

**Propósito**: Dibuja un bloque individual usando su sprite correspondiente.

**Parámetros:**

- `$a0`: Columna (0-9)
- `$a1`: Fila (0-5)

**Algoritmo:**

1. Calcula posición X: `blockStartX + (columna * 20)`
2. Calcula posición Y: `blockStartY + (fila * 8)`
3. Obtiene ID del bloque según fila: `getBlockIDFromRow(fila)`
4. Llama a `drawBlockSprite(x, y, blockID)`

**Asignación de colores por fila:**

- Fila 0: Blanco (ID 1)
- Fila 1: Amarillo (ID 2)
- Fila 2: Azul/Cyan (ID 3)
- Fila 3: Verde (ID 4)
- Fila 4: Rojo (ID 5)
- Fila 5: Púrpura (ID 6)

##### `drawBlockSprite`

**Propósito**: Renderiza un sprite de bloque en una posición específica.

**Parámetros:**

- `$a0`: PosX
- `$a1`: PosY
- `$a2`: BlockID (1-13)

**Algoritmo:**

1. **Obtener sprite**: Accede a `block_sprites_table` con `(blockID - 1) * 4`
2. **Cargar dirección**: Lee dirección del sprite correspondiente
3. **Renderizar píxeles**:

   ```
   Para Y = 0 hasta 7:
       Para X = 0 hasta 19:
           color = sprite[(Y * 20 + X) * 4]
           Si color != 0x000000:  # No transparente
               pantalla[(posY+Y) * 256 + (posX+X)] = color
   ```

**Optimizaciones:**

- Salto de píxeles transparentes
- Acceso directo a tabla de sprites (O(1))
- Sin verificación de límites (bloques siempre en área válida)

**Complejidad**: O(160) = O(20 × 8)

##### `eraseBlock`

**Propósito**: Borra un bloque específico del buffer de video.

**Parámetros:**

- `$a0`: Columna del bloque
- `$a1`: Fila del bloque

**Funcionamiento**:

- Calcula posición
- Pinta rectángulo 20×8 con `bgColor`

##### `getBlockIDFromRow`

**Propósito**: Determina el ID de bloque según la fila.

**Parámetros:**

- `$a0`: Fila (0-5)

**Retorno:**

- `$v0`: ID del bloque (1-6)

**Mapeo:**

```assembly
Fila 0 → ID 1 (Blanco)
Fila 1 → ID 2 (Amarillo)
Fila 2 → ID 3 (Azul)
Fila 3 → ID 4 (Verde)
Fila 4 → ID 5 (Rojo/Naranja)
Fila 5 → ID 6 (Púrpura)
```

##### `drawSpecificBlock`

**Propósito**: Dibuja un bloque en cualquier posición (útil para power-ups).

**Parámetros:**

- `$a0`: PosX
- `$a1`: PosY
- `$a2`: BlockID

**Uso**: Power-ups, efectos especiales, bloques dinámicos.

---

### 3. Input Module (`input/`)

#### `keyboard.asm`

##### `checkInput`

**Propósito**: Lee la entrada del teclado y mueve la paleta horizontalmente.

**Teclas soportadas:**

- `'a'` o `'A'`: Mover izquierda
- `'d'` o `'D'`: Mover derecha

**Algoritmo:**

1. Verifica si hay tecla presionada (MMIO 0xFFFF0000)
2. Lee el código ASCII de la tecla (MMIO 0xFFFF0004)
3. Compara con 'a', 'A', 'd', 'D'
4. Actualiza `paddleX` según la tecla
5. Aplica límites para evitar salirse de pantalla

**Límites de movimiento:**

- Mínimo X: 0
- Máximo X: `256 - 35 = 221` (ajustado al ancho del sprite de la paleta)

**Velocidad de movimiento**: `paddleSpeed = 4` píxeles por frame

---

### 4. Logic Module (`logic/`)

#### `collision_matrix.asm`

Gestiona la matriz de colisiones en memoria.

##### `initCollisionMatrix`

**Propósito**: Inicializa el buffer de colisiones limpiándolo y registrando objetos estáticos.

**Algoritmo:**

1. **Limpia toda la matriz** (65,536 bytes a 0)
2. **Dibuja paredes laterales** (ID 20):
   - Columna izquierda (x=0-1)
   - Columna derecha (x=254-255)
3. **Dibuja techo** (ID 20):
   - Fila superior (y=0-1)
4. **Registra bloques** (IDs 1-60):
   - Llama a `registerAllBlocksInMatrix`

**Complejidad**: O(n) donde n = 65,536

##### `registerAllBlocksInMatrix`

**Propósito**: Registra todos los bloques en la matriz de colisiones con sus IDs correctos.

**Algoritmo:**

```
Para cada fila (0 a 5):
    Para cada columna (0 a 9):
        Si blocks[fila][columna] == 1:
            blockID = getBlockIDFromRow(fila)
            fillRectInMatrix(x, y, 20, 8, blockID)
```

**Importante**: Usa el sistema de IDs por color (1-6), no IDs únicos por bloque.

##### `getBlockIDFromRow`

**Propósito**: Asigna ID de sprite según la fila del bloque.

**Retorno:**

- Fila 0 → ID 1 (Blanco)
- Fila 1 → ID 2 (Amarillo)
- Fila 2 → ID 3 (Azul/Cyan)
- Fila 3 → ID 4 (Verde)
- Fila 4 → ID 5 (Rojo/Naranja)
- Fila 5 → ID 6 (Púrpura)

##### `fillRectInMatrix`

**Propósito**: Rellena un rectángulo en la matriz de colisiones con un ID específico.

**Parámetros:**

- `$a0`: X inicial
- `$a1`: Y inicial
- `$a2`: Ancho
- `$a3`: Alto
- `$t0`: ID del objeto

**Algoritmo:**

1. Itera sobre cada píxel del rectángulo
2. Calcula offset: `(y * 256 + x) + collisionMatrix`
3. Escribe el byte del ID en esa posición

**Uso**: Registrar objetos sólidos (bloques, paleta, pelota) en el buffer de colisiones

##### `updatePaddleInMatrix`

**Propósito**: Actualiza la posición de la paleta en la matriz de colisiones.

**Algoritmo:**

1. **Limpia toda el área posible de la paleta** (y=240-248, x=0-255)
2. **Registra nueva posición**:
   - Área: 35×9 píxeles (tamaño del sprite)
   - ID: 15 (OBJ_PADDLE)

**Optimización**: Limpia área completa para evitar rastros visuales.

##### `updateBallInMatrix`

**Propósito**: Actualiza la posición de la pelota en la matriz.

**Algoritmo:**

1. Limpia área anterior: `clearPreviousBallPosition`
2. Registra nueva área: 6×6 píxeles con ID 14

##### `clearPreviousBallPosition`

**Propósito**: Borra el área anterior de la pelota calculando dónde estaba.

**Cálculo posición anterior:**

```
X_anterior = ballX - ballVelX
Y_anterior = ballY - ballVelY
```

**Área a limpiar**: 6×6 píxeles (tamaño del sprite de la pelota)

#### `collisions.asm`

Detecta colisiones consultando la matriz.

##### `checkCollision`

**Propósito**: Verifica si hay colisión en una posición específica.

**Parámetros:**

- `$a0`: Coordenada X
- `$a1`: Coordenada Y

**Retorno:**

- `$v0`: 1 si hay colisión, 0 si está vacío
- `$v1`: ID del objeto colisionado

**Algoritmo:**

1. Calcula offset: `(y * 256 + x) + collisionMatrix`
2. Lee el byte en esa posición
3. Si byte != 0: colisión detectada
4. Retorna ID del objeto

**Complejidad**: O(1) - acceso directo a memoria

##### `checkCollisionsOnTrajectory`

**Propósito**: Verifica colisiones en los próximos 3 puntos de la trayectoria.

**Algoritmo:**

1. Verifica `(ballX + velX, ballY)` - movimiento horizontal
2. Verifica `(ballX, ballY + velY)` - movimiento vertical
3. Verifica `(ballX + velX, ballY + velY)` - movimiento diagonal

**Retorno:**

- `$v0`: Tipo de colisión (0=ninguna, 1=pared, 2=paleta, 3=bloque)
- `$v1`: ID del objeto

**Ventaja**: Detecta colisiones antes de que ocurran, evitando que la pelota se "trabe".

#### `physics.asm`

Implementa el movimiento y física de la pelota.

##### `moveBall`

**Propósito**: Mueve la pelota y gestiona todas las colisiones.

**Algoritmo principal:**

```
1. Calcular nueva posición (ballX + ballVelX, ballY + ballVelY)
2. Verificar colisiones en 4 esquinas de la pelota (6x6 píxeles)
3. Detectar tipo de colisión:
   - Piso (Y >= 255): Perder vida
   - Paredes/Techo (ID 20): Rebotar
   - Paleta (ID 15): Rebotar con ángulo
   - Bloques (ID 1-60): Rebotar y destruir
4. Aplicar rebote modificando velocidad
5. Mover pelota a nueva posición
6. Actualizar matriz de colisiones
```

**Puntos de colisión verificados:**

- Esquina superior izquierda: `(ballX, ballY)`
- Esquina superior derecha: `(ballX + 5, ballY)`
- Esquina inferior izquierda: `(ballX, ballY + 5)`
- Esquina inferior derecha: `(ballX + 5, ballY + 5)`

**Tipos de rebote:**

1. **Rebote horizontal**: Invierte `ballVelX`
2. **Rebote vertical**: Invierte `ballVelY`
3. **Rebote con paleta**: Invierte `ballVelY` + ajusta ángulo

##### `calculatePaddleBounceAngle`

**Propósito**: Calcula el ángulo de rebote según dónde golpea la pelota en la paleta.

**Sistema de zonas (paleta de 35px):**

```
|  Z1  |  Z2  |  Z3  |  Z4  |  Z5  |
|  7px |  7px |  7px |  7px |  7px |
| -2   | -1   |  0   |  +1  |  +2  | → ballVelX resultante
```

**Algoritmo:**

1. Calcula posición relativa: `ballX - paddleX`
2. Determina zona según posición (0-7, 7-14, 14-21, 21-28, 28-35)
3. Asigna velocidad X según zona

**Efecto:**

- **Zonas extremas**: Rebote más inclinado (±2)
- **Zona central**: Rebote recto (0)

##### `updateBallInMatrix`

**Propósito**: Actualiza la posición de la pelota en la matriz de colisiones.

**Algoritmo:**

1. Limpia área anterior (6×6): `clearPreviousBallPosition`
2. Registra nueva área (6×6): `fillRectInMatrix` con ID 14

##### `clearPreviousBallPosition`

**Propósito**: Borra el área anterior de la pelota en la matriz.

**Cálculo posición anterior:**

```
X_anterior = ballX - ballVelX
Y_anterior = ballY - ballVelY
```

**Algoritmo:**

1. Calcula coordenadas anteriores
2. Limpia área 6×6 con ID 0

##### `destroyBlockInMatrix`

**Propósito**: Destruye un bloque cuando la pelota lo golpea.

**Parámetros:**

- `$a0`: ID del bloque a destruir (1-60)

**Algoritmo:**

1. **Busca el bloque** en la matriz recorriendo 65,536 bytes
2. **Marca como vacío** (ID 0) todas las apariciones
3. **Actualiza contadores**:
   - `blocksRemaining--`
   - `score += 10`

**Complejidad**: O(n) donde n = 65,536 (búsqueda lineal)

**Optimización posible**: Mantener tabla de posiciones de bloques

##### `lostBall`

**Propósito**: Gestiona la pérdida de una vida cuando la pelota cae.

**Algoritmo:**

1. Decrementa vidas: `lives--`
2. Muestra mensaje con vidas restantes
3. Si `lives > 0`:
   - Llama a `respawn` para reiniciar
4. Si `lives == 0`:
   - Muestra "GAME OVER"
   - Muestra puntuación final
   - Termina el programa

##### `respawn`

**Propósito**: Reinicia la posición de la pelota después de perder una vida.

**Valores de reinicio:**

- `ballX = 128` (centro X)
- `ballY = 120` (centro-arriba Y)
- `ballVelX = 1`
- `ballVelY = -1` (hacia arriba)

**Pausa**: 1 segundo (1000ms) antes de continuar

---

### 5. Main Module

#### `main.asm`

Punto de entrada y bucle principal del juego.

##### `main`

**Propósito**: Inicializa el juego y entra en el bucle principal.

**Secuencia de inicialización:**

1. `initCollisionMatrix`: Prepara buffer de colisiones
2. `updatePaddleInMatrix`: Registra paleta inicial
3. `drawAllBlocks`: Dibuja bloques en pantalla
4. Entra en `mainLoop`

##### `mainLoop`

**Propósito**: Bucle principal del juego que se ejecuta cada frame.

**Secuencia de operaciones (cada frame):**

```
1. BORRAR GRÁFICOS ANTERIORES
   - clearPaddleFast
   - clearBallFast

2. PROCESAR ENTRADA
   - checkInput

3. ACTUALIZAR LÓGICA
   - updatePaddleInMatrix
   - moveBall (incluye detección de colisiones)

4. RENDERIZAR NUEVOS GRÁFICOS
   - drawPaddleFast
   - drawBallFast

5. VERIFICAR VICTORIA
   - Si blocksRemaining == 0 → gameWon

6. DELAY
   - Pausa de 5ms para control de frame rate
```

**Frame rate aproximado**: 200 FPS (5ms por frame)

##### `gameWon`

**Propósito**: Gestiona el final exitoso del juego.

**Acciones:**

1. Muestra mensaje "=== VICTORIA ==="
2. Termina el programa (syscall 10)

---

## Flujo de Ejecución

### Diagrama de Flujo Principal

```
┌─────────────┐
│    main     │
└──────┬──────┘
       │
       ├─► initCollisionMatrix
       ├─► updatePaddleInMatrix
       ├─► drawAllBlocks
       │
       ▼
┌─────────────────┐
│   mainLoop      │◄──┐
└──────┬──────────┘   │
       │               │
       ├─► clearPaddleFast    │
       ├─► clearBallFast      │
       ├─► checkInput         │
       ├─► updatePaddleInMatrix
       ├─► moveBall           │
       │   ├─► checkCollision │
       │   ├─► bounce logic   │
       │   └─► destroyBlock   │
       ├─► drawPaddleFast     │
       ├─► drawBallFast       │
       ├─► check victory      │
       └─► delay (5ms) ───────┘
```

### Flujo de Detección de Colisiones

```
moveBall
  │
  ├─► Calcular nueva posición
  │
  ├─► checkCollision (4 esquinas)
  │     │
  │     ├─► Leer matriz en (x, y)
  │     └─► Retornar ID del objeto
  │
  ├─► Analizar ID colisionado:
  │     ├─► ID 0 (vacío) → No hay colisión
  │     ├─► ID 20 (pared/techo) → Rebotar
  │     ├─► ID 15 (paleta) → Rebotar con ángulo
  │     ├─► ID 1-60 (bloque) → Destruir + Rebotar
  │     └─► Y >= 255 (piso) → lostBall
  │
  ├─► Aplicar física de rebote
  │
  ├─► Mover pelota
  │
  └─► updateBallInMatrix
```

---

## Estructuras de Datos

### 1. Matriz de Bloques

```assembly
blocks: .word 1,1,1,1,1,1,1,1,1,1  # Fila 0
        .word 1,1,1,1,1,1,1,1,1,1  # Fila 1
        .word 1,1,1,1,1,1,1,1,1,1  # Fila 2
        .word 1,1,1,1,1,1,1,1,1,1  # Fila 3
        .word 1,1,1,1,1,1,1,1,1,1  # Fila 4
        .word 1,1,1,1,1,1,1,1,1,1  # Fila 5
```

- **Tipo**: Array 2D de words (4 bytes)
- **Dimensiones**: 6 filas × 10 columnas = 60 elementos
- **Valores**: 1 = activo, 0 = destruido
- **Acceso**: `blocks[fila * 10 + columna]`

### 2. Buffer de Video (Display)

```
Dirección: 0x10010000
Tamaño: 256 × 256 × 4 bytes = 262,144 bytes
Formato: [RGBA] por píxel (4 bytes)
```

**Mapa de memoria:**

```
0x10010000 ┌──────────────────┐
           │  Píxel (0,0)     │ ← 4 bytes
           │  Píxel (1,0)     │
           │  ...             │
           │  Píxel (255,0)   │
           │  Píxel (0,1)     │
           │  ...             │
0x1004FFFC │  Píxel (255,255) │
           └──────────────────┘
```

### 3. Buffer de Colisiones (Collision Matrix)

```
Dirección: 0x10050000
Tamaño: 256 × 256 × 1 byte = 65,536 bytes
Formato: 1 byte por píxel (ID del objeto)
```

**Mapa de memoria:**

```
0x10050000 ┌──────────────────┐
           │  ID (0,0)        │ ← 1 byte
           │  ID (1,0)        │
           │  ...             │
           │  ID (255,0)      │
           │  ID (0,1)        │
           │  ...             │
0x1005FFFF │  ID (255,255)    │
           └──────────────────┘
```

**Distribución de IDs en la matriz:**

```
┌────────────────────────────────┐
│ 20 20 20 20 20 ... 20 20 20 20│ ← Techo (y=0)
│ 20  0  0  0  0 ...  0  0  0 20│ ← Paredes laterales
│ 20  0  1  1  1 ...  5  5  5 20│ ← Bloques (IDs 1-60)
│ 20  0 11 11 11 ... 15 15 15 20│
│ 20  0 21 21 21 ... 25 25 25 20│
│ 20  0  0  0  0 ...  0  0  0 20│
│ 20  0  0  0  0 ... 14 14 14 20│ ← Pelota (ID 14)
│ 20  0  0  0  0 ...  0  0  0 20│
│ 20  0 15 15 15 ... 15 15 15 20│ ← Paleta (ID 15)
│ 20  0  0  0  0 ...  0  0  0 20│ ← Zona inferior (sin piso)
└────────────────────────────────┘
```

---

## Optimizaciones Implementadas

### 1. **Funciones "Fast" sin Stack**

Las funciones de dibujo (`drawPaddleFast`, `clearPaddleFast`, etc.) no usan la pila, lo que reduce overhead.

### 2. **Detección de Colisiones O(1)**

Gracias a la matriz de colisiones, verificar colisión es una simple lectura de memoria.

### 3. **Actualización Diferencial**

Solo se borran y redibujan los elementos que se mueven (paleta y pelota), no toda la pantalla.

### 4. **Delay Mínimo**

Frame rate alto (5ms de delay) para movimiento fluido.

---

## Limitaciones y Posibles Mejoras

### Limitaciones Actuales

1. Solo un tipo de bloque (1 golpe)
2. Una sola pelota
3. Sin power-ups implementados
4. Sin niveles adicionales
5. Búsqueda lineal para destruir bloques (O(n))

### Mejoras Propuestas

1. **Tabla de hash de bloques**: Mejorar `destroyBlockInMatrix` a O(1)
2. **Bloques con más resistencia**: Usar IDs 7-13 (ya definidos)
3. **Power-ups**: Implementar IDs 16-18
4. **Múltiples pelotas**: Gestionar array de pelotas
5. **Sonido**: Agregar syscalls de audio en colisiones
6. **Niveles**: Cargar diferentes configuraciones de `blocks[]`

---

## Conclusión

Este proyecto demuestra una implementación eficiente de un juego clásico en ensamblador MIPS, utilizando técnicas avanzadas como:

- **Separación de buffers** para optimizar gráficos y lógica
- **Programación modular** para facilitar mantenimiento
- **Algoritmos eficientes** para detección de colisiones
- **Física realista** con sistema de rebote variable

El sistema de doble buffer (video + colisiones) es la clave de la arquitectura, permitiendo un rendimiento excelente mientras mantiene el código organizado y extensible.
