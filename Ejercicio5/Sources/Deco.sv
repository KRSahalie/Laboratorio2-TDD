`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2025 19:51:46
// Design Name: 
// Module Name: Deco
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Deco(
input logic clk_i, //Reloj global - Switch a decision
input logic rst_i, //Reset global - Switch a decision
input logic [7:0]  data,
input logic [6:0]  sym,

output logic [6:0] seg, //salida a los segmentos
output logic [3:0] an // salida a los anodos
);

//Relojes
logic clk_slow;
logic clk_slow2;
    
// Señales internas del reloj
logic clk_10MHz;
logic locked;
    
    // Instancia del reloj
clk_wiz_0 instance_name (
      .clk_10MHz(clk_10MHz),  // output clk_10MHz
      .reset(rst_i),         // input reset
      .locked(locked),        // output locked
      .clk_100MHz(clk_i)      // input clk_100MHz (connect directly)
  );

    // Instancia del slowclock_module
slowclock_module slowclock_inst (
   .clk_in(clk_10MHz),       // Conecta el reloj principal al módulo slowclock_module
   .clk_slow(clk_slow) // Salida del slow clock
  );
     
     
    // Instancia del slowclock_module2
    ledblink2_module slowclock_inst2 (
        .clk_in(clk_10MHz),       // Conecta el reloj principal al módulo slowclock_module
        .clk_slow2(clk_slow2) // Salida del slow clock
    );
    
   //Logica del decodificador
    //Señales internas de decodificador
    logic [3:0] digit; // Valor a mostrar en el display
    logic [3:0] an_counter; // Contador para alternar entre los anodos
    logic       sym_count = 0;
        
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
                    digit = data[3:0]; // Asigna los bits 0-3 de data_out al primer anodo
                    an = 4'b1110; // Activa el primer anodo
                end
                4'b0001: begin
                    digit = data[7:4]; // Asigna los bits 4-7 de data_out al segundo anodo
                    an = 4'b1101; // Activa el segundo anodo
                end
                4'b0010: begin
                    digit = 0; // Asigna los bits 8-11 de data_out al tercer anodo
                    an = 4'b1011; // Activa el tercer anodo
                end
                4'b0011: begin
                    digit = 'hA;
//                if (sym_count == 0)begin 
//                    digit = 'hA;
//                    sym_count = sym_count + 1;
//                    end
//                else begin
//                    digit = 'hB;
//                    sym_count = 0;
//                    end
                     // Asigna los bits 12-15 de data_out al cuarto anodo
                   an = 4'b0111; // Activa el cuarto anodo
                end
                default: begin
                    digit = 0; // En caso de un valor no esperado, asigna los bits 0-3 de data_out al primer anodo
                    an = 4'b1110; // Activa el primer anodo
                end
            endcase
                      
     //7 segmentos
     always @(*)
         case(digit)        //Anodo comun: para encendido 0 y apagado 1, orden del display 7'babcdefg
             0: seg = 7'b0000001;
             1: seg = 7'b1001111;
             2: seg = 7'b0010010;
             3: seg = 7'b0000110;
             4: seg = 7'b1001100;
             5: seg = 7'b0100100;
             6: seg = 7'b0100000;
             7: seg = 7'b0001111;
             8: seg = 7'b0000000;
             9: seg = 7'b0000100;
             'hA: seg = 7'b0001000;
             'hB: seg = 7'b1100000;
             'hC: seg = 7'b0110001;
             'hD: seg = 7'b1000010;
             'hE: seg = 7'b0110000;
             'hF: seg = 7'b0111000;
                 default: seg = 7'b0000001;  //Default de valor 0
         endcase
endmodule