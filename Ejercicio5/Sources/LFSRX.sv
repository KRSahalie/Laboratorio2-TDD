`timescale 1ns / 1ps
//Instituto Tecnologico de Costa Rica
//Escuela de Ingenieria en Electronica. Taller de Diseno Digital

//Laboratorio 2. Linear Feedback Shift Register (LFSR)
//todo posteriormente se debe considerar el tiempo deseado de display y el tiempo de reloj para cada modulo todo

module LFSRX (
    input  logic clk,
    input  logic rst ,

    output logic [15 : 0] A_reg //la salida de 16 bits
);

logic [15 : 0] lfsr_reg; //registros internos


always_ff @(posedge clk) begin
    if (rst) 
        lfsr_reg <= 16'b101010101010101;  //valor de semilla al iniciar para ser seudorandom
    else 
        lfsr_reg <= {lfsr_reg[14:0], (lfsr_reg [12] ^ lfsr_reg[7])} ;
end

assign A_reg= lfsr_reg;                                                       

endmodule
