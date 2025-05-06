`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.04.2025 23:16:46
// Design Name: 
// Module Name: FSM
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


module FSM(
input logic clk,
input logic rst,
input logic swt,
input logic btn0,
input logic btn1,
input logic btn2,
input logic btn3,

output logic [3:0]  led,
output logic [6:0]  seg,
output logic        mux,
output logic        we,
output logic [3:0]  op,
output logic [4:0]  addr,
output logic [4:0]  addr_rs2,
output logic [4:0]  addr_rs1
//output logic [3:0]  an
//output logic        en
    );

//logic [7:0] data; 
//logic [6:0] sym; 
//logic [3:0] an;
 
//Deco decof(
//.clk_i (clk), //Reloj global - Switch a decision
//.rst_i (rst), //Reset global - Switch a decision
//.data    (data), 

//.seg   (segm), //salida a los segmentos
//.an    (an)// salida a los anodos
//);

typedef enum logic [3:0]{
INICIO    = 4'd0,
LSFR      = 4'd1,
ADDRESS   = 4'd2,
REGISTRO  = 4'd3,
ALU       = 4'd4,
TIEMPO    = 4'd5,
JUMP      = 4'd6,
ESPERA    = 4'd7,
ALMACEN   = 4'd8,
DISPLAY   = 4'd9,
RETORNO   = 4'd10, 
DIRECCION = 4'd11,
LECTURA   = 4'd12,
SUMA      = 4'd13
}state_t;

state_t state, next_state;

logic [3:0]  jump;
logic [15:0] count;
logic [3:0] max;

//Definición del rst y valores iniciales
always @(posedge clk)begin
    if (rst) begin
         state    <= INICIO;
         count    <= 0;
         jump     <= 0;
         max      <= 0;
         addr     <= 0;
         addr_rs2 <= 0;
         addr_rs1 <= 0;
//         segm     <= 0;
         end 
    else begin
        state    <= next_state;
//        count    <= next_count;
//        jump     <= next_jump;
//        max      <= next_max;
//        addr     <= next_addr;
    end
end
    
//Definición de siguiente estado
always_comb begin
        next_state = state;
        case (state)
            //1°Modo
            INICIO:     next_state = (swt == 0)    ? LSFR    : DIRECCION;
            LSFR:       next_state = ADDRESS;
            ADDRESS:    next_state = (jump >= 2)   ? REGISTRO    : LSFR;
            REGISTRO:   next_state = ALU;
            ALU:        next_state = (btn0 || btn1 || btn2 || btn3) ? TIEMPO: ALU;
            TIEMPO:     next_state = JUMP;
            JUMP:       next_state = (count >= 10) ? ESPERA : TIEMPO;
            ESPERA:     next_state = (jump >= 2)   ? ALMACEN : TIEMPO;
            ALMACEN:    next_state = DISPLAY;
            DISPLAY:    next_state = (count >= 10) ? RETORNO : DISPLAY;
            RETORNO:    next_state = (max >= 10)   ? RETORNO : INICIO;
            //2°Modo
            DIRECCION:  next_state = LECTURA;
            LECTURA:    next_state = (count >= 10) ? SUMA    : LECTURA;
            SUMA:       next_state = (max >= 32 )  ? INICIO  : LECTURA;
        endcase
end
//Definición de salida de estados
always_comb begin
        case (state)
        //1°Modo
            INICIO:begin      
                        led = 4'b0000; //0
//                        segm = segm;
                        mux = 0;
                        we = 0;
                        op = 4'h0;
                        addr = addr;
                        jump = 0;
                        count = count;
                        max = max;
                        end
            LSFR:begin
                        led = 4'b0001;
                        we = 0;
                        end
            ADDRESS:begin 
                        led = 4'b0010;//2
//                        mux = 0;
                        we = 1;
//                        op = 4'h0;
                        addr = addr + 1;
                        jump = jump + 1 ;
//                        count = count; 
                        end                 
            REGISTRO:begin   
                        led = 4'b0011;//3 
//                        seg = 16'h0000;
//                        mux =  1;
                        we = 0;
//                        op = 4'h0;
                        addr = addr + 1;//2;
                        jump = jump - 2;
//                        count = count;
//                        max = max;
                        end
            ALU:begin //4
            mux = 1; 
//            we = 1;        
            addr_rs1 = addr - 2;
            addr_rs2 = addr - 1;
                        if (btn0) begin
                            op = 4'h2;
                            led  = 4'b0010;
                            end
                        else if (btn1) begin
                            op = 4'h6;
                            led  = 4'b0110;
                            end
                        else if (btn2) begin
                            op = 4'h0;
                            led  = 4'b1111;
                            end
                        else if (btn3) begin
                            op = 4'h1;
                            led  = 4'b0001;
                            end
                        end
            TIEMPO:begin 
                        led = 4'b0101;//5
//                        we = 0;
//                        seg = 16'h0000;
//                        mux =  0;
//                        we = 0;
                        count = count + 10;
//                        jump = jump;
//                        addr = addr;
//                        max = max;
                        end
            JUMP:begin 
                        led = 4'b0110;//6
//                        segm = segm;
//                        mux =  0;
//                        we =0;
//                        count = count;
//                        jump = jump + 1;
//                        addr = addr + 1;
//                        max = max;
                        end
            ESPERA:begin      
                        led = 4'b0111;//7
//                        seg = 16'h0000;
//                        mux = 1;
//                        we = 1;
//                        op = 4'b0000;
//                        addr = addr - 2;
                        jump = jump + 1;
//                        count = count - 20;
                        //result = result;
//                        max = max;
                        end
            ALMACEN:begin
                        led = 4'b1000;//8
//                        seg = 16'h1111;
//                        mux =  1;
                        we = 1;
//                        op = 4'b0000;
//                        addr = addr + 1 ;
//                        count = count - 1;
//                        max = max;
                        end
            DISPLAY:begin 
                        led = 4'b1001;//9
//                        segm = segm;
//                        mux =  1;
                        we = 0;
//                        op = 4'b0000;
//                        addr = addr;
//                        jump = jump;
                        count = count + 10;
//                        max = max;
                        end
            RETORNO:begin    //10
                        led = 4'b1010;
//                        seg = 16'h0000;
//                        mux =  1;
//                        we = 1;
//                        op = 4'b0000;
//                        addr = addr + 1;
//                        jump = jump;
//                        count = count;
                        max = max + 1;
                        end
            //2°Modo
            DIRECCION:begin
                        led = 4'b1011;
//                        seg = 16'h0000;
                        mux =  0;
                        we = 1;
//                        op = 4'b0000;
                        addr = 0;
//                        jump = jump;
                        count = 0;
                        max = 0;
                        end
            LECTURA:begin
                        led = 4'b1111;
//                        segm = segm;
                        mux =  0;
                        we = 1;
//                        op = 4'h0;
                        addr = addr;
//                        jump = jump;
                        count = count + 10;
                        max = max;
                        end
            SUMA:begin  
                        led = 4'b1001;
//                        segm = segm;
//                        mux =  1;
                        we = 1;
//                        op = 4'h0;
//                        addr = addr + 1;
//                        jump = jump;
                        count = count;
                        max = max + 1;
                        end
        endcase
end         
endmodule
