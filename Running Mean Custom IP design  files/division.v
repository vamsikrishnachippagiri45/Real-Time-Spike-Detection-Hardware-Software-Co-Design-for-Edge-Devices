`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.06.2025 06:46:22
// Design Name: 
// Module Name: division
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


module division #( parameter WIDTH = 32) (a,b,q,pr);
input [WIDTH-1:0]a,b ;
output [WIDTH-1:0]q,pr ;


wire [WIDTH-1:0]a1,a2,as;
wire sign,V2,V1;

assign sign = a[31];
assign a1 = (sign)? -a : a ;
assign a2 = a1 + ({1'b0 , a1[31:1]}) ;

wire [4:0]out1 , out2 ;

priority_encoder_32bits instpe1(.X(a2),.Z(out1),.V(V1));
priority_encoder_32bits instpe2(.X(b),.Z(out2),.V(V2));

wire [4:0]shift,shift1;
assign shift =(out1 > out2 )? (out1 - out2) : 0 ;
assign shift1 = (out1 <= out2)? 1'b0 : (shift - 1) ;
wire [WIDTH-1:0]b1,b2,q1,q2;
barrel_shift_left instbsl(.A(b),.S(shift),.Y(b1));
barrel_shift_left instbsl1(.A(b),.S(shift1),.Y(b2));
barrel_shift_left instbsl2(.A({{31{1'b0}},1'b1}),.S(shift),.Y(q1));
barrel_shift_left instbsl3(.A({{31{1'b0}},1'b1}),.S(shift1),.Y(q2));

wire [WIDTH-1:0]Y1,Y2,Y3,q0,pr0; 

assign Y1 = (a2 <= b1)? b2:b1;
assign Y2 = (a2 <= b1)? q2:q1;
assign Y3 = a1 - Y1 ;
assign pr0 = (sign)? (~Y3 + 1):Y3 ;
assign q0 = (sign)? (~Y2 + 1):Y2 ;

assign pr = (a2 == {32{1'b0}})? {32{1'b0}}:pr0;
assign q = (a2 == {32{1'b0}})? {32{1'b0}}:q0;
endmodule
