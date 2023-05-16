`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/07 00:08:08
// Design Name: 
// Module Name: uart_ctl
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


module uart_ctl(
    clk,
    rst_n,
    rx,
    r_done,
    out_data
);

    input clk;
    input rst_n;
    input rx;
    output r_done;
    output [7:0]out_data;
    
    uart_rx uart_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .baud_rate(2'd0),   //9600 19200 38400 115200 
        .r_done(r_done),
        .r_state(),
        .data_byte(out_data)
    );
endmodule
