`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/19 15:28:29
// Design Name: 
// Module Name: vga_top
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

module vga_top(
    sys_clk,
    sys_rst_n,
    rx,
    hsync,
    vsync,
    vga_rgb
);

    // Inputs
	input sys_clk;
	input sys_rst_n;
	input rx;

    output hsync;
    output vsync;
    output [11:0]vga_rgb;
    
    wire vga_clk;
    wire clk_locked;
	wire rst_n;
    wire [7:0]r_data,out_data;
    wire [15:0]r_addr;
    reg uart_cnt_en;
    reg [3:0]uart_cnt;
    wire [7:0]uart_data;
    wire r_done;
    
    wire ready;
    wire [7:0]in_data;
    reg [7:0]u_data;
    
    assign rst_n = clk_locked & sys_rst_n;
    assign ready = uart_cnt_en;
    assign in_data = u_data;
    
    
    always @(posedge vga_clk or negedge rst_n)
        if(!rst_n)
            uart_cnt_en <= 1'b0;
        else if(r_done)
            uart_cnt_en <= 1'b1;
        else if(uart_cnt == 4'd15)
            uart_cnt_en <= 1'b0;
    
    always @(posedge vga_clk or negedge rst_n)
        if(!rst_n)
            uart_cnt <= 4'd0;
        else if(uart_cnt_en)
            if(uart_cnt == 4'd15)
                uart_cnt <= 4'd0;
            else
                uart_cnt <= uart_cnt + 1'b1;
        else
            uart_cnt <= 4'd0;
    
    always @(posedge vga_clk or negedge rst_n)
        if(!rst_n)
            u_data <= 8'd0;
        else if(r_done)
            u_data <= uart_data;
            
    clk_gen clk_gen(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .clk_out(vga_clk),
        .clk_locked(clk_locked)
    );

    vga_ctl vga_ctl(
        .vga_clk(vga_clk),
        .rst_n(rst_n),
        .pix_data(r_data),
        .r_addr(r_addr),
        .hsync(hsync),
        .vsync(vsync),
        .vga_rgb(vga_rgb)
    );
    
     
    ram_ctl ram_ctl(
        .clk(vga_clk),
        .rst_n(rst_n),
        .ready(ready),
        .in_data(in_data),    
        .r_addr(r_addr),
        .r_data(r_data)
    );
    
    uart_ctl uart_ctl(
        .clk(vga_clk),
        .rst_n(rst_n),
        .rx(rx),
        .r_done(r_done),
        .out_data(uart_data)
    );

endmodule
