`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2025 21:15:09
// Design Name: 
// Module Name: top_module_debouncer
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


module top_module_debouncer(
    input     logic             clk,
    input     logic             bt1_i,
    input     logic             rst_i,
    output    logic    [7:0]    conta_o                         
    );
  
  logic clk_10MHz;  
  logic en_10kHz;
  logic signal;
  
  modules_debouncer db2(
        .clk         (clk_10MHz),
        .bt1_i       (bt1_i),
        .rst_i       (rst_i),
        .signal_o    (signal)
        //.conta_o     (conta_o)
        );
      
  
  module_contador_prueba c1(
      .clk        (clk_10MHz),
      .rst_n_i    (rst_i),
      .en_i       (signal),
      .conta      (conta_o)  
      );
  
   WCLK generate_clock_10Mhz(
        // Clock out ports
        .CLK_10MHZ              (clk_10MHz),            // output CLK_10MHZ
        // Status and control signals
        .locked                 (),                     // output locked
        // Clock in ports
        .CLK_100MHZ             (clk)         // input CLK_100MHZ
    );
    
endmodule