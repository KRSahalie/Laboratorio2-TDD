`timescale 1ns/1ps
module mux4 #(
parameter W = 7) 
(
input  logic [W-1:0]  in0, 
input  logic [W:0]    in1, 
input  logic          sel,
    
output logic [W:0]   out
);
    always_comb begin
        case (sel)
            1'b0: out = in0;
            1'b1: out = in1;
            default: out = {W{1'bx}}; // Indefinido en caso de error
        endcase
    end
endmodule
