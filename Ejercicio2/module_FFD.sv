`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2025 21:16:40
// Design Name: 
// Module Name: module_FFD
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


module module_FFD(
    input     logic    clk, // Data Input
    input     logic    D, // Clock Input
    input     logic    EN,
    output    logic    Q       // Q output
    );

    always_ff @ ( posedge clk) begin
        if (EN)  Q <= D;
       end
   
endmodule
