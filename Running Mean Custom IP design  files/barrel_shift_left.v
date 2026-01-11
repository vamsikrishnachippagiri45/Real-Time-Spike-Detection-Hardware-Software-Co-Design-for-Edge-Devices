`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.06.2025 06:45:24
// Design Name: 
// Module Name: barrel_shift_left
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


module barrel_shift_left(A,S,Y);
input [31:0]A;
input [4:0]S;
output [31:0]Y;

wire [31:0] Y1,Y2,Y3,Y4;
assign Y1 = (S[4] == 1'b1)?({A[15:0],{16{1'b0}}}):A;
assign Y2 = (S[3] == 1'b1)?({Y1[23:0],{8{1'b0}}}):Y1;
assign Y3 = (S[2] == 1'b1)?({Y2[27:0],{4{1'b0}}}):Y2;
assign Y4 = (S[1] == 1'b1)?({Y3[29:0],{2{1'b0}}}):Y3;
assign Y = (S[0] == 1'b1)?({Y4[30:0],1'b0}):Y4;

endmodule
