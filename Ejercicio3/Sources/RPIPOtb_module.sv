`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Student: Kendy Arias
// 
// Create Date: 02/25/2024 04:56:06 PM
// Design Name: Logica del PIPO
// Module Name: pipo_module()
// Target Devices: Basys 3 
// Description: Modulo que implementa la logica del registro de entrada/salida paralela de 16 bits
//
//////////////////////////////////////////////////////////////////////////////////
module pipo_module_tb;

    // Definición de señales de entrada
    reg clk;
    reg enable;
    reg [15:0] data_in;

    // Definición de señales de salida
    wire [15:0] data_out;

    // Instanciación del módulo bajo prueba (UUT)
    RPIPO_module UUT (
        .clk(clk),
        .we(enable),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Generación de clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Genera un clock de 10ns de periodo
    end

    // Testbench
    initial begin
        // Inicialización de señales
        enable = 0;

        // Iterar a través de todos los valores posibles de 16 bits para data_in
        for (data_in = 0; data_in < 65536; data_in = data_in + 1) begin
            // Esperar un ciclo de clock antes de activar enable
            #10;
            // Habilitar y cambiar data_in
            enable = 1;
            // Esperar un ciclo de clock para que se propague la salida
            #10;
            // Verificar resultados
            if (data_out !== data_in) begin
                $display("Error: data_out no es igual a data_in para data_in = %h", data_in);
                $finish;
            end
            // Deshabilitar enable
            enable = 0;
        end

        // Finalizar simulación
        $display("Simulación completada con éxito");
        $finish;
    end

endmodule


