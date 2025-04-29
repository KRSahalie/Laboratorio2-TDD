`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2025 21:19:08
// Design Name: 
// Module Name: module_clock_catodo
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

module module_clock_catodo#(parameter COUNT_CATODO = 20_000_000, BITS_CATODO = 14)(

    input   logic   clk_10Mhz_i,
                    reset_i,
    output  logic   clock_catodo_o 
    
    );

    logic [BITS_CATODO - 1 : 0] counter = 0;
    
    logic                       clk_out = 0;
    
    always_ff @(posedge clk_10Mhz_i)
        
        if(reset_i) begin
            counter <= 0;
            clk_out <= 0;        
        end else
            if(counter  == (COUNT_CATODO - 1)) begin //esto genera un flanco reloj, que se va a dar justo en el counter
                counter <= 0;
                clk_out <= 1; 
            end else begin
                counter <= counter + 1;
                clk_out <= 0;
            end  
    
    assign clock_catodo_o = clk_out;

    
endmodule
