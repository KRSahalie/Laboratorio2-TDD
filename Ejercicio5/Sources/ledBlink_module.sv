`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TEC
// Student: Kendy Arias
// 
// Create Date: 02/25/2024 04:56:06 PM
// Design Name: Logica del Decodificador parte 2
// Module Name: logica_deco parte 2
// Target Devices: Basys 3 
// Description: Modulo que implementa la logica del decodificador con un multiplexor para poder elegir cual display y cuales entradas estan relacionadas
//
//////////////////////////////////////////////////////////////////////////////////

//Como usamos un reloj de 10MHz, vamos a tener que hacer un slowclock para que la LFSR de cambios cada 2s
//En este caso si queremos entonces que 10Mhz pase a 2 Hz dividimos y necesitamos 5Mhz ciclos
module slowclock_module(
    input clk_in,
    output clk_slow
    );
    
    reg [23:0] count = 0 ;
    reg clk_out;
    
    always@(posedge clk_in)
    begin 
    count <= count+1;
    if (count == 5_000_000)
    begin
    count<=0;
    clk_out =~ clk_out;
    end
    end
    
    assign clk_slow= clk_out; // reloj de cada 2  segundos lo uso para el reloj de la LSFR y para el enable del pipo
    
    
endmodule
