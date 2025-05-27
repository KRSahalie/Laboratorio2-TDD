//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
//Date        : Tue Apr 29 14:13:00 2025
//Host        : DESKTOP-8ARU00K running 64-bit major release  (build 9200)
//Command     : generate_target clock_0.bd
//Design      : clock_0
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "clock_0,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=clock_0,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_board_cnt=3,da_clkrst_cnt=2,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "clock_0.hwdef" *) 
module clock_0
   (clk_100MHz,
    clk_100MHz_1,
    clk_out1_0,
    locked,
    reset_rtl_0);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_100MHZ CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_100MHZ, CLK_DOMAIN clock_0_clk_100MHz, FREQ_HZ 100000000, INSERT_VIP 0, PHASE 0.000" *) input clk_100MHz;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_100MHZ_1 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_100MHZ_1, CLK_DOMAIN clock_0_clk_100MHz_1, FREQ_HZ 100000000, INSERT_VIP 0, PHASE 0.000" *) input clk_100MHz_1;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_OUT1_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_OUT1_0, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 10000000, INSERT_VIP 0, PHASE 0.0" *) output clk_out1_0;
  output locked;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RESET_RTL_0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RESET_RTL_0, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input reset_rtl_0;

  wire \^clk_100MHz_1 ;
  wire clk_100MHz_1_1;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_locked;
  wire reset_rtl_0_1;

  assign \^clk_100MHz_1  = clk_100MHz;
  assign clk_100MHz_1_1 = clk_100MHz_1;
  assign clk_out1_0 = clk_wiz_0_clk_out1;
  assign locked = clk_wiz_0_locked;
  assign reset_rtl_0_1 = reset_rtl_0;
  clock_0_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(\^clk_100MHz_1 ),
        .clk_out1(clk_wiz_0_clk_out1),
        .locked(clk_wiz_0_locked),
        .reset(reset_rtl_0_1));
  clock_0_ila_0_0 ila_0
       (.clk(clk_100MHz_1_1),
        .probe0(\^clk_100MHz_1 ),
        .probe1(clk_wiz_0_clk_out1));
endmodule
