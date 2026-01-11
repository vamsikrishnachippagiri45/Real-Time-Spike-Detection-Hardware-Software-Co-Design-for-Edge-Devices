`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2025 10:17:29
// Design Name: 
// Module Name: compare_threshold
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


module compare_threshold#(parameter T = 100)(X,M,S);
input signed [31:0]X;
input signed [31:0]M;
output S;

wire signed [31:0]diff;
wire [31:0]abs_diff;
assign diff = X - M ;
assign abs_diff = (diff<0)?(-diff):(diff);
assign S = (abs_diff >= T)? 1'b1:1'b0;
endmodule
