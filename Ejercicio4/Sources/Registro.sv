// Banco de registros parametrizable
module Registro #(
    parameter N = 5,           // N bits de dirección => 2^N registros
    parameter W = 8            // W bits de ancho por registro
)(
    input logic           clk,             // reloj
    input logic           rst,             // reset síncrono
    input logic [N-1:0]   addr_rs1,        // dirección de lectura 1
    input logic [N-1:0]   addr_rs2,        // dirección de lectura 2
    input logic [N-1:0]   addr_rd,         // dirección de escritura
    input logic [W-1:0]   data_in,         // datos de entrada a escribir
    input logic           we,              // write enable

    output logic [W-1:0]  rs1,             // salida de lectura 1
    output logic [W-1:0]  rs2              // salida de lectura 2
);

    // Declaración del banco de registros
    logic [W-1:0] Registro [0:(2**N)-1];

    // Variable para el reset
    integer i;

    // Lógica secuencial: escritura y reset
    always @(posedge clk) begin
        if (rst) begin
            // Inicializa todos los registros en 0
            for (i = 0; i < 2**N; i = i + 1)
                Registro[i] <= 0;
        end else begin
            // Escritura solo si se habilita y no es el registro 0
            if (we && addr_rd != 0)
                Registro[addr_rd] <= data_in;
        end
    end

    // Lógica combinacional: lectura
    always_comb begin
        // Registro 0 siempre entrega 0 (solo lectura)
        rs1 = (addr_rs1 == 0) ? 0 : Registro[addr_rs1];
        rs2 = (addr_rs2 == 0) ? 0 : Registro[addr_rs2];
    end

endmodule
