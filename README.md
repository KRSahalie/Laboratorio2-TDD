
## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

[1] Features, 1., & Description, 3. (s/f). SNx4HC14 Hex Inverters with Schmitt-Trigger Inputs. Www.ti.com. https://www.ti.com/lit/ds/symlink/sn74hc14.pdf?ts=1709130609427&ref_url=https%253A%252F%252Fwww.google.com%252F

## 3. Desarrollo

## 3.1 Ejercicio 1. Uso del PLL IP-core
Su función principal es distribuir y estabilizar señales de reloj en un diseño digital. Sus características clave:
Entradas/Salidas:

Entradas:
-	clk_100MHz y clk_100MHz_1: Dos relojes de referencia de 100 MHz.
-	reset_rtl_0: Reset activo (a nivel bajo).

Salidas:
-	clk_out1_0: Reloj generado (frecuencia determinada por el módulo interno clock_0).
-	locked: Señal que indica estabilidad del reloj generado (1 = estable).

Funcionamiento interno:
-	Instancia el módulo clock_0_i, que probablemente contiene un PLL (Phase-Locked Loop) o MMCM (Mixed-Mode Clock Manager) para generar relojes con características específicas.
-	La directiva timescale 1 ps / 1 ps define la unidad de tiempo para simulaciones.

Aplicación típica:
-	Proporcionar relojes sincronizados y estables para otros módulos en diseños FPGA.
-	Gestionar domain crossing (cambios entre dominios de reloj).

#### 1. Módulo
```SystemVerilog
`timescale 1 ps / 1 ps

module clock_0_wrapper
   (clk_100MHz,
    clk_100MHz_1,
    clk_out1_0,
    locked,
    reset_rtl_0);
  input clk_100MHz;
  input clk_100MHz_1;
  output clk_out1_0;
  output locked;
  input reset_rtl_0;

  wire clk_100MHz;
  wire clk_100MHz_1;
  wire clk_out1_0;
  wire locked;
  wire reset_rtl_0;

  clock_0 clock_0_i
       (.clk_100MHz(clk_100MHz),
        .clk_100MHz_1(clk_100MHz_1),
        .clk_out1_0(clk_out1_0),
        .locked(locked),
        .reset_rtl_0(reset_rtl_0));
endmodule
```
#### 2. Criterios y restricciones de diseño
Diseño sincrónico robusto:

•	Usar un único flanco de reloj (ascendente o descendente) en todo el sistema para evitar inconsistencias temporales.
•	Registrar las salidas de cada módulo para garantizar estabilidad.
•	Sincronizar señales asincrónicas externas con circuitos de metaestabilidad.

Gestión de relojes:

•	Emplear bloques dedicados (MMCM/PLL) para distribución con baja distorsión y alta capacidad de fan-out.
•	Definir restricciones de periodo para cada reloj, cubriendo solo caminos entre elementos sincrónicos controlados por ese reloj.
•	Evitar divisores de reloj basados en lógica combinacional para prevenir desfases.

Restricciones temporales críticas:

•	Periodo mínimo: Calculado como Tcycle>TCO+Twd1+Tpd+Twd2+TSU+TmTcycle>TCO+Twd1+Tpd+Twd2+TSU+Tm.
•	Setup time (tsutsu): Tiempo mínimo de estabilidad de datos antes del flanco de reloj.
•	Hold time (thth): Tiempo mínimo de estabilidad posterior al flanco.

Regla 60/40:

•	60% del periodo asignado a retardo lógico y 40% a retardo de rutado para garantizar margen de seguridad. Si el retardo lógico supera el 60%, se recomienda rediseñar el módulo afectado.

#### 3. Testbench y Implementación en la FPGA
```SystemVerilog
`timescale 1ns / 1ps

module tb_clock_0;

// Declarar señales de prueba
reg clk_100MHz;
reg clk_100MHz_1;
reg reset_rtl_0;  // Señal de reset
wire clk_out1_0;  // La señal de salida de 10 MHz (generada por el PLL)
wire locked;      // Señal de "locked" del PLL
reg clk_10MHz_ref;  // Reloj de 10 MHz para comparación

// Instanciar el wrapper
clock_0_wrapper uut (
    .clk_100MHz(clk_100MHz),
    .clk_100MHz_1(clk_100MHz_1),
    .clk_out1_0(clk_out1_0),
    .reset_rtl_0(reset_rtl_0),
    .locked(locked)  // Asegúrate de conectar la señal "locked"
);

// Generar el reloj de entrada de 100 MHz
always begin
    #5 clk_100MHz = ~clk_100MHz;  // Reloj de 100 MHz
end

// Generar el segundo reloj de entrada (si es necesario)
always begin
    #5 clk_100MHz_1 = ~clk_100MHz_1;  // Reloj de 100 MHz adicional, si es necesario
end

// Generar el reloj de 10 MHz para comparación
always begin
    #50 clk_10MHz_ref = ~clk_10MHz_ref;  // Reloj de 10 MHz (10 veces más lento que 100 MHz)
end

// Establecer las condiciones iniciales
initial begin
    // Inicializar señales
    clk_100MHz = 0;
    clk_100MHz_1 = 0;
    clk_10MHz_ref = 0;  // Inicializar el reloj de 10 MHz
    reset_rtl_0 = 1;  // Activar el reset al principio

    // Desactivar el reset después de 10 ns
    #10 reset_rtl_0 = 0;

    // Esperar un tiempo para que el PLL se bloquee
    #500;  // Esperar 500 ns para ver el bloqueo

    // Verificar si el PLL está bloqueado
    if (locked == 1) begin
        $display("PLL bloqueado correctamente.");
    end else begin
        $display("PLL no bloqueado dentro del tiempo esperado.");
    end

    // Esperar un tiempo suficiente para observar varios ciclos de la salida de 10 MHz
    #10000;  // Esperar un tiempo mayor (10,000 ns) para observar más ciclos de 10 MHz

    // Terminar la simulación
    $finish;
end

// Verificar señales en la simulación
initial begin
    $monitor("Time = %t, locked = %b, clk_out1_0 = %b, clk_10MHz_ref = %b, clk_100MHz = %b, clk_100MHz_1 = %b, reset_rtl_0 = %b", 
              $time, locked, clk_out1_0, clk_10MHz_ref, clk_100MHz, clk_100MHz_1, reset_rtl_0);
end

endmodule
```

## Ejercicio 2: Diseño antirebotes y sincronizador
Para el diseño del antirebotres y sincronizador se procedio a crear un module debouncer mediante la yutilizacion de dos flip flop para eliminar los pulsos mo deseados, tambien se utilizo un contador para llevar la cuenta en de los cambion en el falco positivo de la senal habilitadora.

Se desea crear el programar el siguiente esquematico y a partir de este se cran los siguientes modulos para implementarlos en la FPGA.

<div align="center">
  <img src="https://raw.githubusercontent.com/KRSahalie/Laboratorio2-TDD/main/Imagenes/mi_ca/1.png">
</div>


#### 1. Encabezados de los  módulos
Se implementa una funcion Top para mostrar la salida de lka tarjeta mediante la utilizacion de los leds, tambien inicializa el reloj
Encabezado del modulo
```SystemVerilog
module top_module_debouncer(
    input     logic             clk,
    input     logic             bt1_i,
    input     logic             rst_i,
    output    logic    [7:0]    conta_o                         
    );
  
  logic clk_10MHz;  
  logic en_10kHz;
  logic signal;
```

Se crea un module_deboncer donse se realiza la conecxion de los flip flop para el sistema antirebote

```SystemVerilog
module modules_debouncer(
    input     logic    clk,
    input     logic    bt1_i,
    input     logic    rst_i,
    output    logic    signal_o
    );
    
    logic en_out;
    logic Q1,Q1_neg, Q2, Q2_neg;
    
    module_FFD ff1(
        .clk   (clk),
        .D     (bt1_i),
        .EN    (en_out),
        .Q     (Q1)
        );
        
    module_FFD ff2(
        .clk   (clk),
        .D     (Q1),
        .EN    (en_out),
        .Q     (Q2)
        );
    
    assign Q2_neg = ~Q2;    
    assign signal_o = Q1 & Q2_neg; 
        

    clock_enable clkEN(
        .Clk_10M (clk),
        .slow_clk_en (en_out) 
    );
    
       

endmodule 

    module clock_enable(input Clk_10M,output slow_clk_en);
    logic [26:0]counter=0;
    always @(posedge Clk_10M)
    begin
       counter <= (counter>=249999)?0:counter+1;
    end
    assign slow_clk_en = (counter == 249999)?1'b1:1'b0; 
endmodule
```
Tambien sde crea el module_contador_prueba el cual se impolementa para la llevar la cuenta en los cambios de la senal habilitadora.
Encabezado del modulo
```SystemVerilog
module module_contador_prueba(
    input logic         clk, 
    input logic         rst_n_i, 
    input logic         en_i, 
    output logic [7:0]  conta);
```

#### 2. Parámetros
Agregar parámetros en este formato.
- `WIDTH`: Parámetro que define el ancho del bus de datos en el multiplexor. Tiene un valor predeterminado de 8, pero en el test bench este toma valores de 4, 8 y 16.
#### 3. Entradas y salidas
Agregar en este formato.
- `clk`, `bt1_1`, `rst_i`: Entradas de datos al modulo top debouncer.
- `conta_o`: Salida del módulo.


#### 4. Testbench
Por Ultimo se implemento una testbench para poder realizar la simulacion de lo planteadop anteriormente

```SystemVerilog
module tb_modules_debouncer;
    logic           clk;
    logic           bt1_i;
    logic           rst_i;
    logic           signal_o;
    logic           CLK_100MHZ;
    logic           CLK_10MHZ;
    logic    [3:0]  cont2;
    
    
    initial begin
        CLK_100MHZ = 0;
        CLK_10MHZ  = 0;
        cont2      = 0; 
```
como resultado al implementar el testbenh obtuvimos lo siguiente

<div align="center">
  <img src="https://raw.githubusercontent.com/KRSahalie/Laboratorio2-TDD/main/Imagenes/mi_ca/resultadoTB.png">
</div>

## Ejercicio 3: Decodificador hex-to-7-segments

La solución al ejercicio 3 consiste en el uso de un decodificador binario a hexadecimal y su conversión a la visualización equivalente en siete segmentos (creado en el Laboratorio 1), pero que en lugar de utilizar switches para mapear datos, utiliza datos pseudoaleatorios. Esta implementación se realiza mediante la integración de cuatro Registros de Desplazamiento de Retroalimentación Lineal (LFSR) de 4 bits, concatenados en una unidad de entrada paralela-paralela (PIPO) de 16 bits. El objetivo principal es convertir secuencias binarias generadas por los LFSR en su representación hexadecimal y, a su vez, visualizar estas cifras en dispositivos de siete segmentos. 

## Módulos utilizados y descripción de su funcionamiento:
## A. Generación de datos con el módulo LSFR

El módulo LFSR (Registro de Desplazamiento de Retroalimentación Lineal) es una implementación de un LFSR que genera secuencias pseudoaleatorias de acuerdo con un polinomio de retroalimentación específico. Este módulo fue dado por el profesor del curso y solo se debía aprender a implementar. 

### 1. Encabezado
```SystemVerilog
module LFSR #(parameter NUM_BITS = 4) //Parametrización a 4 bits
  (
   input i_Clk,
   input i_Rst,
   input i_Enable,
 
   // Optional Seed Value
   input [NUM_BITS-1:0] i_Seed_Data,
 
   output [NUM_BITS-1:0] o_LFSR_Data,
   output o_LFSR_Done
   );
```
### 2. Señales
Las señales básicas del módulo y su funcionamiento son:

#### Señales de Entrada:
- **i_Clk:** Señal de reloj que controla el funcionamiento del LFSR.
- **i_Rst:** Señal de reset que restablece el estado del LFSR.
- **i_Enable:** Señal de habilitación que controla la generación de la secuencia pseudoaleatoria.
- **i_Seed_Data:** Valor opcional que establece el estado inicial del LFSR.


#### Señales de Salida:
- **o_LFSR_Data:** Secuencia pseudoaleatoria generada por el LFSR.
- **o_LFSR_Done:** Señal que indica cuando el LFSR ha completado una iteración completa de su secuencia.

### 3. Uso y criterios de diseño
El módulo LFSR se utiliza para generar datos que luego se ingresan en un registro. Se ha parametrizado con 4 bits para aumentar la aleatoriedad en la secuencia generada. El funcionamiento del módulo LFSR se comprende al analizar su semilla y su instanciación para la concatenación. La semilla (i_Seed_Data) establece el estado inicial del LFSR, y es importante para determinar la secuencia pseudoaleatoria generada. Al instanciar múltiples módulos LFSR en concatenación, se asegura una mayor complejidad en la secuencia generada, lo que aumenta la aleatoriedad de los datos.

Es importante destacar que este módulo trabaja en conjunto con el registro para procesar los datos generados. Además, se utilizan módulos de prueba específicos para la LFSR con el fin de simular su funcionamiento y verificar que efectivamente se están produciendo los datos esperados.

### 4. Testbench
Este testbench verifica el funcionamiento del módulo LFSR bajo diferentes condiciones de habilitación y deshabilitación, permitiendo la observación de la generación de datos y la activación de la señal w_LFSR_Done para confirmar que el LFSR ha completado una iteración completa de su secuencia. El testbench es una modificación del otorgado por el profesor. 

```SystemVerilog
module LFSR_TB ();
    parameter clock_cycle = 10;//periodo 10ns
    parameter half_cycle = clock_cycle/2;
    parameter delay_val=1;//1 ns delay de escritura
    
    reg Clk = 1'b0;
    reg Rst = 1'b0;
    reg r_Enable = 1'b0;
    wire [4-1:0] w_LFSR_Data;
    wire w_LFSR_Done;
    
    always @(*)
        #(half_cycle) Clk <= ~Clk; 
        
    task wait_clk(input integer num);
        repeat(num) begin
            @(posedge Clk); #(delay_val);
        end
    endtask
   
  LFSR_individual_test_top LFSR_inst
         (.i_Clk(Clk),
          .i_Rst(Rst),
          .i_Enable(r_Enable),
          .i_Seed_Data({4{1'b0}}), // Replication
          .o_LFSR_Data(w_LFSR_Data),
          .o_LFSR_Done(w_LFSR_Done)
          );
          
  initial begin 
    wait_clk(2);
    Rst=1;
    wait_clk(5);
    r_Enable=1;
    wait_clk(100);
    r_Enable=1;
    wait_clk(10);
    r_Enable=0;
    wait_clk(10);
    repeat(15) begin
        r_Enable=~r_Enable;
        wait_clk(1);
    end
    r_Enable=0;
    wait_clk(10);
    $finish;
  end
 
endmodule // LFSR_TB
```

La simulación se puede ver en la imagen siguiente: 

<div align="center">
  <img src="https://github.com/KRSahalie/Laboratorio2-TDD/blob/main/Ejercicio3/Imagenes/TB%20LSFR.png">
</div>

Los valores obtenidos son correctos y esperados, se comprueba la generación de datos con este paso. 

## B. Registro de entrada y salida paralela con write enable (WE) de 16 bits

Este módulo registra los datos de entrada cuando se activa la señal de escritura, y los mantiene hasta que se produce la siguiente escritura. Es un componente básico pero esencial en muchos sistemas digitales, utilizado para almacenar datos y sincronizar operaciones en circuitos digitales. Es simple, de 16 bits y toma los valores concatenados de las LFSR como entrada (se explica en módulo TOP). En el siguiente diagrama se muestra su funcionamiento, la entrada se representa con una D. 

<div align="center">
  <img src="https://github.com/KRSahalie/Laboratorio2-TDD/blob/main/Ejercicio3/Imagenes/imagen%202.jpg">
</div>

### 1. Encabezado
```SystemVerilog
module RPIPO_module(
  input wire clk,
  input wire we,
  input wire [15:0] data_in,
  output reg [15:0] data_out
);
```
### 2. Señales
Las señales básicas del módulo y su funcionamiento son:

#### Señales de Entrada:
- **clk:** Señal de reloj que sincroniza el funcionamiento del registro.
- **we:** Señal de escritura que indica cuándo se debe escribir en el registro.
- **data_in:** Datos de entrada que se escribirán en el registro.

#### Señales de Salida:
- **data_out:** Datos de salida del registro, que reflejan los datos de entrada una vez que se ha producido la escritura.

### 3. Uso y criterios de diseño
El módulo de Registro PIPO desempeña un papel crucial en el sistema, ya que actúa como un punto intermedio entre la generación de datos por parte de los LSFR y su visualización en el display. Esta funcionalidad es esencial para el funcionamiento del sistema, ya que permite pausar la transmisión de datos al desactivar la escritura (write enable), lo que garantiza un control preciso sobre cuándo y cómo se muestran los datos en el display.

### 4. Testbench
En el testbench, se prueba la funcionalidad de los módulos LFSR y el Registro PIPO al verificar que los datos generados por los LFSR se concatenen correctamente y se almacenen en el registro. Los LFSR se utilizan para generar datos pseudoaleatorios, mientras que el Registro PIPO actúa como un almacenamiento temporal para estos datos antes de ser procesados o mostrados en el display.

```SystemVerilog
module LFSR_TB;

  // Parámetros de tiempo
  parameter CLOCK_PERIOD = 10; // Periodo del reloj en ns
  parameter HALF_CLOCK_PERIOD = CLOCK_PERIOD / 2;
  parameter DELAY_VALUE = 1; // Retardo de escritura en ns

  // Señales de entrada
  reg clk = 0;
  reg rst = 0;
  reg enable = 0;

  // Señales de salida
  wire [15:0] data_out;
  wire [3:0] lfsr_data_out[3:0];
  wire lfsr_done[3:0];
 
  // Semillas iniciales aleatorias
  reg [3:0] seed_array[3:0];

  // Contador de ciclo
  integer i;

  // Instanciación de los 4 módulos LFSR
  LFSR #(4) lfsr_inst0 (
    .i_Clk(clk),
    .i_Rst(rst),
    .i_Enable(enable),
    .i_Seed_Data(seed_array[0]), // Semilla aleatoria
    .o_LFSR_Data(lfsr_data_out[0]),
    .o_LFSR_Done(lfsr_done[0])
  );

  LFSR #(4) lfsr_inst1 (
    .i_Clk(clk),
    .i_Rst(rst),
    .i_Enable(enable),
    .i_Seed_Data(seed_array[1]), // Semilla aleatoria
    .o_LFSR_Data(lfsr_data_out[1]),
    .o_LFSR_Done(lfsr_done[1])
  );

  LFSR #(4) lfsr_inst2 (
    .i_Clk(clk),
    .i_Rst(rst),
    .i_Enable(enable),
    .i_Seed_Data(seed_array[2]), // Semilla aleatoria
    .o_LFSR_Data(lfsr_data_out[2]),
    .o_LFSR_Done(lfsr_done[2])
  );

  LFSR #(4) lfsr_inst3 (
    .i_Clk(clk),
    .i_Rst(rst),
    .i_Enable(enable),
    .i_Seed_Data(seed_array[3]), // Semilla aleatoria
    .o_LFSR_Data(lfsr_data_out[3]),
    .o_LFSR_Done(lfsr_done[3])
  );

  // Instanciación del módulo de registro RPIPO_module
  RPIPO_module RPIPO_inst (
    .clk(clk),
    .we(enable),
    .data_in({lfsr_data_out[3], lfsr_data_out[2], lfsr_data_out[1], lfsr_data_out[0]}),
    .data_out(data_out)
  );

  // Generación de la señal de reloj
  always #HALF_CLOCK_PERIOD clk = ~clk;

  // Inicialización de la simulación
  initial begin
    // Bucle para realizar múltiples ciclos de simulación
    for (i = 1; i <= 5; i = i + 1) begin
      // Generar semillas aleatorias para cada elemento del array seed_array
      for (integer j = 0; j < 4; j = j + 1) begin
        seed_array[j] = $urandom_range(4'b0000, 4'b1111);
      end

      // Habilitar la entrada de datos
      enable = 1;

      // Esperar 10 ciclos de reloj
      #(10 * HALF_CLOCK_PERIOD);

      // Mostrar la concatenación actual
      $display("Concatenación %0d: %b", i, data_out);
       
      // Deshabilitar la entrada de datos
      enable = 0;
    end
    
    // Finalizar la simulación
    $finish;
  end

endmodule
```

La simulación se puede ver en la imagen siguiente: 

<div align="center">
  <img src="https://github.com/KRSahalie/Laboratorio2-TDD/blob/main/Ejercicio3/Imagenes/TB%20LSFR%20Y%20PIPO.png">
</div>

Los valores obtenidos son correctos y esperados, se comprueba la generación de datos y concatenación en el registro PIPO con este paso. 

 
## C. Uso de módulos para controlar relojes de distintas frecuencias

Para el laboratorio 2, se implementa un PLL IP-Core para reducir la frecuencia del reloj principal de la tarjeta FPGA Basys 3 de 100MHz a 10MHz. Este nuevo reloj de 10MHz se convierte en la fuente de reloj global para todos los programas en ejecución en la FPGA. Sin embargo, incluso con esta reducción, la frecuencia de 10MHz sigue siendo relativamente alta para ciertas aplicaciones que requieren operaciones a una velocidad mucho más baja. Por lo que se crean módulos que controlen el reloj y lo disminuyan en frecuencia. 

### 1. Encabezados

#### Slow Clock para los LFSR:
```SystemVerilog
module slowclock_module(
    input clk_in,
    output clk_slow
    );
```
#### Slow Clock para la sincronización del display:
```SystemVerilog
module ledblink2_module(
    input clk_in,
    output clk_slow2
    );
```

### 2. Señales
Las señales básicas de ambos módulos y su funcionamiento son:

#### Señales de Entrada:
- **clk_in:** Señal de reloj reducida de 10Mhz.

#### Señales de Salida:
- **clk_slow,clk_slow2:** Salida de los módulos con la nueva frecuencia de reloj. En el caso de clk_slow es de 2Hz y el de clk_slow2 es de 300 Hz pero puede mejorarse a 1kHz.

### 3. Uso y criterios de diseño
En particular, se establece que la generación de datos para la LFSR (Linear Feedback Shift Register) debe tener un período mínimo de dos segundos. Para lograr esta desaceleración significativa, se recurre a los módulos reductores de frecuencia, comúnmente conocidos como "slow clocks". Los slow clocks son componentes o circuitos diseñados para disminuir la frecuencia de una señal de reloj de manera controlada. Estos módulos permiten ajustar la velocidad de operación del sistema, asegurando que las operaciones se realicen a la velocidad deseada y cumplan con los requisitos de tiempo específicos de la aplicación.

Para la implementación en la FPGA, se utilizaron dos módulos slow clock. Uno se encargó de controlar el reloj de la generación de datos en la LFSR, mientras que el otro gestionó el reloj del contador que cambia de ánodos. Esto permitió visualizar de manera simultánea los 4 dígitos en el display de 7 segmentos sin que se sobrepusieran entre ellos.

### 4. Código

Se define un contador count de 24 bits para llevar la cuenta de los ciclos del reloj de entrada clk_in. En el siempre bloques always @(posedge clk_in) se detectan los flancos de subida del reloj de entrada clk_in.
En cada flanco de subida del reloj de entrada, se incrementa el contador count. Cuando el contador alcanza el valor de 5_000_000 (equivalente a una frecuencia de 2 Hz en un reloj de 10MHz), se reinicia el contador a cero y se invierte el estado del reloj clk_out. Finalmente, el slow clock resultante se asigna a la salida clk_slow. El reloj de 300 Hz funciona con el mismo código, solo se modifica el rango y el valor del contador. 

```SystemVerilog
module slowclock_module(
    input clk_in,
    output clk_slow
    );
    
    reg [23:0] count = 0 ;
    reg clk_out;
    
    always@(posedge clk_in)
    begin 
    count <= count+1;
    if (count == 5_000_000)
    begin
    count<=0;
    clk_out =~ clk_out;
    end
    end
    
    assign clk_slow= clk_out; // reloj de cada 2  segundos lo uso para el reloj de la LSFR y para el enable del pipo
endmodule
```

El funcionamiento de los relojes se probó con la implementación del módulo TOP que se explica continuación. 


## C. Módulo TOP y Decodificación
El módulo LFSR (Registro de Desplazamiento de Retroalimentación Lineal) es una implementación de un LFSR que genera secuencias pseudoaleatorias de acuerdo con un polinomio de retroalimentación específico. Este módulo fue dado por el profesor del curso y solo se debía aprender a implementar. 

### 1. Encabezado
```SystemVerilog
module module_top(
    input clk_i, 
    input rst_i, 
    input enable_i, 
    output reg [0:6] seg, 
    output reg [3:0] an 
);
```
### 2. Señales
Las señales básicas del módulo y su funcionamiento son:

#### Señales de Entrada:
- **clk_i:** Es el reloj global de la FPGA, que se utiliza para sincronizar las operaciones.
- **rst_i:** Es la señal de reset global, que se utiliza para restablecer el estado del sistema.
- **enable_i:** Es la señal de habilitación de las LFSR, que controla la generación de datos pseudoaleatorios.
- 
#### Señales de Salida:
- **seg[0:6]:** Son las salidas conectadas a los segmentos del display de 7 segmentos.
- **an[0:3]:** Son las salidas que controlan el encendido de los ánodos.


### 3. Uso y criterios de diseño
El módulo top representa la culminación y la integración de todos los elementos del sistema en un único diseño. Cada uno de estos componentes interactúan entre sí para lograr el funcionamiento deseado.

Se instancia un módulo de PLL para generar un reloj de 10MHz a partir del reloj global de la FPGA (clk_i). Este reloj de 10MHz se convierte en la base temporal para todo el sistema, proporcionando una sincronización uniforme y precisa para las operaciones internas. Se instancian cuatro LSFR, cada uno con su propia semilla inicial y sincronizado con un reloj lento correspondiente. Estos LSFR generan datos pseudoaleatorios que se utilizarán posteriormente para mostrar información en el display de 7 segmentos. Se emplean los módulos de reloj lento (slowclock_module) para generar relojes de frecuencia más baja. Estos relojes lentos son esenciales para controlar la generación de datos de los LSFR (Linear Feedback Shift Register) y el registro PIPO (Parallel In, Parallel Out). La utilización de relojes de frecuencia reducida permite ajustar la velocidad de operación de estos componentes según los requisitos específicos de la aplicación.

El registro PIPO actúa como una especie de "buffer" temporal, almacenando los datos generados por los LSFR antes de ser mostrados en el display. Este registro también está sincronizado con un reloj lento para garantizar una operación coordinada con el resto del sistema.

Para visualizar los datos en el display de 7 segmentos, se implementa un sistema de multiplexión junto con un contador. Este sistema alterna rápidamente entre los diferentes ánodos del display, permitiendo que se muestren varios dígitos en secuencia. Cada ánodo se activa con una frecuencia específica, coordinada con el reloj lento correspondiente, y muestra el dígito correspondiente decodificado a partir de la cadena de 16 bits generada por los LSFR.

### 4. Código 

```SystemVerilog
module module_top(
    input clk_i, 
    input rst_i, 
    input enable_i, 
    output reg [0:6] seg, 
    output reg [3:0] an
);
    // Declaración de señales internas
    wire clk_slow;
    wire clk_slow2;
    
    // Señales internas del reloj obtenido por PLL IP-Core
    wire clk_10MHz;
    wire reset;
    wire locked;
    
    //Señales internas del LFSR y PIPO
    wire [15:0] data_out;
    wire [3:0] lfsr_data_out[3:0];
    wire lfsr_done[3:0];
    
    //Instancias de LFSR (4 de 4 bits)
        LFSR #(4) lfsr_inst0 (
        .i_Clk(clk_slow),//Genera datos cada dos segundos
        .i_Rst(rst_i),
        .i_Enable(enable_i),
        .i_Seed_Data(4'b1010),
        .o_LFSR_Data(lfsr_data_out[0]),
        .o_LFSR_Done(lfsr_done[0])
    );

    LFSR #(4) lfsr_inst1 (
        .i_Clk(clk_slow),//Genera datos cada dos segundos
        .i_Rst(rst_i),
        .i_Enable(enable_i),
        .i_Seed_Data(4'b1101),
        .o_LFSR_Data(lfsr_data_out[1]),
        .o_LFSR_Done(lfsr_done[1])
    );

    LFSR #(4) lfsr_inst2 (
        .i_Clk(clk_slow),//Genera datos cada dos segundos
        .i_Rst(rst_i),
        .i_Enable(enable_i),
        .i_Seed_Data(4'b0110),
        .o_LFSR_Data(lfsr_data_out[2]),
        .o_LFSR_Done(lfsr_done[2])
    );

    LFSR #(4) lfsr_inst3 (
        .i_Clk(clk_slow), //Genera datos cada dos segundos
        .i_Rst(rst_i),
        .i_Enable(enable_i),
        .i_Seed_Data(4'b1001),
        .o_LFSR_Data(lfsr_data_out[3]),
        .o_LFSR_Done(lfsr_done[3])
    );
    
    // Instancia del reloj
    clk_wiz_0 instance_name (
        .clk_10MHz(clk_10MHz),  // salida de clk_10MHz
        .reset(reset),        
        .locked(locked),        
        .clk_100MHz(clk_i)      
    );

    // Instancia del slowclock_module
    slowclock_module slowclock_inst (
        .clk_in(clk_10MHz),       
        .clk_slow(clk_slow) // Salida del slow clock
    );
     
    // Instancia del slowclock_module2
    ledblink2_module slowclock_inst2 (
        .clk_in(clk_10MHz),       
        .clk_slow2(clk_slow2) // Salida del slow clock
    );
    
    // Instancia del RPIPO_module
    RPIPO_module RPIPO_inst (
        .clk(clk_10MHz),     // Conecta el slow clock al reloj del RPIPO_module
        .we(clk_slow2),      // Conecta la señal de escritura
        .data_in({lfsr_data_out[3], lfsr_data_out[2], lfsr_data_out[1], lfsr_data_out[0]}), //Entrada concatenada
        .data_out(data_out)
    );
    
    //Logica del decodificador
    //Señales internas de decodificador
    reg [1:0] s; // Selector del multiplexor
    reg [3:0] digit; // Valor a mostrar en el display
    reg [3:0] an_counter; // Contador para alternar entre los anodos
        
    // Inicialización del contador de anodos
    initial begin
        an_counter = 4'b0000;
    end
    
    // Lógica del contador de anodos para alternar entre los anodos rápidamente
    always @ (posedge clk_slow2) begin
        if (an_counter == 4'b0011) begin // Cuando el contador llega a 3 (4'b0011), reiniciamos a 0
            an_counter <= 4'b0000;
        end else begin
            an_counter <= an_counter + 1;
        end
    end
            
        // Multiplexor
        always @ (*)
            case (an_counter)
                4'b0000: begin
                    digit = data_out[3:0]; // Asigna los bits 0-3 de data_out al primer anodo
                    an = 4'b1110; // Activa el primer anodo
                end
                4'b0001: begin
                    digit = data_out[7:4]; // Asigna los bits 4-7 de data_out al segundo anodo
                    an = 4'b1101; // Activa el segundo anodo
                end
                4'b0010: begin
                    digit = data_out[11:8]; // Asigna los bits 8-11 de data_out al tercer anodo
                    an = 4'b1011; // Activa el tercer anodo
                end
                4'b0011: begin
                    digit = data_out[15:12]; // Asigna los bits 12-15 de data_out al cuarto anodo
                    an = 4'b0111; // Activa el cuarto anodo
                end
                default: begin
                    digit = data_out[3:0]; // En caso de un valor no esperado, asigna los bits 0-3 de data_out al primer anodo
                    an = 4'b1110; // Activa el primer anodo
                end
            endcase
                      
     //7 segmentos
     always @(*)
         case(digit)        //Anodo comun: para encendido 0 y apagado 1, orden del display 7'babcdefg
             0: seg = 7'b0000001;   //0
             1: seg = 7'b1001111;   //1
             2: seg = 7'b0010010;   //2
             3: seg = 7'b0000110;   //3
             4: seg = 7'b1001100;   //4
             5: seg = 7'b0100100;   //5
             6: seg = 7'b0100000;   //6
             7: seg = 7'b0001111;   //7
             8: seg = 7'b0000000;   //8
             9: seg = 7'b0000100;   //9
             'hA: seg = 7'b0001000; //A
             'hB: seg = 7'b1100000; //b
             'hC: seg = 7'b0110001; //C
             'hD: seg = 7'b1000010; //D
             'hE: seg = 7'b0110000; //E
             'hF: seg = 7'b0111000; //F
                 default: seg = 7'b0000001;  //Default de valor 0 
         endcase

endmodule
```

El constraint utilizado para las conexiones y la prueba en la FPGA es el siguiente: 


```SystemVerilog
## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal
## Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk_i]
#create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_i]

# Switches
set_property PACKAGE_PIN V17 [get_ports {rst_i}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {rst_i}]
set_property PACKAGE_PIN V16 [get_ports {enable_i}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {enable_i}]	
#set_property PACKAGE_PIN W16 [get_ports {enable_i}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {enable_i}]
#set_property PACKAGE_PIN W17 [get_ports {sw[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
#set_property PACKAGE_PIN W15 [get_ports {sw[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
#set_property PACKAGE_PIN V15 [get_ports {sw[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
#set_property PACKAGE_PIN W14 [get_ports {sw[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
#set_property PACKAGE_PIN W13 [get_ports {sw[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
#set_property PACKAGE_PIN V2 [get_ports {sw[8]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
#set_property PACKAGE_PIN T3 [get_ports {sw[9]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
#set_property PACKAGE_PIN T2 [get_ports {sw[10]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
#set_property PACKAGE_PIN R3 [get_ports {sw[11]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
#set_property PACKAGE_PIN W2 [get_ports {sw[12]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
#set_property PACKAGE_PIN U1 [get_ports {sw[13]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
#set_property PACKAGE_PIN T1 [get_ports {sw[14]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
#set_property PACKAGE_PIN R2 [get_ports {sw[15]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[15]}]
 

# LEDs
set_property PACKAGE_PIN U16 [get_ports {LED[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
#set_property PACKAGE_PIN U19 [get_ports {LED[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
#set_property PACKAGE_PIN V19 [get_ports {LED[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]
#set_property PACKAGE_PIN W18 [get_ports {LED[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]
#set_property PACKAGE_PIN U15 [get_ports {LED[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}]
#set_property PACKAGE_PIN U14 [get_ports {LED[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}]
#set_property PACKAGE_PIN V14 [get_ports {LED[7]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]
#set_property PACKAGE_PIN V13 [get_ports {LED[8]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[8]}]
#set_property PACKAGE_PIN V3 [get_ports {LED[9]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]
#set_property PACKAGE_PIN W3 [get_ports {LED[10]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]
#set_property PACKAGE_PIN U3 [get_ports {LED[11]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]
#set_property PACKAGE_PIN P3 [get_ports {LED[12]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]
#set_property PACKAGE_PIN N3 [get_ports {LED[13]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[13]}]
#set_property PACKAGE_PIN P1 [get_ports {LED[14]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[14]}]
#set_property PACKAGE_PIN L1 [get_ports {LED[15]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED[15]}]
	
	
#7 segment display
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

#set_property PACKAGE_PIN V7 [get_ports dp]							
#	set_property IOSTANDARD LVCMOS33 [get_ports dp]

#Anodes
set_property PACKAGE_PIN U2 [get_ports {an[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]


##Buttons
#set_property PACKAGE_PIN U18 [get_ports btnC]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnC]
#set_property PACKAGE_PIN T18 [get_ports btnU]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnU]
#set_property PACKAGE_PIN W19 [get_ports btnL]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnL]
#set_property PACKAGE_PIN T17 [get_ports btnR]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnR]
#set_property PACKAGE_PIN U17 [get_ports btnD]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnD]
 


##Pmod Header JA
##Sch name = JA1
#set_property PACKAGE_PIN J1 [get_ports {JA[0]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[0]}]
##Sch name = JA2
#set_property PACKAGE_PIN L2 [get_ports {JA[1]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[1]}]
##Sch name = JA3
#set_property PACKAGE_PIN J2 [get_ports {JA[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[2]}]
##Sch name = JA4
#set_property PACKAGE_PIN G2 [get_ports {JA[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[3]}]
##Sch name = JA7
#set_property PACKAGE_PIN H1 [get_ports {JA[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[4]}]
##Sch name = JA8
#set_property PACKAGE_PIN K2 [get_ports {JA[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[5]}]
##Sch name = JA9
#set_property PACKAGE_PIN H2 [get_ports {JA[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[6]}]
##Sch name = JA10
#set_property PACKAGE_PIN G3 [get_ports {JA[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JA[7]}]



##Pmod Header JB
##Sch name = JB1
#set_property PACKAGE_PIN A14 [get_ports {JB[0]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[0]}]
##Sch name = JB2
#set_property PACKAGE_PIN A16 [get_ports {JB[1]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[1]}]
##Sch name = JB3
#set_property PACKAGE_PIN B15 [get_ports {JB[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[2]}]
##Sch name = JB4
#set_property PACKAGE_PIN B16 [get_ports {JB[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[3]}]
##Sch name = JB7
#set_property PACKAGE_PIN A15 [get_ports {JB[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[4]}]
##Sch name = JB8
#set_property PACKAGE_PIN A17 [get_ports {JB[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[5]}]
##Sch name = JB9
#set_property PACKAGE_PIN C15 [get_ports {JB[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[6]}]
##Sch name = JB10 
#set_property PACKAGE_PIN C16 [get_ports {JB[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JB[7]}]
 


##Pmod Header JC
##Sch name = JC1
#set_property PACKAGE_PIN K17 [get_ports {JC[0]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[0]}]
##Sch name = JC2
#set_property PACKAGE_PIN M18 [get_ports {JC[1]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[1]}]
##Sch name = JC3
#set_property PACKAGE_PIN N17 [get_ports {JC[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[2]}]
##Sch name = JC4
#set_property PACKAGE_PIN P18 [get_ports {JC[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[3]}]
##Sch name = JC7
#set_property PACKAGE_PIN L17 [get_ports {JC[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[4]}]
##Sch name = JC8
#set_property PACKAGE_PIN M19 [get_ports {JC[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[5]}]
##Sch name = JC9
#set_property PACKAGE_PIN P17 [get_ports {JC[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[6]}]
##Sch name = JC10
#set_property PACKAGE_PIN R18 [get_ports {JC[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {JC[7]}]


##Pmod Header JXADC
##Sch name = XA1_P
#set_property PACKAGE_PIN J3 [get_ports {vauxp6}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {vauxp6}]
##Sch name = XA2_P
#set_property PACKAGE_PIN L3 [get_ports {vauxp14}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {vauxp14}]
##Sch name = XA3_P
#set_property PACKAGE_PIN M2 [get_ports {vauxp7}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {vauxp7}]
##Sch name = XA4_P
#set_property PACKAGE_PIN N2 [get_ports {vauxp15}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {vauxp15}]
##Sch name = XA1_N
#set_property PACKAGE_PIN K3 [get_ports {vauxn6}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {vauxn6}]
##Sch name = XA2_N
#set_property PACKAGE_PIN M3 [get_ports {vauxn14}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {vauxn14}]
##Sch name = XA3_N
#set_property PACKAGE_PIN M1 [get_ports {vauxn7}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {vauxn7}]
##Sch name = XA4_N
#set_property PACKAGE_PIN N1 [get_ports {vauxn15}]				
#	set_property IOSTANDARD LVCMOS33 [get_ports {vauxn15}]



##VGA Connector
#set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
#set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
#set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
#set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]
#set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
#set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
#set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
#set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]
#set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
#set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
#set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
#set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]
#set_property PACKAGE_PIN P19 [get_ports Hsync]						
	#set_property IOSTANDARD LVCMOS33 [get_ports Hsync]
#set_property PACKAGE_PIN R19 [get_ports Vsync]						
	#set_property IOSTANDARD LVCMOS33 [get_ports Vsync]


##USB-RS232 Interface
#set_property PACKAGE_PIN B18 [get_ports RsRx]						
	#set_property IOSTANDARD LVCMOS33 [get_ports RsRx]
#set_property PACKAGE_PIN A18 [get_ports RsTx]						
	#set_property IOSTANDARD LVCMOS33 [get_ports RsTx]


##USB HID (PS/2)
#set_property PACKAGE_PIN C17 [get_ports PS2Clk]						
	#set_property IOSTANDARD LVCMOS33 [get_ports PS2Clk]
	#set_property PULLUP true [get_ports PS2Clk]
#set_property PACKAGE_PIN B17 [get_ports PS2Data]					
	#set_property IOSTANDARD LVCMOS33 [get_ports PS2Data]	
	#set_property PULLUP true [get_ports PS2Data]


##Quad SPI Flash
##Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
##STARTUPE2 primitive.
#set_property PACKAGE_PIN D18 [get_ports {QspiDB[0]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[0]}]
#set_property PACKAGE_PIN D19 [get_ports {QspiDB[1]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[1]}]
#set_property PACKAGE_PIN G18 [get_ports {QspiDB[2]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[2]}]
#set_property PACKAGE_PIN F18 [get_ports {QspiDB[3]}]				
	#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[3]}]
#set_property PACKAGE_PIN K19 [get_ports QspiCSn]					
	#set_property IOSTANDARD LVCMOS33 [get_ports QspiCSn]
```

### 4. Implementación y prueba en FPGA
Se procede a sintetizar, implementar y generar el Bitstream para probar en la FPGA, el funcionamiento se puede ver en el siguiente video:

https://github.com/EL3313/laboratorio2-grupo-6/assets/161046331/6c918419-c169-4f6b-b69e-d6917fdfe341

El ejercicio fue diseñado e implementado con éxito, y todas las funcionalidades operaron correctamente. Desde la generación de datos pseudoaleatorios hasta su visualización en el display de 7 segmentos, el sistema demostró una integración efectiva de cada componente. La utilización de relojes de frecuencia reducida permitió controlar con precisión el tiempo de operación de los LSFR y el registro PIPO, mientras que el sistema de multiplexión y el contador garantizaron una visualización fluida y coordinada en el display. En resumen, el diseño cumplió con los requisitos establecidos y demostró una ejecución confiable y coherente de principio a fin.



## Ejercicio 4: Banco de registros

## 1. Módulo de Registro
El módulo Registro implementa un banco de registros de 32 registros (configurable mediante el parámetro N) con un ancho de datos de 8 bits (configurable mediante el parámetro W). Este módulo permite realizar lecturas y escrituras de manera controlada en cada uno de los registros, utilizando señales de dirección para seleccionar el registro de lectura y escritura, así como un bit de habilitación de escritura (we). Además, se incluye un mecanismo de reset para asegurar que el banco de registros inicie en un estado conocido. El banco de registros se utiliza comúnmente en unidades de procesamiento o sistemas que requieren almacenamiento temporal de datos en hardware digital.

### 1. Encabezado
```SystemVerilog
// Banco de registros parametrizable
module Registro #(
    parameter N = 5,           // N bits de dirección => 2^N registros
    parameter W = 8            // W bits de ancho por registro
)(
    input logic           clk,             // reloj
    input logic           rst,             // reset síncrono
    input logic [N-1:0]   addr_rs1,        // dirección de lectura 1
    input logic [N-1:0]   addr_rs2,        // dirección de lectura 2
    input logic [N-1:0]   addr_rd,         // dirección de escritura
    input logic [W-1:0]   data_in,         // datos de entrada a escribir
    input logic           we,              // write enable

    output logic [W-1:0]  rs1,             // salida de lectura 1
    output logic [W-1:0]  rs2              // salida de lectura 2
);
```

### 2. Señales
Las señales básicas del módulo y su funcionamiento son:

#### Señales de Entrada:
- **clk:** Señal de reloj que controla el funcionamiento del banco de registros.
- **rst:** Señal de reset que restablece el estado del banco de registros.
- **addr_rs1,addr_rs2:** Direcciones de lectura del banco de registros.
- **addr_rd:** Dirección de escritura del banco de registros.
- **data_in:** Datos de entrada a escribir en el banco de registros.
- **we:** Señal de write enable, controla la escritura en el banco de registros. 

#### Señales de Salida:
- **rs1,rs2:** Señales de salida de lectura del banco de registros. 

### 3. Uso y criterios de diseño
El banco de registros desarrollado en este laboratorio es una estructura parametrizable que permite almacenar temporalmente variables necesarias para la ejecución de las instrucciones de un procesador. Este banco cuenta con un número configurable de registros, 2^N en total, y cada registro tiene un ancho de W bits, lo que proporciona flexibilidad en términos de almacenamiento y acceso. El banco de registros está diseñado para realizar escritura de datos en cualquier registro especificado a través de la dirección addr_rd, pero la escritura solo ocurre cuando la señal de habilitación we está activa. Las lecturas de los registros se realizan mediante las señales de dirección addr_rs1 y addr_rs2, que seleccionan qué registros devolverán sus valores a través de las salidas rs1 y rs2, respectivamente.

Es importante destacar que el registro ubicado en la dirección 0x00h es de solo lectura, y siempre devuelve un valor de 0x0000000h al ser leído, independientemente de la operación de lectura realizada. Este comportamiento asegura que el registro 0 no sea modificado durante la ejecución del sistema.

Este diseño también incorpora la capacidad de probar el banco de registros a través de un testbench, que permite escribir valores aleatorios en cada registro y luego realizar lecturas también aleatorias para verificar la correcta operación de la memoria. El sistema se ha diseñado para que sea fácilmente adaptable a diferentes anchos de palabra, como 8 bits o 16 bits, y puede ser implementado en una FPGA para su demostración práctica.

### 4. Testbench

Este testbench verifica el funcionamiento del módulo de registro, provee entradas que son escritas a direcciones especificas y luego leídas para verificar que el paso de información es correcto. 

```SystemVerilog
// Definición de la escala de tiempo (1ns de unidad de tiempo, 1ps de precisión)
`timescale 1ns/1ps

// Módulo de prueba para el banco de registros (Registro_tb)
module Registro_tb;

    // Parámetros del banco de registros
    parameter N = 5; // 2^5 = 32 registros (el número total de registros)
    parameter W = 8; // 8 bits de ancho de cada registro (tamaño de los datos)

    // Señales de entrada y salida para el DUT (Device Under Test)
    logic clk;  // Reloj
    logic rst;  // Reset (reinicio)
    logic [N-1:0] addr_rs1, addr_rs2, addr_rd;  // Direcciones de los registros
    logic [W-1:0] data_in;  // Datos a escribir en el registro
    logic we;  // Señal de habilitación de escritura (write enable)
    logic [W-1:0] rs1, rs2;  // Salidas de los registros

    // Instanciación del banco de registros (DUT)
    Registro #(N, W) dut (
        .clk(clk),        // Reloj
        .rst(rst),        // Reset
        .addr_rs1(addr_rs1), // Dirección del registro 1
        .addr_rs2(addr_rs2), // Dirección del registro 2
        .addr_rd(addr_rd),   // Dirección del registro de escritura
        .data_in(data_in),   // Datos a escribir
        .we(we),            // Habilitación de escritura
        .rs1(rs1),          // Salida del registro 1
        .rs2(rs2)           // Salida del registro 2
    );

    // Generador de señal de reloj (flip-flop que invierte el valor del reloj cada 5 unidades de tiempo)
    always #5 clk = ~clk;

    // Memoria de referencia para comparar los valores escritos
    logic [W-1:0] ref_mem [0:(2**N)-1];

    initial begin
        integer i;  // Variable de índice para los bucles

        // Inicialización de señales
        clk = 0;  // El reloj inicia en 0
        rst = 1;  // El reset está activado inicialmente
        we = 0;   // No se habilita la escritura al principio
        data_in = 0;  // Inicialización de los datos de entrada
        addr_rd = 0;  // Dirección de lectura inicial
        addr_rs1 = 0; // Dirección de lectura para rs1
        addr_rs2 = 0; // Dirección de lectura para rs2

        // Activación del reset durante 10 unidades de tiempo
        #10 rst = 0;

        // Escritura de datos aleatorios en los registros (excepto en el registro 0)
        for (i = 1; i < 2**N; i = i + 1) begin
            @(posedge clk); // Espera un ciclo de reloj
            addr_rd = i;  // Se asigna la dirección del registro
            data_in = $urandom_range(0, 2**W - 1);  // Generación de datos aleatorios
            ref_mem[i] = data_in;  // Se almacena el valor en la memoria de referencia
            we = 1;  // Se habilita la escritura
        end

        @(posedge clk);  // Espera otro ciclo de reloj
        we = 0;  // Se deshabilita la escritura
        addr_rd = 0;  // Se restablece la dirección de lectura a 0

        // Lectura de registros aleatorios
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);  // Espera un ciclo de reloj
            addr_rs1 = $urandom_range(0, 2**N - 1);  // Se asigna aleatoriamente la dirección de lectura para rs1
            addr_rs2 = $urandom_range(0, 2**N - 1);  // Se asigna aleatoriamente la dirección de lectura para rs2
            #1; // Se introduce un pequeño retraso para observar los valores leídos

            // Impresión de los resultados de lectura con comparación
            $display("--------------------------------------------------");
            $display("Read Check #%0d", i + 1);  // Muestra el número de la prueba

            // Verificación del valor leído en rs1
            $display("  RS1 -> Address: %0d | Value: %0d | Expected: %0d", 
                     addr_rs1, rs1, (addr_rs1 == 0) ? 0 : ref_mem[addr_rs1]);  // Dirección, valor leído y valor esperado
            if (rs1 == ((addr_rs1 == 0) ? 0 : ref_mem[addr_rs1])) 
                $display("    => RS1 Check PASSED!");  // Si coincide, se muestra que la verificación fue exitosa
            else 
                $display("    => RS1 Check FAILED!");  // Si no coincide, se muestra que falló

            // Verificación del valor leído en rs2
            $display("  RS2 -> Address: %0d | Value: %0d | Expected: %0d", 
                     addr_rs2, rs2, (addr_rs2 == 0) ? 0 : ref_mem[addr_rs2]);  // Dirección, valor leído y valor esperado
            if (rs2 == ((addr_rs2 == 0) ? 0 : ref_mem[addr_rs2])) 
                $display("    => RS2 Check PASSED!");  // Si coincide, se muestra que la verificación fue exitosa
            else 
                $display("    => RS2 Check FAILED!");  // Si no coincide, se muestra que falló

            $display("--------------------------------------------------\n");  // Se separan las verificaciones con una línea
        end

        $display("Testbench terminado.");  // Mensaje final indicando que la prueba ha terminado
        $finish;  // Finaliza la simulación
    end

endmodule
```
La simulación se puede ver en la imagen siguiente: 

<div align="center">
  <img src="https://github.com/KRSahalie/Laboratorio2-TDD/blob/main/Ejercicio4/Imagenes/Tb.png">
</div>

Además se muentra en la consola unos mensajes de autoverificación:

```SystemVerilog
--------------------------------------------------
Read Check #1
  RS1 -> Address: 26 | Value: 140 | Expected: 140
    => RS1 Check PASSED!
  RS2 -> Address: 6 | Value: 244 | Expected: 244
    => RS2 Check PASSED!
--------------------------------------------------

--------------------------------------------------
Read Check #2
  RS1 -> Address: 14 | Value: 214 | Expected: 214
    => RS1 Check PASSED!
  RS2 -> Address: 29 | Value: 209 | Expected: 209
    => RS2 Check PASSED!
--------------------------------------------------

--------------------------------------------------
Read Check #3
  RS1 -> Address: 23 | Value: 198 | Expected: 198
    => RS1 Check PASSED!
  RS2 -> Address: 8 | Value: 101 | Expected: 101
    => RS2 Check PASSED!
--------------------------------------------------

--------------------------------------------------
Read Check #4
  RS1 -> Address: 23 | Value: 198 | Expected: 198
    => RS1 Check PASSED!
  RS2 -> Address: 18 | Value: 195 | Expected: 195
    => RS2 Check PASSED!
--------------------------------------------------

--------------------------------------------------
Read Check #5
  RS1 -> Address: 14 | Value: 214 | Expected: 214
    => RS1 Check PASSED!
  RS2 -> Address: 5 | Value: 140 | Expected: 140
    => RS2 Check PASSED!
--------------------------------------------------

--------------------------------------------------
Read Check #6
  RS1 -> Address: 15 | Value: 128 | Expected: 128
    => RS1 Check PASSED!
  RS2 -> Address: 5 | Value: 140 | Expected: 140
    => RS2 Check PASSED!
--------------------------------------------------

--------------------------------------------------
Read Check #7
  RS1 -> Address: 13 | Value: 29 | Expected: 29
    => RS1 Check PASSED!
  RS2 -> Address: 6 | Value: 244 | Expected: 244
    => RS2 Check PASSED!
--------------------------------------------------

--------------------------------------------------
Read Check #8
  RS1 -> Address: 23 | Value: 198 | Expected: 198
    => RS1 Check PASSED!
  RS2 -> Address: 27 | Value: 179 | Expected: 179
    => RS2 Check PASSED!
--------------------------------------------------

--------------------------------------------------
Read Check #9
  RS1 -> Address: 12 | Value: 26 | Expected: 26
    => RS1 Check PASSED!
  RS2 -> Address: 6 | Value: 244 | Expected: 244
    => RS2 Check PASSED!
--------------------------------------------------

--------------------------------------------------
Read Check #10
  RS1 -> Address: 1 | Value: 217 | Expected: 217
    => RS1 Check PASSED!
  RS2 -> Address: 25 | Value: 9 | Expected: 9
    => RS2 Check PASSED!
--------------------------------------------------
```
Los valores obtenidos son correctos y esperados, se comprueba la generación de datos con este paso. 




## 3.5 Ejercicio 5. Mini unidad de cálculo
### 1. Diagrama de bloques para la mini unidad de claculo
 <div align="center">
<img src="https://raw.githubusercontent.com/KRSahalie/Laboratorio2-TDD/main/Ejercicio5/Imagenes/Diagrama_Bloques.png">
</div>
### 2.1 Diagramas de de flujo para la mini unidad de calculo 
### 2.1 Modo 1
 <div align="center">
<img src="https://raw.githubusercontent.com/KRSahalie/Laboratorio2-TDD/main/Ejercicio5/Imagenes/Diagrama taller.drawio.png">
</div>
### 2.2 Modo 2
 <div align="center">
<img src="https://raw.githubusercontent.com/KRSahalie/Laboratorio2-TDD/main/Ejercicio5/Imagenes/Diagrama_Flujo_M2.png">
</div>

### 3. La maquina de estados seleccionada fue la de moore que se encuentra en la siguiente imagen.
<div align="center">
<img src="https://raw.githubusercontent.com/KRSahalie/Laboratorio2-TDD/main/Ejercicio5/Imagenes/FSM">
</div>

### 4. Ruta de datos
Para el sistema primero se generan 2 grupo de bits semialeatorios (LSFR), uno a la vez pasando por el mux donde la maquina de estados permite la salida de la entrada del LSFR guardando en la dirección 1 a los primeros 7 bits semialeatorios y luego volviendo a realizar el proceso para los segundos 7bits semialeatorios. Ya guardados en el banco de registros en la posición 1 y 2 se manda los valores del registro a la ALU al mismo tiempo que se manda cada uno de los 2 numeros semialatorios a la pa

### 5. Codigo
```SystemVerilog
module FSM(
input logic clk,
input logic rst,
input logic swt,
input logic btn0,
input logic btn1,
input logic btn2,
input logic btn3,

output logic [3:0]  led,
output logic [15:0] seg,
output logic        mux,
output logic        we,
output logic [3:0]  op,
output logic [4:0]  addr
    );
    
typedef enum logic [3:0]{
INICIO    = 4'd0,
LSFR      = 4'd1,
ADDRESS   = 4'd2,
REGISTRO  = 4'd3,
ALU       = 4'd4,
TIEMPO    = 4'd5,
JUMP      = 4'd6,
ESPERA    = 4'd7,
ALMACEN   = 4'd8,
DISPLAY   = 4'd9,
RETORNO   = 4'd10, 
DIRECCION = 4'd11,
LECTURA   = 4'd12,
SUMA      = 4'd13
}state_t;

state_t state, next_state;

logic [3:0]  jump;
logic [15:0] count;
logic [3:0] max;

//Definición del rst y valores iniciales
always @(negedge clk)begin
    if (rst) begin
         state    <= INICIO;
         count    <= 0;
         jump     <= 0;
         max      <= 0;
         addr     <= 0;
  end else begin
        state    <= next_state;
//        count    <= next_count;
//        jump     <= next_jump;
//        max      <= next_max;
//        addr     <= next_addr;
    end
end
    
//Definición de siguiente estado
always_comb begin
        next_state = state;
        case (state)
            //1°Modo
            INICIO:     next_state = (swt == 0)    ? LSFR    : DIRECCION;
            LSFR:       next_state = ADDRESS;
            ADDRESS:    next_state = (jump >= 2)   ? REGISTRO    : LSFR;
            REGISTRO:   next_state = ALU;
            ALU:        next_state = (btn0 || btn1 || btn2 || btn3) ? TIEMPO: ALU;
            TIEMPO:     next_state = (count >= 10) ? JUMP  : ALU;
            JUMP:       next_state = (jump >= 2)   ? ESPERA  : ALU;
            ESPERA:     next_state = ALMACEN;
            ALMACEN:    next_state = DISPLAY;
            DISPLAY:    next_state = (count >= 20) ? RETORNO : DISPLAY;
            RETORNO:    next_state = (max >= 10)   ? RETORNO : INICIO;
            //2°Modo
            DIRECCION:  next_state = LECTURA;
            LECTURA:    next_state = (count >= 20) ? SUMA    : LECTURA;
            SUMA:       next_state = (max >= 32 )  ? INICIO  : LECTURA;
        endcase
end
//Definición de salida de estados
always_comb begin
        case (state)
        //1°Modo
            INICIO:begin      
                        led = 4'b0000; //0
                        seg = 16'h0000;
                        mux = 0;
                        we = 0;
                        op = 4'h0;
                        addr = addr;
                        jump = jump;
                        count = count;
                        max = max;
                        end
            LSFR:begin
                        led = 4'b0001; //1
//                        seg = 16'h0000;
//                        mux = 0;
//                        we = 1;
//                        op = 4'h0;
//                        addr = addr; 
//                        jump = jump;
//                        count = count;
//                        max = max;
                        end
            ADDRESS:begin 
                        led = 4'b0010;//2
//                        seg = 16'h0000;
//                        mux = 0;
                        we = 1;
//                        op = 4'h0;
                        addr = addr + 1;
                        jump = jump + 1 ;
//                        count = count; 
                        end                 
            REGISTRO:begin   
                        led = 4'b0011;//3 
//                        seg = 16'h0000;
//                        mux =  1;
                        we = 1;
//                        op = 4'h0;
                        addr = addr - 2;
                        jump = jump - 2;
//                        count = count;
//                        max = max;
                        end
            ALU:begin //4
            mux = 1; 
            we = 0;        
                        if (btn0) begin
                            op = 4'h2;
                            led  = 4'b1001;
//                            seg = 16'h0000;
//                            addr = addr;
//                            jump = jump;
//                            count = count;
//                            max = max;
                            end
                        else if (btn1) begin
                            op = 4'h6;
                            led  = 4'b0110;
//                            seg = 16'h0000;
//                            addr = addr;
//                            jump = jump;
//                            count = count;
//                            max = max;
                            end
                        else if (btn2) begin
                            op = 4'h0;
                            led  = 4'b1111;
//                            seg = 16'h0000;
//                            addr = addr;
//                            jump = jump;
//                            count = count;
//                            max = max;
                            end
                        else if (btn3) begin
                            op = 4'h1;
                            led  = 4'b1010;
//                            seg = 16'h0000;
//                            mux =  1;
//                            we = 1;
//                            addr = addr;
//                            jump = jump;
//                            count = count;
//                            max = max;
                            end
                        end
            TIEMPO:begin 
                        led = 4'b0101;//5
//                        seg = 16'h0000;
//                        mux =  0;
//                        we = 0;
//                        op = 4'b0000;
                        count = count + 20;
//                        jump = jump;
//                        addr = addr;
//                        max = max;
                        end
            JUMP:begin 
                        led = 4'b0110;//6
                        seg = 16'h0000;
//                        mux =  0;
//                        we =0;
//                        op = 4'b0000;
//                        count = count;
                        jump = jump + 1;
                        addr = addr + 1;
//                        max = max;
                        end
            ESPERA:begin      
                        led = 4'b0111;//7
//                        seg = 16'h0000;
                        mux = 1;
                        we = 1;
//                        op = 4'b0000;
//                        addr = addr + 1;
                        jump = jump -1;
                        count = count - 20;
                        //result = result;
//                        max = max;
                        end
            ALMACEN:begin
                        led = 4'b1000;//8
                        seg = 16'h1111;
//                        mux =  1;
//                        we = 1;
//                        op = 4'b0000;
//                        addr = addr ;
//                        jump = jump;
//                        count = count;
//                        max = max;
                        end
            DISPLAY:begin 
                        led = 4'b1001;//9
                        seg = 16'h1111;
//                        mux =  1;
//                        we = 1;
//                        op = 4'b0000;
//                        addr = addr;
//                        jump = jump;
                        count = count + 10;
//                        max = max;
                        end
            RETORNO:begin    //10
                        led = 4'b1010;
//                        seg = 16'h0000;
//                        mux =  1;
//                        we = 1;
//                        op = 4'b0000;
//                        addr = addr + 1;
//                        jump = jump;
//                        count = count;
                        max = max + 1;
                        end
            //2°Modo
            DIRECCION:begin
                        led = 4'b1011;
//                        seg = 16'h0000;
                        mux =  0;
                        we = 1;
//                        op = 4'b0000;
                        addr = 0;
//                        jump = jump;
                        count = 0;
                        max = 0;
                        end
            LECTURA:begin
                        led = 4'b1111;
                        seg = 16'h0000;
                        mux =  0;
                        we = 1;
//                        op = 4'h0;
                        addr = addr;
//                        jump = jump;
                        count = count + 10;
                        max = max;
                        end
            SUMA:begin  
                        led = 4'b1001;
                        seg = 16'h0000;
//                        mux =  1;
                        we = 1;
//                        op = 4'h0;
//                        addr = addr + 1;
//                        jump = jump;
                        count = count;
                        max = max + 1;
                        end
        endcase
end         
endmodule
```
## 6 Top module
```SystemVerilog
module FSM_top(
input logic clk,
input logic rst,
input logic swt,
input logic btn0,
input logic btn1,
input logic btn2,
input logic btn3,

output logic [3:0]  led,
output logic [15:0] seg,
output logic        mux,
output logic        we,
output logic [3:0]  op,
output logic [4:0]  addr
    );
    
logic [6:0] A_reg;
//logic [6:0] B_reg;
logic [6:0] result;
logic [6:0] out;
logic [6:0] rs1;
logic [6:0] rs2;

FSM fsm_U(
.clk  (clk),
.rst  (rst),
.swt  (swt),
.btn0 (btn0),
.btn1 (btn1),
.btn2 (btn2),
.btn3 (btn3),

.led  (led),
.seg  (seg),
.mux  (mux),
.we   (we),
.op   (op),
.addr (addr)
);

LFSR2 l_sfm(
.clk   (clk),
.rst   (rst),
.A_reg (A_reg)
//.B_reg (B_reg)
);

mux4 mux_U(
.in0 (A_reg), 
.in1 (result), 
.sel  (mux),
.out  (out)
);

Registro reg_fsm (
.clk(clk),
.rst(rst),
.addr_rs1(addr),
.addr_rs2(addr+1),
.addr_rd(addr+1),
.data_in(out),
.we(we),
.rs1(rs1),
.rs2(rs2)
    );

Alu Alu_U(
.A (rs1),
.B (rs2),
.Alu_control (op),
.result (result)
);

endmodule
```
## 7 Testbench

```SystemVerilog
module FSM_tb;
    // Señales de entrada
    logic        clk;
    logic        rst;
    logic        swt;
    logic        btn0, btn1, btn2, btn3;

    // Señales de salida (mismos anchos que en FSM_top)
    logic [3:0]  led;
    logic [15:0] seg;
    logic        mux;
    logic        we;
    logic [3:0]  op;
    logic [4:0]  addr;

    // Instancia de la FSM
    FSM_top dut (
        .clk(clk),
        .rst(rst),
        .swt(swt),
        .btn0(btn0),
        .btn1(btn1),
        .btn2(btn2),
        .btn3(btn3),
        .led(led),
        .seg(seg),
        .mux(mux),
        .we(we),
        .op(op),
        .addr(addr)
    );

    // Reloj de 10 ns
    initial clk = 0;
    always #5 clk = ~clk;

initial begin
$dumpfile("FSM_tb.vcd");
$dumpvars(0, FSM_tb);

        // 1) Hacer reset asíncrono
        rst  = 1;
        swt  = 0;
        btn0 = 0; 
        btn1 = 0; 
        btn2 = 0; 
        btn3 = 0;
        
        #20 
        
        rst = 0;              // tras dos ciclos, quitamos el reset
       
        // 2) Pulsamos el switch de inicio
       #10 
       
        swt = 0;

//        // 3) Elegimos operaciones en ALU
//        #50 btn0 = 1; #10 btn0 = 0;
//        #50 btn1 = 1; #10 btn1 = 0;
//        #50 btn2 = 1; #10 btn2 = 0;
//        #50 btn3 = 1; #10 btn3 = 0;

//        // 4) Dejamos correr unos ciclos más
//        #200;

//        $display("Fin de simulación: led=%b, op=%b, addr=%0d", led, op, addr);
//        $finish;
//    end


#20

btn0 = 1;
btn1 = 0;
btn2 = 0;
btn3 = 0;

#500

#20

btn0 = 0;
btn1 = 1;
btn2 = 0;
btn3 = 0;

#500

$finish;
end
endmodule
```
## 8 Simulaciones

<div align="center">
<img src="https://raw.githubusercontent.com/KRSahalie/Laboratorio2-TDD/main/Ejercicio5/Imagenes/Simulación.png">
</div>

<div align="center">
<img src="https://raw.githubusercontent.com/KRSahalie/Laboratorio2-TDD/main/Ejercicio5/Imagenes/Simulación 2.png">
</div>
