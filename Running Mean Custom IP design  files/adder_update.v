`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.06.2025 18:45:59
// Design Name: 
// Module Name: adder_update
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


module adder_update(m,dm,um,n,un);
input [31:0]m,dm,n;
output [31:0]um,un;
assign um = m + dm ;
assign un = n + 1;
endmodule
