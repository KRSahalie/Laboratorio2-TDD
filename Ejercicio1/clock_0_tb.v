`timescale 1ns / 1ps

module tb_clock_0;

// Declarar se�ales de prueba
reg clk_100MHz;
reg clk_100MHz_1;
reg reset_rtl_0;  // Se�al de reset
wire clk_out1_0;  // La se�al de salida de 10 MHz (generada por el PLL)
wire locked;      // Se�al de "locked" del PLL
reg clk_10MHz_ref;  // Reloj de 10 MHz para comparaci�n

// Instanciar el wrapper
clock_0_wrapper uut (
    .clk_100MHz(clk_100MHz),
    .clk_100MHz_1(clk_100MHz_1),
    .clk_out1_0(clk_out1_0),
    .reset_rtl_0(reset_rtl_0),
    .locked(locked)  // Aseg�rate de conectar la se�al "locked"
);

// Generar el reloj de entrada de 100 MHz
always begin
    #5 clk_100MHz = ~clk_100MHz;  // Reloj de 100 MHz
end

// Generar el segundo reloj de entrada (si es necesario)
always begin
    #5 clk_100MHz_1 = ~clk_100MHz_1;  // Reloj de 100 MHz adicional, si es necesario
end

// Generar el reloj de 10 MHz para comparaci�n
always begin
    #50 clk_10MHz_ref = ~clk_10MHz_ref;  // Reloj de 10 MHz (10 veces m�s lento que 100 MHz)
end

// Establecer las condiciones iniciales
initial begin
    // Inicializar se�ales
    clk_100MHz = 0;
    clk_100MHz_1 = 0;
    clk_10MHz_ref = 0;  // Inicializar el reloj de 10 MHz
    reset_rtl_0 = 1;  // Activar el reset al principio

    // Desactivar el reset despu�s de 10 ns
    #10 reset_rtl_0 = 0;

    // Esperar un tiempo para que el PLL se bloquee
    #500;  // Esperar 500 ns para ver el bloqueo

    // Verificar si el PLL est� bloqueado
    if (locked == 1) begin
        $display("PLL bloqueado correctamente.");
    end else begin
        $display("PLL no bloqueado dentro del tiempo esperado.");
    end

    // Esperar un tiempo suficiente para observar varios ciclos de la salida de 10 MHz
    #10000;  // Esperar un tiempo mayor (10,000 ns) para observar m�s ciclos de 10 MHz

    // Terminar la simulaci�n
    $finish;
end

// Verificar se�ales en la simulaci�n
initial begin
    $monitor("Time = %t, locked = %b, clk_out1_0 = %b, clk_10MHz_ref = %b, clk_100MHz = %b, clk_100MHz_1 = %b, reset_rtl_0 = %b", 
              $time, locked, clk_out1_0, clk_10MHz_ref, clk_100MHz, clk_100MHz_1, reset_rtl_0);
end

endmodule
