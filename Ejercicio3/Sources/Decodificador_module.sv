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
//Inicio del modulo
module logica_deco2(
    input clk, // Se agrega una entrada para el reloj
    input rst, // Reset
    input [15:0] data_in, //entrada de la pipo
    output reg [0:6] seg, //salida a los segmentos
    output reg [1:0] an // salida a los anodos
);

reg [3:0] digit;
reg [1:0] anode_counter; // Contador para alternar entre los ánodos
reg [1:0] s; // Selector del multiplexor
reg [1:0] an_sel; // Selector del ánodo

// Contador para alternar entre los ánodos de manera rápida
reg [7:0] anode_counter_fast;

// Selector del ánodo basado en el contador
always @(posedge clk or posedge rst) begin
    if (rst)
        anode_counter <= 2'b00;
    else begin
        if (anode_counter_fast == 8'hFF) begin
            anode_counter <= anode_counter + 1;
            anode_counter_fast <= 8'h00;
        end else begin
            anode_counter_fast <= anode_counter_fast + 1;
        end
    end
end

// Asignar el valor de s basado en el contador de ánodos
always @(posedge clk) begin
    case (anode_counter)
        2'b00: s <= 2'b00; // Ánodo 0 activo
        2'b01: s <= 2'b01; // Ánodo 1 activo
        2'b10: s <= 2'b10; // Ánodo 2 activo
        2'b11: s <= 2'b11; // Ánodo 3 activo
    endcase
end

// Asignar el valor de s a an_sel
always @(*) begin
    an_sel = s;
end

// Asignar el valor de an_sel a an
always @(posedge clk) begin
    an <= an_sel;
end

//Multiplexor
always @ (*)
    case (s)
        2'b00: digit = data_in[3:0]; // Selecciona sw[3:0] para el ánodo 0
        2'b01: digit = data_in[7:4]; // Selecciona sw[7:4] para el ánodo 1
        2'b10: digit = data_in[11:8]; // Selecciona sw[11:8] para el ánodo 2
        2'b11: digit = data_in[15:12]; // Selecciona sw[15:12] para el ánodo 3
        default: digit = data_in[3:0]; // Default para el ánodo 0
    endcase
                   
//7 segmentos
always @(*)
    case(digit)
        4'h0: seg = 7'b0000001; //0
        4'h1: seg = 7'b1001111; //1
        4'h2: seg = 7'b0010010; //2
        4'h3: seg = 7'b0000110; //3
        4'h4: seg = 7'b1001100; //4
        4'h5: seg = 7'b0100100; //5
        4'h6: seg = 7'b0100000; //6
        4'h7: seg = 7'b0001111; //7
        4'h8: seg = 7'b0000000; //8
        4'h9: seg = 7'b0000100; //9
        4'hA: seg = 7'b0001000; //A
        4'hB: seg = 7'b1100000; //B
        4'hC: seg = 7'b0110001; //C
        4'hD: seg = 7'b1000010; //D
        4'hE: seg = 7'b0110000; //E
        4'hF: seg = 7'b0111000; //F
        default: seg = 7'b0000001;  //Default de valor 0
    endcase
endmodule

