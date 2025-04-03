`timescale 1ns / 1ps

module tb_slowclock_module;

  // Señales
  reg clk_in = 0; // Entrada de reloj de 10MHz
  wire clk_slow; // Salida del slow clock

  // Instancia del módulo a probar
  slowclock_module slowclock_inst (
    .clk_in(clk_in),
    .clk_slow(clk_slow)
  );

  // Generación del reloj de 10MHz (period of 100 ns)
  initial begin
    clk_in = 0;
    forever #50 clk_in = ~clk_in; // Cambio de estado cada 50ns (10MHz)
  end

  // Verificar el slow clock (period should be 500 ns)
  initial begin
    wait (clk_slow); // Wait for the first slow clock pulse
    integer num_slow_edges = 0;
    integer time_between_edges = 0;
    repeat (10) begin // Check multiple slow clock edges
      wait (posedge clk_slow);
      num_slow_edges = num_slow_edges + 1;
      time_between_edges = $time - time_between_edges;
    end
    $display("Number of slow clock edges: %d", num_slow_edges);
    $display("Average time between edges: %d ns", time_between_edges / num_slow_edges);
  end

endmodule
