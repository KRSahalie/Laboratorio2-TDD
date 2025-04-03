`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Student: Kendy Arias
// 
// Create Date: 02/25/2024 04:56:06 PM
// Design Name: Logica del Decodificador parte 2
// Module Name: logica_deco parte 2
// Target Devices: Basys 3 
// Description: Modulo que implementa la logica del decodificador con un multiplexor para poder elegir cual display y cuales entradas estan relacionadas
//
//////////////////////////////////////////////////////////////////////////////////
module module_top(
    input clk_i, //Reloj global - Switch a decision
    input rst_i, //Reset global - Switch a decision
    input enable_i, //Enable de las LFSR
    output reg [0:6] seg, //salida a los segmentos
    output reg [3:0] an // salida a los anodos
);

    // Declaración de señales
    wire clk_slow;
    wire clk_slow2;
    
    // Señales internas del reloj
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
        .clk_10MHz(clk_10MHz),  // output clk_10MHz
        .reset(reset),         // input reset
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
    
    // Instancia del RPIPO_module
    RPIPO_module RPIPO_inst (
        .clk(clk_10MHz),     // Conecta el slow clock al reloj del RPIPO_module
        .we(clk_slow2),            // Conecta la señal de escritura
        .data_in({lfsr_data_out[3], lfsr_data_out[2], lfsr_data_out[1], lfsr_data_out[0]}),
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
