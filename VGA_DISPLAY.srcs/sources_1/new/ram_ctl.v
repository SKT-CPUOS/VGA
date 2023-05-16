`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/09 14:29:00
// Design Name: 
// Module Name: ram_ctl
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

module ram_ctl(
    clk,
    rst_n,
    ready,      //写控制线
    in_data,    //写数据，保持16个时钟
    r_addr,     //读地址
    r_data     //读数据   
);

    input clk;
    input rst_n;
    input ready;
    input [7:0]in_data;
    input [15:0]r_addr;
    output [7:0]r_data;
    
    reg [4:0]cnt;
    reg [6:0]index;
    reg[5:0]row,offset;
    reg[6:0]col;
    reg end_flag,r_en_temp;
    reg [7:0]indata_r,indata_temp;
    wire r_en;
    reg w_en;
    
    reg ready_value0,ready_value1;
    reg ready_temp0,ready_temp1;
    wire negdge;
    reg w_en2;
    reg [6:0]end_col;
    
    wire [15:0]w_addr;
    reg [3:0]w_cnt = 4'd0;
    
    reg [15:0]r_addr_real;
    wire [7:0]out_data,rom_data;
    wire [15:0]r_addr_w;
    wire line_end_flag,blank_flag;
    reg [6:0]line_end_col = 7'd100;
    
    assign negdge = (!ready_value0) & ready_value1;       
    
    assign r_en = (end_flag) ? 1'b0 : r_en_temp;
    
    assign w_addr = (w_en) ? 1202 + (col + (1600 * (row + offset))) % 57600 + w_cnt * 100 : 16'd0;
    
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            w_en <= 1'b0;
        else if(r_en)
            w_en <= 1'b1;
        else
            w_en <= 1'b0;
    
    always @(posedge clk)
        if(w_en) begin
            if(w_cnt == 4'd15)
                w_cnt <= 4'd0;
            else
                w_cnt <= w_cnt + 1'b1;        
        end
        else
            w_cnt <= 4'd0;

    assign r_addr_w = r_addr_real;
    
    always @(r_addr,offset,line_end_flag,blank_flag)
        if(line_end_flag && (r_addr % 100) > 1 && (r_addr % 100) < 98 && blank_flag)
            r_addr_real = 16'd501;         
        else if(r_addr < 1200 || r_addr > 58799)
            r_addr_real = r_addr;
        else if(r_addr + offset * 1600 > 58799)
            r_addr_real = (r_addr + offset * 1600) % 58800 + 1200;
        else
            r_addr_real = r_addr + offset * 1600;
    
    //out_data是ram的输出
    assign r_data = ((r_addr - 1200) % 1600 < 100 && out_data == 8'h0d) ? 8'd0 : out_data;
    
    assign line_end_flag = (line_end_col < 7'd100 && (r_addr - 1200) % 1600 != 0) ? 1'b1 : 1'b0;
    assign blank_flag = (line_end_flag && (r_addr % 100) >= line_end_col) ? 1'b1 : 1'b0;

    always @(posedge clk)
        if((r_addr - 1200) % 1600 < 100 && out_data == 8'h0d)
            line_end_col = r_addr % 100;
        else if((r_addr - 1200) % 1600 == 0)
            line_end_col = 7'd100;
    
    //对外部输入的异步信号进行同步处理
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
           ready_temp0 <= 1'b0;
           ready_temp1 <= 1'b0; 
        end
        else begin
            ready_temp0 <= ready;
            ready_temp1 <= ready_temp0;
        end
    end
    
    //使用D触发器存储两个相邻时钟上升沿时外部输入信号（已经同步到系统时钟域中）的电平状态
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
           ready_value0 <= 1'b0;
           ready_value1 <= 1'b0; 
        end
        else begin
            ready_value0 <= ready_temp1;
            ready_value1 <= ready_value0;
        end
    end

    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            cnt <= 5'd16;       
        else if(ready || w_en2)
            if(cnt == 5'd16 || cnt == 5'd17) 
                cnt <= 5'd1;
            else    
                cnt <= cnt + 1'b1;
        else
            if(cnt == 5'd16)
                cnt <= 5'd1;
            else if(cnt < 5'd7)
                cnt <= cnt + 1'b1;
            else if(cnt == 5'd7)
                cnt <= 5'd17;
                
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
           indata_r <= 8'd0;
        else if(ready && cnt == 5'd6) 
           indata_r <= in_data;
        else if(w_en2 && cnt == 5'd6)
            if(col == 7'd95)
                indata_r <= indata_temp;
            else
                indata_r <= 8'h20;
            
                
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            end_flag <= 1'b0;
        else if(indata_r == 8'h0a)
            end_flag <= 1'b1;  
        else 
            end_flag <= 1'b0;
                
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            r_en_temp <= 1'b0;
        else if((ready && cnt == 5'd7) || (w_en2 && cnt == 5'd7))
            r_en_temp <= 1'b1;
        else if((ready == 1'b0 && cnt == 5'd7) || (w_en2 == 1'b0 && cnt == 5'd7))
            r_en_temp <= 1'b0;
    
    always @(posedge clk or negedge rst_n)
        if(!rst_n) begin
            row <= 6'b1111_11;
            col <= 7'b1111_111;
            offset <= 6'd0;
        end
        else if((ready && cnt == 5'd8) || (w_en2 && cnt == 5'd8)) begin
            if(indata_r == 8'h0a) begin
                col <= 7'd95;
                if(row == 6'b1111_11)
                    row <= 6'd0;
                else
                    row <= row;
            end 
            else if(row == 6'b1111_11 && col == 7'b1111_111) begin
                col <= 7'd0;
                row <= 6'd0;
            end
            else if(col == 7'd95) begin
                if(w_en2)
                    col <= end_col;
                else
                    col <= 7'd0;
                    
                if(w_en2)
                    row <= row;
                else if(row == 6'd35 && offset == 6'd35) begin
                    row <= 6'd35;
                    offset <= 6'd0;
                end
                else if(row == 6'd35 && offset < 6'd35) begin
                    row <= 6'd35;
                    offset <= offset + 1'b1;
                end
                else
                    row <= row + 1'b1;
            end
            else begin
                col <= col + 1'b1;
                row <= row;
            end
        end
    
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            index <= 7'd0;
        else if((ready && cnt == 5'd7) || (w_en2 && cnt == 5'd7))
            if(indata_r >= 8'h20 && indata_r <= 8'h7e)
                index <= indata_r - 8'h20;
            else if(indata_r == 8'h0a)
                index <= 7'd0;
            else if(indata_r == 8'h0d)
                index <= 7'd95;
    
    always @(posedge clk or negedge rst_n)      
        if(!rst_n) begin
            w_en2 <= 1'b0;
            end_col <= 7'd0;
            indata_temp <= 8'd0;
        end
        else if(negdge) begin
            if(indata_r != 8'h0a && col != 7'd95) begin
                w_en2 <= 1'b1;
                indata_temp <= indata_r;
            end
            else
                w_en2 <= 1'b0; 
            end_col <= col;
        end
        else if(w_en2 && (cnt == 5'd15) && (col == end_col)) begin    
            w_en2 <= 1'b0;
        end
            
    
    char_rom char_rom(
        .clk(clk),
        .index(index),
        .r_en(r_en),
        .out_data(rom_data)
    );
    
    blk_mem_gen_1 ram (
        .clka(clk),    // input wire clka
        .wea(w_en),      // input wire [0 : 0] wea
        .addra(w_addr),  // input wire [15 : 0] addra
        .dina(rom_data),    // input wire [7 : 0] dina
        .clkb(clk),    // input wire clkb
        .addrb(r_addr_w),  // input wire [15 : 0] addrb
        .doutb(out_data)  // output wire [7 : 0] doutb
    );

endmodule