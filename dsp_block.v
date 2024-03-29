/*
 * Date        :                       25/2/2024
 *********************************************************************************************************************************************
 * Author      :                       Youssef Khaled
 *********************************************************************************************************************************************
 * File Name   :                       dsp_block.v
 *********************************************************************************************************************************************
 * Module Name :                       dsp_block
 *********************************************************************************************************************************************
 * Describtion :                       The Spartan-6 family offers a high ratio of DSP48A1 slices to logic , making it ideal for math-
 *                                     intensive applications.The DSP48A1 is derived from the DSP48A slice in Extended Spartan-3A FPGA
 *                                     Many DSP algorithms are supported with minimal use of the general-purpose FPGA logic, resulting
 *                                     in low power, high performance,and efficient device utilization.At first look,the DSP48A1 slice
 *                                     contains an 18-bit input pre-adder followed by an 18 x 18 bit two’s complement multiplier and a 
 *                                     48-bit sign-extended adder/subtracter/accumulator, a function that is widely used in digital si
 *                                     gnal processing. A second look reveals many subtle features that enhance the usefulness, versat
 *                                     ility, and speed of this arithmetic building block. Programmable pipelining of input operands,i
 *                                     ntermediate products, and accumulator outputs enhances throughput. The 48-bit internal bus allo
 *                                     ws for practically unlimited aggregation of DSP slices.The C input port allows the formation of
 *                                     many 3-input mathematical functions, such as 3-input addition by cascading the pre-adder with t
 *                                     he post-adder, and 2-input multiplication with a single addition. The D input allows a second a
 *                                     rgument to be used with the pre-adder to reduce DSP48A1 slice utilization in symmetric filters.
 *********************************************************************************************************************************************
*/


module dsp_block(A,B,D,C,CLK,CARRYIN,OPMODE,BCIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE
	            ,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);

parameter A0REG = 0;
parameter A1REG = 1;
parameter B0REG = 0;
parameter B1REG = 1;

parameter CREG 		  = 1;
parameter DREG 		  = 1;
parameter MREG 		  = 1;
parameter PREG 		  = 1;
parameter CARRYINREG  = 1;
parameter CARRYOUTREG = 1;
parameter OPMODEREG   = 1;

parameter CARRYINSEL  = "OPMODE5";

parameter B_INPUT     = "DIRECT";

parameter RSTTYPE     = "SYNC";

input [17:0] A,B,D,BCIN;
input [47:0] C,PCIN;
input CLK,CARRYIN;
input [7:0] OPMODE;
input RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE;
input CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE;

output [17:0] BCOUT;
output [47:0] PCOUT,P;
output [35:0] M;
output CARRYOUT,CARRYOUTF;

wire [17:0] B0; 

assign B0 = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 0;


wire [17:0] D_mux_out,A0_mux_out,B0_mux_out;
wire [47:0] C_mux_out;
wire [7:0] OPMODE_mux_out;


reg_mux #(.N(8),.RSTTYPE(RSTTYPE),.SEL(OPMODEREG)) reg_mux_OPMODE(.data(OPMODE),.clk(CLK),
          .rst(RSTOPMODE),.ce(CEOPMODE),.out(OPMODE_mux_out));

reg_mux #(.N(18),.RSTTYPE(RSTTYPE),.SEL(DREG)) reg_mux_D(.data(D),.clk(CLK),.rst(RSTD),.ce(CED),.out(D_mux_out));
reg_mux #(.N(18),.RSTTYPE(RSTTYPE),.SEL(B0REG)) reg_mux_B0(.data(B0),.clk(CLK),.rst(RSTB),.ce(CEB),.out(B0_mux_out));
reg_mux #(.N(18),.RSTTYPE(RSTTYPE),.SEL(A0REG)) reg_mux_A0(.data(A),.clk(CLK),.rst(RSTA),.ce(CEA),.out(A0_mux_out));
reg_mux #(.N(48),.RSTTYPE(RSTTYPE),.SEL(CREG)) reg_mux_C(.data(C),.clk(CLK),.rst(RSTC),.ce(CEC),.out(C_mux_out));

wire [17:0] pre_addsub_out;
assign pre_addsub_out = OPMODE_mux_out[6] ? (D_mux_out - B0_mux_out) : (D_mux_out + B0_mux_out) ;

wire [17:0] B1_reg_data;
assign B1_reg_data    = OPMODE_mux_out[4] ? pre_addsub_out  : B0_mux_out;

wire [17:0] A1_mux_out,B1_mux_out;


reg_mux #(.N(18),.RSTTYPE(RSTTYPE),.SEL(B1REG)) reg_mux_B1(.data(B1_reg_data),.clk(CLK),.rst(RSTB),.ce(CEB),.out(B1_mux_out));
reg_mux #(.N(18),.RSTTYPE(RSTTYPE),.SEL(A1REG)) reg_mux_A1(.data(A0_mux_out),.clk(CLK),.rst(RSTA),.ce(CEA),.out(A1_mux_out));

wire [47:0] D_A_B_concatenated;
assign D_A_B_concatenated = {D_mux_out[11:0] , A1_mux_out[17:0] , B1_mux_out[17:0]};
assign BCOUT = B1_mux_out;

wire [35:0] multiplier_out;
assign multiplier_out = A1_mux_out * B1_mux_out;

wire [35:0] M_mux_out;
reg_mux #(.N(36),.RSTTYPE(RSTTYPE),.SEL(MREG)) reg_mux_M(.data(multiplier_out),.clk(CLK),.rst(RSTM),.ce(CEM),.out(M_mux_out));

/* buffering M without specifying delays has no meaning , but it will be added if it is needed for some reason */

generate
	genvar i;
	for(i = 0;i<36;i=i+1)
		buf(M[i],M_mux_out[i]); //as buf take only scalar(1 bit)
endgenerate

wire [47:0] X_mux_out,Z_mux_out;
// by default M_mux_out will extend by zeros to be suitable for X_mux_out if it was chosen , no need to manually extend it
assign X_mux_out = (OPMODE_mux_out[1:0] == 0) ? 0
                   : (OPMODE_mux_out[1:0] == 1) ? M_mux_out
                   : (OPMODE_mux_out[1:0] == 2) ? P 
                   : D_A_B_concatenated ;   

assign Z_mux_out = (OPMODE_mux_out[3:2] == 0) ? 0
                   : (OPMODE_mux_out[3:2] == 1) ? PCIN
                   : (OPMODE_mux_out[3:2] == 2) ? P 
                   : C_mux_out ;  

 wire CARRYIN_mux_out;
 assign CARRYIN_mux_out = (CARRYINSEL == "OPMODE5") ? OPMODE_mux_out[5] : (CARRYINSEL == "CARRYIN") ? CARRYIN : 0;

wire CIN;
reg_mux #(.N(1),.RSTTYPE(RSTTYPE),.SEL(CARRYINREG)) reg_mux_CYI(.data(CARRYIN_mux_out),.clk(CLK),.rst(RSTCARRYIN),.ce(CECARRYIN),.out(CIN));

wire[47:0] post_addsub_out;
wire CO;

assign {CO,post_addsub_out}  = OPMODE_mux_out[7] ? Z_mux_out - ( X_mux_out + CIN) : Z_mux_out + X_mux_out + CIN ;
assign PCOUT = P;
assign CARRYOUTF = CARRYOUT;

reg_mux #(.N(48),.RSTTYPE(RSTTYPE),.SEL(PREG)) reg_mux_P(.data(post_addsub_out),.clk(CLK),.rst(RSTP),.ce(CEP),.out(P));
reg_mux #(.N(1),.RSTTYPE(RSTTYPE),.SEL(CARRYOUTREG)) reg_mux_CYO(.data(CO),.clk(CLK),.rst(RSTCARRYIN),.ce(CECARRYIN),.out(CARRYOUT));

endmodule