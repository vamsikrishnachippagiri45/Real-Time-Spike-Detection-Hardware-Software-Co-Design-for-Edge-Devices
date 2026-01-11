`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2025 07:50:34
// Design Name: 
// Module Name: IP_core
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


module IP_core#(parameter Threshold = 100)(
input clk,
input resetn,

// slave interfaces 
input [31:0]s_axis_data,
input s_axis_valid,
output s_axis_ready,

// Master interface
output [31:0]m_axis_data,
output m_axis_valid,
input m_axis_ready
    );
   
wire valid_compute;
assign valid_compute = s_axis_valid & m_axis_ready;
assign s_axis_ready = m_axis_ready; 

main #(.Threshold(Threshold)) inst(
.X(s_axis_data),
.RST(~resetn),
.CLK(clk),
.Out(m_axis_data),
.Valid_data(valid_compute),
.m_axis_valid(m_axis_valid)
);    

endmodule

