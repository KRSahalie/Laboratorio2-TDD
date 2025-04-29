`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2025 21:19:57
// Design Name: 
// Module Name: tb_modules_debouncer
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


module tb_modules_debouncer;
    logic           clk;
    logic           bt1_i;
    logic           rst_i;
    logic           signal_o;
    logic           CLK_100MHZ;
    logic           CLK_10MHZ;
    logic    [3:0]  cont2;
    
    
    initial begin
        CLK_100MHZ = 0;
        CLK_10MHZ  = 0;
        cont2      = 0; 
    end
    always begin
        #5 CLK_100MHZ = ~CLK_100MHZ;
        if(CLK_100MHZ == 1)begin
            cont2 = cont2 + 1;
        end
        if(cont2 == 4'b0101)begin
            CLK_10MHZ = ~CLK_10MHZ;
            cont2 = 0;
        end
    end
    
    top_module_debouncer debouncer(
    .clk                (CLK_10MHZ),
    .bt1_i              (bt1_i),
    .rst_i              (rst_i),
    .conta_o            (signal_o)
    );
    
    initial begin
        rst_i = 0;
        bt1_i = 0;
        #15;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #200;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #300;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #200;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #2;
        bt1_i = 1;
        #2;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
        #1;
        bt1_i = 1;
        #1;
        bt1_i = 0;
    
    end

   
endmodule
