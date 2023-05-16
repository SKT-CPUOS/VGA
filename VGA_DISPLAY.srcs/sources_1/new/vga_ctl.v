`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/19 15:26:31
// Design Name: 
// Module Name: vga_ctl
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

module vga_ctl(
    input vga_clk,
    input rst_n,
    input [7:0]pix_data,
    output reg [15:0]r_addr,
    output hsync,
    output vsync,
    output [11:0] vga_rgb
);

    wire rgb_valid,pix_data_req;
	wire [11:0]rgb_data;
	reg [10:0] x_cnt;
    reg [9:0] y_cnt;
    reg [2:0] pix_cnt;
    reg [7:0]pix_data_reg;
    wire [9:0]pix_x,pix_y;
    
    //-----------------------------------------------------------//
    // 水平扫描参数的设定 1024*768 60Hz VGA
    //-----------------------------------------------------------//
    // parameter H_Total =1344; //行周期数
    // parameter H_Sync=136; //行同步脉冲（ Sync a）
    // parameter H_Back=160; //显示后沿（ Back porch b）
    // parameter H_Valid=1024; //显示时序段（ Display interval c）
    // parameter H_Front=24; //显示前沿（ Front porch d）

    // parameter Hde_start=296;
    // parameter Hde_end=1320;


    // //-----------------------------------------------------------//
    // // 垂直扫描参数的设定 1024*768 60Hz VGA
    // //-----------------------------------------------------------//
    // parameter V_Total =806; //列周期数
    // parameter V_Sync=6; //列同步脉冲（ Sync o）
    // parameter V_Back=29; //显示后沿（ Back porch p）
    // parameter V_Valid=768; //显示时序段（ Display interval q）
    // parameter V_Front=3; //显示前沿（ Front porch r）

    // parameter Vde_start=35;
    // parameter Vde_end=803;

    //-----------------------------------------------------------//
    // 水平扫描参数的设定 800*600 VGA
    //-----------------------------------------------------------//
    parameter H_Total =1056; //行周期数
    parameter H_Sync=128; //行同步脉冲（ Sync a）
    parameter H_Back=88; //显示后沿（ Back porch b）
    parameter H_Valid=800; //显示时序段（ Display interval c）
    parameter H_Front=40; //显示前沿（ Front porch d）

    // -----------------------------------------------------------//
    // 垂直扫描参数的设定 800*600 VGA
    // -----------------------------------------------------------//
    parameter V_Total =628; //列周期数
    parameter V_Sync=4; //列同步脉冲（ Sync o）
    parameter V_Back=23; //显示后沿（ Back porch p）
    parameter V_Valid=600; //显示时序段（ Display interval q）
    parameter V_Front=1; //显示前沿（ Front porch r）


    //----------------------------------------------------------------
    ////////// 水平扫描计数
    //----------------------------------------------------------------
    always @ (posedge vga_clk or negedge rst_n) 
        if((!rst_n)) 
            x_cnt <= 11'd0;
        else if(x_cnt == H_Total - 1'b1) 
            x_cnt <= 11'd0;
        else 
            x_cnt <= x_cnt+ 1'b1;

    //----------------------------------------------------------------
    ////////// 垂直扫描计数
    //----------------------------------------------------------------
    always @ (posedge vga_clk or negedge rst_n)
        if((!rst_n)) 
            y_cnt <= 10'd0;
        else if((x_cnt == H_Total - 1'b1) && (y_cnt == V_Total - 1'b1))
            y_cnt <= 10'd0;
        else if(x_cnt == H_Total - 1'b1)
            y_cnt <= y_cnt+1'b1;
        else 
            y_cnt <= y_cnt;

    assign hsync = (x_cnt < H_Sync) ? 1'b1 : 1'b0;
    assign vsync = (y_cnt < V_Sync) ? 1'b1 : 1'b0;

    assign rgb_valid = ((x_cnt >= H_Sync + H_Back) 
                        && (x_cnt < H_Sync + H_Back + H_Valid)
                        && (y_cnt >= V_Sync + V_Back)
                        && (y_cnt < V_Sync + V_Back + V_Valid))
                        ? 1'b1 : 1'b0;

	assign pix_data_req = ((x_cnt >= H_Sync + H_Back - 2'd2) 
                        && (x_cnt < H_Sync + H_Back + H_Valid - 2'd2)
                        && (y_cnt >= V_Sync + V_Back)
                        && (y_cnt < V_Sync + V_Back + V_Valid))
                        ? 1'b1 : 1'b0;

    assign pix_x = (pix_data_req == 1'b1) ? (x_cnt - (H_Sync + H_Back - 2)) : 10'b1111_1111_11;
    assign pix_y = (pix_data_req == 1'b1) ? (y_cnt - (V_Sync + V_Back)) : 10'b1111_1111_11;

    always @(posedge vga_clk or negedge rst_n)
        if(!rst_n) 
            pix_cnt <= 3'd0;
        else if(rgb_valid == 1'b1)
            if(pix_cnt == 3'b111) 
                pix_cnt <= 3'd0;
            else
                pix_cnt <= pix_cnt + 1'b1;
        else
            pix_cnt <= 3'd0;
    
    always @(posedge vga_clk or negedge rst_n)
        if(!rst_n)
            r_addr <= 16'd0;
        else if(pix_x != 10'h3ff && pix_y != 10'h3ff)
            if(pix_x == 10'd0 && pix_y == 10'd0)
                r_addr <= 16'd0;
            else if(pix_x % 8 == 0)
                r_addr <= r_addr + 1'b1;
    
    assign rgb_data = (pix_data[pix_cnt] == 1'b1) ? 12'b1111_1111_1111 : 12'd0;
	 
    assign vga_rgb = (rgb_valid == 1'b1) ? (rgb_data) : 12'd0;

endmodule

