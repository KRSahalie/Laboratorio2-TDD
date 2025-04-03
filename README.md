
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

### 3.2 Ejercicio 3- Decodificador hex-to-7-segments
#### 1.  Encabezado del módulo
```SystemVerilog
module logica_deco(
    input [3:0] valor, 
    output reg [0:6] representacion 
    );
```
#### 2.  Entradas y salidas
- `valor`: Entrada de switches (anodos se repiten de 4 en 4)
- `representacion`: Salida a los switches (segmentos repetidos de 4 en 4 en el display)
#### 3.  Criterios de diseño
#### 4.  Testbench



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

