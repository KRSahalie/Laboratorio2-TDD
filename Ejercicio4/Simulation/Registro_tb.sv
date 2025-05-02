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
