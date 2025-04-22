`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.03.2025 14:28:22
// Design Name: 
// Module Name: LFSR
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


module LFSR(
input logic  clk,
input logic  rst,
output logic [6:0] A_reg
    );

always @(posedge clk)begin
    if (rst)
        A_reg <= 7'd0;
    else
        A_reg <= $urandom % 128;
end

endmodule
