`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.04.2025 18:04:57
// Design Name: 
// Module Name: Registro_tb
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


module Registro_tb;

parameter N = 6;
parameter W = 8;

logic          clk;
logic          rst;
logic [N-1:0]  addr_rs1;
logic [N-1:0]  addr_rs2;
logic [N-1:0]  addr_rd;
logic [W-1:0]  data_in;
logic          we;

logic [W-1:0]  rs1;
logic [W-1:0]  rs2;

Registro regX(
.clk        (clk),
.rst        (rst),
.addr_rs1   (addr_rs1),
.addr_rs2   (addr_rs2),
.addr_rd    (addr_rd),
.data_in    (data_in),
.we         (we),

.rs1         (rs1),
.rs2         (rs2)
);

    
initial clk = 0;
always #5 clk = ~clk;

initial begin
$dumpfile("Registro_tb.vcd");
$dumpvars(0, Registro_tb);

rst = 1;
we  = 0;
addr_rd = 0; 
data_in = 0;
        
#10 

rst = 0;
we  = 1;
addr_rd = 1; 
data_in = 8'h45;

#10

addr_rd = 2; 
data_in = 8'h1a;

#10

we = 0;
addr_rs1 = 1;
addr_rs2 = 2;

#15

addr_rs1 = 0;
#10

$finish;
end
endmodule
