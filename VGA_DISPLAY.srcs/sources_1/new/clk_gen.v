`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/16 03:09:13
// Design Name: 
// Module Name: clk_gen
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
module clk_gen(
    input sys_clk,
    input sys_rst_n,
    output clk_out,
    output clk_locked
);   

   clk_wiz_0 pll_inst
   (
    // Clock out ports
    .clk_out1(),     // 21.175Mhz for 640x480(60hz)
    .clk_out2(clk_out),     // 40.0Mhz for 800x600(60hz)
    .clk_out3(),     // 65.0Mhz for 1024x768(60hz)
    .clk_out4(),     // 108.0Mhz for 1280x1024(60hz)
    // Status and control signals
    .reset(~sys_rst_n), // input reset
    .locked(clk_locked),       // output locked
   // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1
// INST_TAG_END ------ End INSTANTIATION Template ---------

endmodule