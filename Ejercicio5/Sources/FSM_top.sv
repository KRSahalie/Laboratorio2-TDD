`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2025 22:56:51
// Design Name: 
// Module Name: FSM_tb
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


module FSM_top#(
parameter N = 16)
(
input logic clk,  
input logic rst,
input logic swt,
input logic btn0,
input logic btn1,
input logic btn2,
input logic btn3,

output logic [3:0]  led,
output logic [3:0]  an_s,
output logic [6:0]  seg_s,
output logic [3:0]  op
    );
  
logic [N-1:0] A_reg;
logic [N-1:0]   result;
logic [N-1:0]   out;
logic [N-1:0] rs1c;
logic [N-1:0] rs2c;
logic [N-1:0]   data_in;
logic [N-1:0]   data; 
logic [4:0]   addr;
logic [4:0]   addr_rs1;
logic [4:0]   addr_rs2;
logic         mux;
logic         we;

Deco decof(
.clk   (clk),
.rst   (rst),
.data  (rs2c), 

.seg   (seg_s), //salida a los segmentos
.an    (an_s)
);

FSM fsm_U(
.clk  (clk),
.rst  (rst),
.swt  (swt),
.btn0 (btn0),
.btn1 (btn1),
.btn2 (btn2),
.btn3 (btn3),

.led  (led),
.mux  (mux),
.we   (we),
.op   (op),
.addr (addr),
.addr_rs1 (addr_rs1),
.addr_rs2 (addr_rs2)
);

LFSRX l_sfm(
.clk   (clk),
.rst   (rst),
.A_reg (A_reg)
);

//LFSR l_sfm(
//.i_Clk (clk),
//.i_Rst (rst),
////.i_Enable (en),
 
//.i_Seed_Data(7'b1010101),
 
//.o_LFSR_Data (A_reg)
////.o_LFSR_Done (o_LFSR_Done)
//);

mux4 mux_U(
.in0 (A_reg), 
.in1 (result), 
.sel  (mux),
.out  (data_in)
);

Registro reg_fsm (
.clk(clk),
.rst(rst),
.addr_rs1r(addr_rs1),
.addr_rs2r(addr_rs2),
.addr_rd(addr),
.data_in(data_in),
.we(we),
.rs1(rs1c),
.rs2(rs2c)
    );

Alu Alu_U(
.A (rs1c),
.B (rs2c),
.Alu_control (op),
.result (result)
);

endmodule