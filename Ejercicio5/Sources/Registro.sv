`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2024 17:12:59
// Design Name: 
// Module Name: Registro
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


module Registro #(
parameter N = 5,
parameter W = 7)
(
input logic          clk,
input logic          rst,
input logic [N-1:0]  addr_rs1,
input logic [N-1:0]  addr_rs2,
input logic [N-1:0]  addr_rd,
input logic [W-1:0]  data_in,
input logic          we,

output logic [W:0]    rs1,
output logic [W:0]    rs2
    );

logic [W-1:0] Registro [0:2**N-1];

integer i;

always @(posedge clk)begin
    if (rst) begin 
        for(i = 0;i < 2**N;i = i+1)
            Registro[i] <= 0;
        end
    else begin
        if(we && (addr_rd != 0))
            Registro[addr_rd] <= data_in;
        end
end

always_comb begin
    rs1 = (we != 0) ? 0 : Registro[addr_rs1];
    rs2 = (we != 0) ? 0 : Registro[addr_rs2];
end

endmodule
