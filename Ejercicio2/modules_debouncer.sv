`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2025 21:15:48
// Design Name: 
// Module Name: modules_debouncer
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

module modules_debouncer(
    input     logic    clk,
    input     logic    bt1_i,
    input     logic    rst_i,
    output    logic    signal_o
    );
    
    logic en_out;
    logic Q1,Q1_neg, Q2, Q2_neg;
    
    module_FFD ff1(
        .clk   (clk),
        .D     (bt1_i),
        .EN    (en_out),
        .Q     (Q1)
        );
        
    module_FFD ff2(
        .clk   (clk),
        .D     (Q1),
        .EN    (en_out),
        .Q     (Q2)
        );
    
    assign Q2_neg = ~Q2;    
    assign signal_o = Q1 & Q2_neg; 
        

    clock_enable clkEN(
        .Clk_10M (clk),
        .slow_clk_en (en_out) 
    );
    
       

endmodule 

    module clock_enable(input Clk_10M,output slow_clk_en);
    logic [26:0]counter=0;
    always @(posedge Clk_10M)
    begin
       counter <= (counter>=249999)?0:counter+1;
    end
    assign slow_clk_en = (counter == 249999)?1'b1:1'b0; 
endmodule

