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
