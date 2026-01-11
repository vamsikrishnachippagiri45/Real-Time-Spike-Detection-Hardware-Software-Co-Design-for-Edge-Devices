`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.06.2025 18:50:50
// Design Name: 
// Module Name: main
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


module main#(parameter Threshold = 100)(X,RST,Valid_data,CLK,Out,m_axis_valid);
input signed [31:0]X;
input RST,CLK,Valid_data;
output [31:0]Out;
output m_axis_valid;

reg [31:0]Xin_reg ;
wire [31:0]Xin;
wire select;
reg g_reg1,g_reg2;
reg CE1,CE2,CE; 

reg [31:0]X_reg,M_reg,P_reg,N_reg;
reg [31:0]Mean_out;
wire [31:0]a,q,pr,um,un;



assign Xin = (select)? um:Xin_reg;
compare_threshold #(.T(Threshold)) instTC (.X(Xin_reg),.M(um),.S(select));


adder instadd(.a(a),.p(P_reg),.x(X_reg),.m(M_reg));
division instdiv(.a(a),.b(N_reg),.q(q),.pr(pr));
adder_update  instaddupdate(.m(M_reg),.dm(q),.um(um),.n(N_reg),.un(un));

reg VD1,VD2;

always @(posedge CLK)
    begin 
        if(RST == 1'b1)
            begin 
                X_reg <= {32{1'b0}};  M_reg <= {32{1'b0}};  P_reg <= {32{1'b0}};  N_reg <= {32{1'b0}};
                Xin_reg<={32{1'b0}} ; g_reg1 <= 1'b0 ; g_reg2 <= 1'b0 ; CE <= 1'b1; CE1 <= 1'b1;
                VD1 <= 1'b0; VD2 <= 1'b0;
            end
        else 
        begin
             CE1 <= Valid_data; CE <= CE1;
            if(CE == 1'b0)
                begin 
                    X_reg <= X_reg ;  M_reg <= M_reg ;  P_reg <= P_reg ;  N_reg <= N_reg ;  
                    Xin_reg<=Xin_reg; g_reg1 <= g_reg1 ; g_reg2 <= g_reg2 ;
                    VD1 <= VD1 ; VD2 <= VD2 ;
                end
            else 
                begin 
                    X_reg <= Xin ;  M_reg <= um ; P_reg <= pr ; N_reg <= un ; Mean_out <= um ;  
                    Xin_reg<= X; g_reg1 <= select ; g_reg2 <= g_reg1 ;  
                    VD1 <= Valid_data; VD2 <= VD1;
                end
        end
     end
assign Out = {g_reg2 , Mean_out[30:0]} ;
assign m_axis_valid = VD2;
endmodule
