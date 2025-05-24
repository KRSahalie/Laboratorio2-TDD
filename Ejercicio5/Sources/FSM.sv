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
output logic        mux,
output logic        we,
output logic [3:0]  op,
output logic [4:0]  addr,
output logic [4:0]  addr_rs2,
output logic [4:0]  addr_rs1
    );

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

state_t  state, next_state;

logic [3:0]  jump, next_jump;
logic [15:0] count, next_count;
logic [3:0]  max, next_max;
logic [4:0]  addr_n, next_addr;
logic [4:0]  addr_1, next_rs1;
logic [4:0]  addr_2, next_rs2;



//Definición del rst y valores iniciales
always @(posedge clk)begin
    if (rst) begin
         state    <= INICIO;
         count    <= 0;
         jump     <= 0;
         max      <= 0;
         addr_n   <= 0;
         addr_1   <= 0;
         addr_2   <= 0;
         end 
    else begin
        state     <= next_state;
        jump      <= next_jump;
        count     <= next_count;
        max       <= next_max;
        addr_n    <= next_addr;
        addr_1    <= next_rs1;
        addr_2    <= next_rs2;
    end
end
    
//Definición de siguiente estado
always_comb begin
        next_state = state;
        case (state)
            //1°Modo
            INICIO:     next_state = (swt == 0)    ? LSFR    : DIRECCION;
            LSFR:       next_state = ADDRESS;
            ADDRESS:    next_state = (jump >= 1)   ? REGISTRO    : LSFR;
            REGISTRO:   next_state = ALU;
            ALU:        next_state = (btn0 || btn1 || btn2 || btn3) ? TIEMPO: ALU;
            TIEMPO:     next_state = JUMP;
            JUMP:       next_state = (count >= 10) ? ESPERA : TIEMPO;
            ESPERA:     next_state = (jump >= 1)   ? ALMACEN : TIEMPO;
            ALMACEN:    next_state = DISPLAY;
            DISPLAY:    next_state = (count >= 10) ? RETORNO : DISPLAY;
            RETORNO:    next_state = (max >= 10)   ? RETORNO : INICIO;
            //2°Modo
            DIRECCION:  next_state = LECTURA;
            LECTURA:    next_state = (count >= 20) ? SUMA    : LECTURA;
            SUMA:       next_state = (max >= 32 )  ? INICIO  : LECTURA;
            default:    next_state = INICIO;
        endcase
end
//Definición de salida de estados
always_comb begin
 next_jump  = jump;
 next_count = count;
 next_max   = max;
 next_addr  = addr_n;
 next_rs1   = addr_1;
 next_rs2   = addr_2;
        case (state)
        //1°Modo
            INICIO:begin      
                        led = 4'b0000; //0
                        mux = 0;
                        we = 0;
                        op = 4'h0;
                        next_addr = addr_n;
                        next_jump = 0;
                        next_count = 0;
                        next_max = max;
                        end
            LSFR:begin
                        led = 4'b0001;
                        next_addr = addr_n + 1;
                        we = 0;
                        end
            ADDRESS:begin 
                        led = 4'b0010;//2
//                        mux = 0;
                        we = 1;
                        next_jump = jump + 1;
//                        count = count; 
                        end                 
            REGISTRO:begin   
                        led = 4'b0011;//3 
                        we = 0;
                        next_addr = addr + 1;//2;
                        next_jump = jump - 2;
                        next_rs2 = addr_n;
                        end
            ALU:begin //4
            mux = 1; 
            we = 1;        
            next_rs1 = addr_n - 2;
            next_rs2 = addr_n - 2; 
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
//                        mux =  0;
                        we = 0;
                        next_count = count + 1;
                        end
            JUMP:begin 
                        led = 4'b0110;//6
                        next_rs2 = addr_2;
//                        jump = jump + 1;
//                        addr = addr + 1;
                        end
            ESPERA:begin      
                        led = 4'b0111;//7
                        next_addr = addr_n + 1;
                        next_rs2 = addr_2 + 1;
                        next_jump = jump + 1;
                        next_count = count - 2;
                        end
            ALMACEN:begin
                        led = 4'b1000;//8
//                        we = 1;
                        next_addr = addr_n - 2;
//                        addr = addr + 1 ;
                        end
            DISPLAY:begin 
                        led = 4'b1001;//9
                        we = 0;
                        next_rs2 = addr_2;
//                        jump = jump;
                        next_count = count + 1;
                        end
            RETORNO:begin    //10
                        led = 4'b1010;
                        next_jump = jump - 2;
                        next_max = max + 1;
                        next_count = count - 2;
                        end
            //2°Modo
            DIRECCION:begin
                        led = 4'b1011;
//                        mux =  0;
                        we = 1;
                        next_addr = 0;
//                        count = 0;
                        next_max = 0;
                        end
            LECTURA:begin
                        led = 4'b1111;
                        mux =  0;
                        we = 1;
                        next_addr = addr_n;
                        next_count = count + 2;
                        next_max = max;
                        end
            SUMA:begin  
                        led = 4'b1001;
//                        mux =  1;
                        we = 1;
//                        op = 4'h0;
                        next_addr = addr_n + 1;
                        next_count = count;
                        next_max = max + 1;
                        end
        endcase
end  
assign addr_rs1 = next_rs1;
assign addr_rs2 = addr_2;
assign addr     = addr_n;
endmodule
