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
//Inicio del modulo
module RPIPO_module(
  input wire clk,
  input wire we,
  input wire [15:0] data_in,
  output reg [15:0] data_out
);

    always @(posedge clk) begin
      if (we) begin
        data_out <= data_in;
      end
    end

endmodule
