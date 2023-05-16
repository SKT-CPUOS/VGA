`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/07 00:08:26
// Design Name: 
// Module Name: uart_rx
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
//8位数据位，1位停止位，无奇偶校验位
module uart_rx (
    input clk,
    input rst_n,
    input rx,
    input [1:0] baud_rate,   //9600 19200 38400 115200 
    output reg r_done,
    output reg r_state,
    output reg [7:0]data_byte
);
    
    wire negdge;
    reg s0_rx_r,s1_rx_r;
    reg s0_temp_r,s1_temp_r;
    
    parameter Sys_Fre = 40_000_000;
	
    assign negdge = (!s0_temp_r) && (s1_temp_r);

    //同步时序，消除亚稳态
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            s0_rx_r <= 1'd0;
            s1_rx_r <= 1'd0;
        end
        else begin
            s0_rx_r <= rx;
            s1_rx_r <= s0_rx_r;
        end
    end

    //数据寄存
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            s0_temp_r <= 1'd0;
            s1_temp_r <= 1'd0;
        end
        else begin
            s0_temp_r <= s1_rx_r;
            s1_temp_r <= s0_temp_r;
        end
    end

    reg [15:0] div_pre;
    //获取波特率分频计数器的计数值
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            div_pre <= (Sys_Fre / 9600 / 6) - 1'b1;
        else
            case(baud_rate)
                2'b00:div_pre <= (Sys_Fre / 9600 / 6) - 1'b1;
                2'b01:div_pre <= (Sys_Fre / 19200 / 6) - 1'b1;
                2'b10:div_pre <= (Sys_Fre / 38400 / 6) - 1'b1;
                2'b11:div_pre <= (Sys_Fre / 115200 / 6) - 1'b1;
            endcase
    end

    reg bps_clk;
    reg [11:0] div_cnt;
    //波特率分频计数器
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            div_cnt <= 12'd0;
        else if(r_state) begin
            if(div_cnt == div_pre) 
                div_cnt <= 12'd0;
            else 
                div_cnt <= div_cnt + 1'b1;
        end
        else 
            div_cnt <= 12'd0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            bps_clk <= 1'b0;
        else if(div_cnt == 12'd1)
            bps_clk <= 1'b1;
        else
            bps_clk <= 1'b0;
    end

    reg [5:0] bps_cnt;
    //数据位计数器
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            bps_cnt <= 6'd0;
		  else if((bps_cnt == 6'd59) && (div_cnt == div_pre))
				bps_cnt <= 0;
        else if(bps_clk)
            bps_cnt <= bps_cnt + 1'b1;
        else
            bps_cnt <= bps_cnt;
    end

    reg [7:0]rec_data_r;
    reg start_bit_r,end_bit_r;
    //rx
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rec_data_r[0] <= 1'b0;
            rec_data_r[1] <= 1'b0;
            rec_data_r[2] <= 1'b0;
            rec_data_r[3] <= 1'b0;
            rec_data_r[4] <= 1'b0;
            rec_data_r[5] <= 1'b0;
            rec_data_r[6] <= 1'b0;
            rec_data_r[7] <= 1'b0;
		  end
        else begin
            case(bps_cnt)
                6'd0: begin
                    rec_data_r[0] <= 1'b0;
                    rec_data_r[1] <= 1'b0;
                    rec_data_r[2] <= 1'b0;
                    rec_data_r[3] <= 1'b0;
                    rec_data_r[4] <= 1'b0;
                    rec_data_r[5] <= 1'b0;
                    rec_data_r[6] <= 1'b0;
                    rec_data_r[7] <= 1'b0;
                end
                6'd4:start_bit_r <= rx;
                6'd10:rec_data_r[0] <= rx;   
                6'd16:rec_data_r[1] <= rx;
                6'd22:rec_data_r[2] <= rx;
                6'd28:rec_data_r[3] <= rx;
                6'd34:rec_data_r[4] <= rx;
                6'd40:rec_data_r[5] <= rx;
                6'd46:rec_data_r[6] <= rx;
                6'd52:rec_data_r[7] <= rx;
                6'd58:end_bit_r <= rx;
                default:;
            endcase
		 end
    end

    //输出发送完成标志
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            r_done <= 1'b0;
        else if((bps_cnt == 6'd59) && (div_cnt == div_pre))
            r_done <= 1'b1;
		else
			r_done <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            data_byte <= 8'd0;
        else if((bps_cnt == 6'd59) && (div_cnt == div_pre))begin
            data_byte[0] <= rec_data_r[0];
            data_byte[1] <= rec_data_r[1];
            data_byte[2] <= rec_data_r[2];
            data_byte[3] <= rec_data_r[3];
            data_byte[4] <= rec_data_r[4];
            data_byte[5] <= rec_data_r[5];
            data_byte[6] <= rec_data_r[6];
            data_byte[7] <= rec_data_r[7];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            r_state <= 1'b0;
        else if(negdge)
            r_state <= 1'b1;
        else if((bps_cnt == 6'd59  && (div_cnt == div_pre)) || (bps_cnt == 6'd3 && start_bit_r))
            r_state <= 1'b0;
        else
            r_state <= r_state;
    end

endmodule
