`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.09.2025 00:35:01
// Design Name: 
// Module Name: i2c_clk_divider
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


module i2c_clk_divider(
   input wire reset, 
   input wire ref_clk,
   output reg i2c_clk

    );
  
reg [9:0] count = 0;

initial i2c_clk =0;

always @(posedge ref_clk) begin
  
     if(count == 500) begin
       i2c_clk <= ~i2c_clk;
       count <= 0;
     end
     else begin
       count <= count + 1;
     end  
     
   end

endmodule

