module priority_encoder_8bits(A,Q,V);
input [7:0]A ;
output [2:0]Q ;
output V ;

wire o6 ;

LUT6#(
 .INIT(64'hFFFFFFFFFFFF000E) //SpecifyLUTContents
 )LUT6_instp0(
 .O(Q[1]), //LUTgeneraloutput
 .I0(A[2]),//LUTinput
 .I1(A[3]),//LUTinput
 .I2(A[4]),//LUTinput
 .I3(A[5]),//LUTinput
 .I4(A[6]),//LUTinput
 .I5(A[7]) //LUTinput
 );
 
  LUT6_2#(
 .INIT(64'hFF0CFF0CFFFFFFFE)//SpecifyLUTContents
 )LUT6_2_instp1(
 .O6(o6),//1-bitLUT6output
 .O5(V),//1-bitlowerLUT5output
 .I0(A[0]),//1-bitLUTinput
 .I1(A[1]),//1-bitLUTinput
 .I2(A[2]),//1-bitLUTinput
 .I3(A[3]),//1-bitLUTinput
 .I4(Q[2]),//1-bitLUTinput
 .I5(1'b1) //1-bitLUTinput(fastMUXselectonlyavailabletoO6output)
 );
 
 LUT6_2#(
 .INIT(64'hFFFF00F2FFFFFFFC)//SpecifyLUTContents
 )LUT6_2_instp2(
 .O6(Q[0]),//1-bitLUT6output
 .O5(Q[2]),//1-bitlowerLUT5output
 .I0(o6),//1-bitLUTinput
 .I1(A[4]),//1-bitLUTinput
 .I2(A[5]),//1-bitLUTinput
 .I3(A[6]),//1-bitLUTinput
 .I4(A[7]),//1-bitLUTinput
 .I5(1'b1) //1-bitLUTinput(fastMUXselectonlyavailabletoO6output)
 );
 

endmodule

