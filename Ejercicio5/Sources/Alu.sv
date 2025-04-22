`timescale 1ns / 1ps

module Alu #(
parameter n = 4)
(
 input logic [n-1:0] A,
 input logic [n-1:0] B,
 input logic [3:0] Alu_control,
 input logic       ALUFlagsIn, 
 
 output logic [n-1:0] result,
 output logic       ALUFlags,
 output logic       C
    ); 
 
 always_comb begin
    case(Alu_control)
        4'h0: result = A & B; //and
        4'h1: result = A | B; //or
        4'h2: {C , result} = signed'(A) + signed'(B); //suma A2
        4'h3: {C , result} = (ALUFlagsIn == 0) ? A + 1 : B + 1; //suma 1
        4'h4: {C , result} = (ALUFlagsIn == 0) ? A - 1 : B - 1; //resta 1
        4'h5: result = (ALUFlagsIn == 0) ? ~A : ~B; //not
        4'h6: {C , result} = signed'(A) - signed'(B); //resta A2
        4'h7: result = A ^ B; //xor (eliminar C)
        4'h8: {C , result} = (ALUFlagsIn == 0)? A << B : (A << B) | ((1 << B) - 1); //Desplazamiento a la izquierda de 1 o 0      
        4'h9: begin //Desplazamiento a la derecha de 1 o 0
            assign C = A[B];
            assign result = (ALUFlagsIn == 0)? A >> B : (A >> B) | (((1 >> B) - 1) << (n - B));           
            end
        default: result = 0;
    endcase
    
assign ALUFlags = (result == 0) ? 1 : 0; 
end
endmodule
