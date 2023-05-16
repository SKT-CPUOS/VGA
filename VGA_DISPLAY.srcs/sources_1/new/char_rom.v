`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/06 04:09:15
// Design Name: 
// Module Name: char_rom
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


module char_rom(
        clk,
        index,
        r_en,
        out_data
);
    
    input clk;
    input [6:0]index;
    input r_en;
    output [7:0]out_data;
    
    wire [10:0]addra;
    reg [3:0]cnt;

    assign addra = (r_en) ? index * 16 + cnt : 11'd0;
   
    always @(posedge clk)
       if(r_en)
           if(cnt == 4'd15)
               cnt <= 4'd0;
           else
               cnt <= cnt + 1'b1;
       else
           cnt <= 4'd0;
    
    blk_mem_gen_0 rom (
        .clka(clk),    // input wire clka
        .ena(r_en),      // input wire ena
        .addra(addra),  // input wire [10 : 0] addra
        .douta(out_data)  // output wire [7 : 0] douta
    );
    
endmodule
