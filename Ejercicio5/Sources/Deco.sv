`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2025 19:51:46
// Design Name: 
// Module Name: Deco
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

//module Deco(
//    input logic clk,          // Reloj FPGA (ej. 100 MHz)
//    input logic rst,        // Reset activo alto
//    input logic [15:0] data,  // 4 dígitos hexadecimales (16 bits)
//    output logic [6:0] seg,    // Segmentos (a-g, ánodo común)
//    output logic [3:0] an,      // Ánodos (0 = dígito activo)
//    output logic       dp
//);

//logic [1:0] s;
//logic [3:0] digit;
//logic [3:0] aen;
//logic [20:0]clkdiv;

//assign dp=1;
//assign s=clkdiv [20:19];
//assign aen = 4'b1111;

//    always_comb begin
//        case (s)
//            2'd0: begin 
//                digit = data[3:0];    
//                end
//            2'd1: begin 
//                digit = data[7:4];  
//                end
//            2'd2: begin 
//                digit = data[11:8];   
//                end
//            2'd3: begin 
//                digit = data[15:12];  
//                end
//            default: begin 
//                digit = 4'd0;      
//                end
//        endcase
//    end
    
//     //7 segmentos
//     always_comb begin
//         case(digit)        //Anodo comun: para encendido 0 y apagado 1, orden del display 7'babcdefg
//             0: seg = 7'b0000001;
//             1: seg = 7'b1001111;
//             2: seg = 7'b0010010;
//             3: seg = 7'b0000110;
//             4: seg = 7'b1001100;
//             5: seg = 7'b0100100;
//             6: seg = 7'b0100000;
//             7: seg = 7'b0001111;
//             8: seg = 7'b0000000;
//             9: seg = 7'b0000100;
//             'hA: seg = 7'b0001000;
//             'hB: seg = 7'b1100000;
//             'hC: seg = 7'b0110001;
//             'hD: seg = 7'b1000010;
//             'hE: seg = 7'b0110000;
//             'hF: seg = 7'b0111000;
//                 default: seg = 7'b0000001;  //Default de valor 0
//         endcase
//    end
    
//always_comb begin
//    an = 4'b1111;
//    if (aen[s]==1)
//        an[s]=0;
//end

//    always_ff @(posedge clk or posedge rst) begin
//    if (rst==1) 
//        clkdiv <= 0;
//    else
//        clkdiv <= clkdiv + 1;
//    end
//endmodule
 
//module Deco(
//input logic        clk,
//input logic        rst, 
//input logic [15:0] data,

//output logic [6:0] seg, //salida a los segmentos
//output logic [3:0] an
// // salida a los anodos
//);  

//    logic [1:0] an_counter;

////     rotación de ánodos a cada flanco de reloj
//    always_ff @(posedge clk) begin
//    if (rst) 
//        an_counter <= 0;
//    else
//        an_counter <= an_counter + 1;
//    end


//    logic [3:0] digit;
//    always_comb begin
//        case (an_counter)
//            2'd0: begin 
//                digit = data[3:0];    
//                an = 4'b1110;
//                end
//            2'd1: begin 
//                digit = data[7:4];   
//                an = 4'b1101;  
//                end
//            2'd2: begin 
//                digit = data[11:8];   
//                an = 4'b1011; 
//                end
//            2'd3: begin 
//                digit = data[15:12];  
//                an = 4'b0111; 
//                end
//            default: begin 
//                digit = 4'd0;      
//                an = 4'b1111;
//                end
//        endcase
//    end
    
//     //7 segmentos
//     always_comb begin
//         case(digit)        //Anodo comun: para encendido 0 y apagado 1, orden del display 7'babcdefg
//             0: seg = 7'b0000001;
//             1: seg = 7'b1001111;
//             2: seg = 7'b0010010;
//             3: seg = 7'b0000110;
//             4: seg = 7'b1001100;
//             5: seg = 7'b0100100;
//             6: seg = 7'b0100000;
//             7: seg = 7'b0001111;
//             8: seg = 7'b0000000;
//             9: seg = 7'b0000100;
//             'hA: seg = 7'b0001000;
//             'hB: seg = 7'b1100000;
//             'hC: seg = 7'b0110001;
//             'hD: seg = 7'b1000010;
//             'hE: seg = 7'b0110000;
//             'hF: seg = 7'b0111000;
//                 default: seg = 7'b0000001;  //Default de valor 0
//         endcase
//    end
//endmodule

   //Logica del decodificador
    //Señales internas de decodificador
//    logic [3:0] digit; // Valor a mostrar en el display
//    logic [3:0] an_counter; // Contador para alternar entre los anodos
       
////     Lógica del contador de anodos para alternar entre los anodos rápidamente
//    always @(posedge clk) begin
//    an_counter = 4'b0000;
//        if (an_counter == 4'b0011) begin // Cuando el contador llega a 3 (4'b0011), reiniciamos a 0
//            an_counter <= 4'b0000;
//        end else begin
//            an_counter <= an_counter + 1;
//        end
//    end
////         Multiplexor
//    always_comb begin
//           case (an_counter)
//               4'd00: begin
//                   digit = data[3:0]; // Asigna los bits 0-3 de data_out al primer anodo
//                   an = 4'b1110; // Activa el primer anodo
//               end
//               4'b0001: begin
//                   digit = data[7:4]; // Asigna los bits 4-7 de data_out al segundo anodo
//                   an = 4'b1101; // Activa el segundo anodo
//               end
//               4'b0010: begin
//                   digit = 0; // Asigna los bits 8-11 de data_out al tercer anodo
//                   an = 4'b1011; // Activa el tercer anodo
//               end
//               4'b0011: begin
//                   digit = 0;
//                  an = 4'b0111; // Activa el cuarto anodo
//               end
//               default: begin
//                   digit = 0; // En caso de un valor no esperado, asigna los bits 0-3 de data_out al primer anodo
//                   an = 4'b1110; // Activa el primer anodo
//               end
//           endcase
//     end

module Deco(
    input logic clk,          // Reloj FPGA (ej. 100 MHz)
    input logic rst,        // Reset activo alto
    input logic [15:0] data,  // 4 dígitos hexadecimales (16 bits)
    output logic [6:0] seg,    // Segmentos (a-g, ánodo común)
    output logic [3:0] an      // Ánodos (0 = dígito activo)
);

// Divisor de frecuencia para refresco ~4ms por dígito (250 Hz total)
logic [15:0] refresh_counter;
localparam REFRESH_TICK = 16'd49_999; // Ajuste para 100 MHz

always @(posedge clk or posedge rst) begin
    if (rst)
     refresh_counter <= 0;
    else if (refresh_counter == REFRESH_TICK) 
    refresh_counter <= 0;
    else refresh_counter <= refresh_counter + 1;
end


// Contador de selección de dígito (0 a 3)
logic [1:0] digit_sel;

always @(posedge clk or posedge rst) begin
    if (rst) 
        digit_sel <= 0;
    else if (refresh_counter == REFRESH_TICK) 
        digit_sel <= digit_sel + 1;
end

// Lógica combinacional para ánodos y segmentos

always_comb begin
    case(digit_sel)
        2'b00: begin
            an = 4'b1110; // Activa primer dígito
            case(data[3:0]) // Decodifica dígito 0
                4'h0: seg = 7'b0000001; 4'h1: seg = 7'b1001111;
                4'h2: seg = 7'b0010010; 4'h3: seg = 7'b0000110;
                4'h4: seg = 7'b1001100; 4'h5: seg = 7'b0100100;
                4'h6: seg = 7'b0100000; 4'h7: seg = 7'b0001111;
                4'h8: seg = 7'b0000000; 4'h9: seg = 7'b0000100;
                4'hA: seg = 7'b0001000; 4'hB: seg = 7'b1100000;
                4'hC: seg = 7'b0110001; 4'hD: seg = 7'b1000010;
                4'hE: seg = 7'b0110000; 4'hF: seg = 7'b0111000;
                default: seg = 7'b1111111;
            endcase
        end
        2'b01: begin
            an = 4'b1101; // Segundo dígito
            case(data[7:4]) // Decodifica dígito 1
                4'h0: seg = 7'b0000001; 4'h1: seg = 7'b1001111;
                4'h2: seg = 7'b0010010; 4'h3: seg = 7'b0000110;
                4'h4: seg = 7'b1001100; 4'h5: seg = 7'b0100100;
                4'h6: seg = 7'b0100000; 4'h7: seg = 7'b0001111;
                4'h8: seg = 7'b0000000; 4'h9: seg = 7'b0000100;
                4'hA: seg = 7'b0001000; 4'hB: seg = 7'b1100000;
                4'hC: seg = 7'b0110001; 4'hD: seg = 7'b1000010;
                4'hE: seg = 7'b0110000; 4'hF: seg = 7'b0111000;
                default: seg = 7'b1111111;
            endcase
        end
        2'b10: begin
            an = 4'b1011; // Tercer dígito
            case(data[11:8]) // Decodifica dígito 2
                4'h0: seg = 7'b0000001; 4'h1: seg = 7'b1001111;
                4'h2: seg = 7'b0010010; 4'h3: seg = 7'b0000110;
                4'h4: seg = 7'b1001100; 4'h5: seg = 7'b0100100;
                4'h6: seg = 7'b0100000; 4'h7: seg = 7'b0001111;
                4'h8: seg = 7'b0000000; 4'h9: seg = 7'b0000100;
                4'hA: seg = 7'b0001000; 4'hB: seg = 7'b1100000;
                4'hC: seg = 7'b0110001; 4'hD: seg = 7'b1000010;
                4'hE: seg = 7'b0110000; 4'hF: seg = 7'b0111000;
                default: seg = 7'b1111111;
            endcase
        end
        2'b11: begin
            an = 4'b0111; // Cuarto dígito
            case(data[15:12]) // Decodifica dígito 3
                4'h0: seg = 7'b0000001; 4'h1: seg = 7'b1001111;
                4'h2: seg = 7'b0010010; 4'h3: seg = 7'b0000110;
                4'h4: seg = 7'b1001100; 4'h5: seg = 7'b0100100;
                4'h6: seg = 7'b0100000; 4'h7: seg = 7'b0001111;
                4'h8: seg = 7'b0000000; 4'h9: seg = 7'b0000100;
                4'hA: seg = 7'b0001000; 4'hB: seg = 7'b1100000;
                4'hC: seg = 7'b0110001; 4'hD: seg = 7'b1000010;
                4'hE: seg = 7'b0110000; 4'hF: seg = 7'b0111000;
                default: seg = 7'b1111111;
            endcase
        end
        default: begin
            an = 4'b1111;
            seg = 7'b1111111;
        end
    endcase
end

endmodule