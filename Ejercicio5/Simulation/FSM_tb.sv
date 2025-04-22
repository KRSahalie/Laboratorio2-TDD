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


module FSM_tb;
logic clk;
logic rst;
logic swt;
logic btn0;
logic btn1;
logic btn2;
logic btn3;

logic [3:0]  led;
logic [15:0] seg;
logic        mux;
logic        we;
logic [3:0]  op;
logic [4:0]  addr;

logic [6:0] A_reg;
logic [6:0] result;
logic [6:0] out;
logic [6:0] rs1;
logic [6:0] rs2;

FSM fsm_U(
.clk  (clk),
.rst  (rst),
.swt  (swt),
.btn0 (btn0),
.btn1 (btn1),
.btn2 (btn2),
.btn3 (btn3),

.led  (led),
.seg  (seg),
.mux  (mux),
.we   (we),
.op   (op),
.addr (addr)
);

LFSR l_fsm(
.clk   (clk),
.rst   (rst),
.A_reg (A_reg)
);

mux4 mux_U(
.in0 (A_reg), 
.in1 (result), 
.sel  (mux),
.out  (out)
);
// Banco de registros
Registro #(.N(5), .W(8)) reg_fsm (
.clk(clk),
.rst(rst),
.addr_rs1(addr),
.addr_rs2(addr + 1),
.addr_rd(addr),
.data_in(out),
.we(we),
.rs1(rs1),
.rs2(rs2)
    );

 // ALU
Alu Alu_U(
.A (rs1),
.B (rs2),
.Alu_control (op),
.result (result)
);

initial clk = 0;
always #20 clk = ~clk;

initial begin
        // Inicializar señales
        rst  = 1;
        swt  = 0;
        btn0 = 0; btn1 = 0; btn2 = 0; btn3 = 0;

        #20 rst = 0;

        // Activar FSM en modo LSFR ? REGISTRO ? ALU ? etc.
        #10 swt = 1;  // Cambiar modo de inicio
        #10 swt = 0;

        // Simular elección de operación ALU con botón
        #50 btn0 = 1; #10 btn0 = 0;
        #50 btn1 = 1; #10 btn1 = 0;
        #50 btn2 = 1; #10 btn2 = 0;
        #50 btn3 = 1; #10 btn3 = 0;

        // Esperar un tiempo
        #200;

        $display("FSM test finalizado. Estado led = %b, op = %b, addr = %d", led, op, addr);
        $finish;
    end
//initial begin
//$dumpfile("FSM_tb.vcd");
//$dumpvars(0, FSM_tb);

//rst = 1;

//#20

//rst = 0;

//#40

//swt = 0;

//#40

//btn0 = 1;
//btn1 = 0;
//btn2 = 0;
//btn3 = 0;

//#1000

//swt = 1;

//#40

//$finish;
//end
endmodule