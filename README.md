
## 1. Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays
- **FA**: Full Adder
- **RCA**: Ripple Carry Adder
- **CLA**: Carry Look-ahead Adder

## 2. Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

[1] Features, 1., & Description, 3. (s/f). SNx4HC14 Hex Inverters with Schmitt-Trigger Inputs. Www.ti.com. https://www.ti.com/lit/ds/symlink/sn74hc14.pdf?ts=1709130609427&ref_url=https%253A%252F%252Fwww.google.com%252F



## 3. Desarrollo

### 3.1 Ejercicio 1- Uso del PLL IP-core
Descipción del módulo.
#### 1. Módulo
```SystemVerilog
Agregar código del módulo
```
#### 2. Criterios y restricciones de diseño
#### 3. Testbench y Implementación en la FPGA


### 3.2 Ejercicio 2- Diseño antirebotes y sincronizador
Descripción del módulo.
#### 1. Encabezado del módulo
```SystemVerilog
Agregar código.
```
#### 2. Parámetros
Agregar parámetros en este formato.
- `WIDTH`: Parámetro que define el ancho del bus de datos en el multiplexor. Tiene un valor predeterminado de 8, pero en el test bench este toma valores de 4, 8 y 16.
#### 3. Entradas y salidas
Agregar en este formato.
- `in_0`, `in_1`, `in_2`, `in_3`: Entradas de datos al multiplexor.
- `sel`: Entrada de 2 bits que especifica qué entrada del multiplexor se seleccionará.
- `out`: Salida del módulo, representa el dato seleccionado por el multiplexor según la entrada `sel`.
#### 4. Criterios de diseño
Agregar si ameita.
#### 5. Testbench
El siguiente fragmento de código muestra una simplificación del test bench con la finalidad de poder visualizar su esctructura global y funcionamiento.


# Ejercicio 3: Decodificador hex-to-7-segments

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



### 3.4 Ejercicio 4. Banco de registros

Agregar lo que amerite.
#### 1.Código final Bit Adder
#### 2. Código final del RCA
#### 3. Código final del LCA
#### 4. Criterios de diseño
#### 5. Testbench



### 3.5 Ejercicio 5. Mini unidad de cálculo
 
#### 1. Encabezado del módulo
#### 2. Criterios de diseño
#### 3. Testbench

