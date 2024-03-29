/*
 * Date        :                       27/2/2024
 *****************************************************************************************************************************
 * Author      :                       Youssef Khaled
 *****************************************************************************************************************************
 * File Name   :                       dsp_block_tb.v
 *****************************************************************************************************************************
 * Module Name :                       dsp_block_tb
 *****************************************************************************************************************************
 * Describtion :                       simple directed testbench testing different operations for the DSP block
 *****************************************************************************************************************************
*/

`timescale 10ns/1ns
module dsp_block_tb();

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

reg [17:0] A,B,D;
reg [47:0] C,PCIN;
reg CLK,CARRYIN;
reg [7:0] OPMODE;
reg RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE;
reg CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE;

reg [17:0] BCIN;

wire [17:0] BCOUT;
wire [47:0] PCOUT,P;
wire [35:0] M;
wire CARRYOUT,CARRYOUTF;

dsp_block #(.A0REG(A0REG),.A1REG(A1REG),.B0REG(B0REG),.B1REG(B1REG),.CREG(CREG),.DREG(DREG),.MREG(MREG),.PREG(PREG),
	        .CARRYINREG(CARRYINREG),.CARRYOUTREG(CARRYOUTREG),.OPMODEREG(OPMODEREG),.CARRYINSEL(CARRYINSEL),.B_INPUT(B_INPUT),
	        .RSTTYPE(RSTTYPE)) dut(.A(A),.B(B),.D(D),.C(C),.CLK(CLK),.CARRYIN(CARRYIN),.OPMODE(OPMODE),.BCIN(BCIN),.RSTA,
	        .RSTB(RSTB),.RSTM(RSTM),.RSTP(RSTP),.RSTC(RSTC),.RSTD(RSTD),.RSTCARRYIN(RSTCARRYIN),
	        .RSTOPMODE(RSTOPMODE),.CEA(CEA),.CEB(CEB),.CEM(CEM),.CEP(CEP),.CEC(CEC),.CED(CED),
	        .CECARRYIN(CECARRYIN),.CEOPMODE(CEOPMODE),.PCIN(PCIN),.BCOUT(BCOUT),.PCOUT(PCOUT),.P(P),.M(M),.CARRYOUT(CARRYOUT),
	        .CARRYOUTF(CARRYOUTF));

initial begin
	CLK = 0;
	forever 
	#1 CLK = ~CLK;
end

initial begin

	RSTA = 1;
	RSTB = 1;
	RSTM = 1;
	RSTP = 1;
	RSTC =1;
	RSTD = 1;
	RSTCARRYIN = 1;
	RSTOPMODE = 1;
	CEA = 1;
	CEB = 1;
	CEM = 1;
	CEP = 1;
	CEC = 1;
	CED = 1;
	CECARRYIN = 1;
	CEOPMODE = 1;

	A = 20;
	B = 50;
	C = 10;
	D = 100;
	CARRYIN = 0;
	BCIN = 5;
	PCIN = 40;

	OPMODE[6] = 0; 
	OPMODE[4] = 1;
	OPMODE[5] = 1;
	OPMODE[1:0] = 1;
	OPMODE[3:2] = 3;
	OPMODE[7] = 0;

	repeat(5) @(negedge CLK);


	A = 20;
	B = 50;
	C = 10;
	D = 100;
	CARRYIN = 0;

	RSTA = 0;
	RSTB = 0;
	RSTM = 0;
	RSTP = 0;
	RSTC = 0;
	RSTD = 0;
	RSTCARRYIN = 0;
	RSTOPMODE = 0;


	OPMODE[6] = 0; 
	OPMODE[4] = 1;
	OPMODE[5] = 1;
	OPMODE[1:0] = 1;
	OPMODE[3:2] = 3;
	OPMODE[7] = 0;
	repeat(5) @(negedge CLK);

	A = 10;
	B = 30;
	C = 500;
	D = 50;

	OPMODE[6] = 0; 
	OPMODE[4] = 0;
	OPMODE[5] = 0;
	OPMODE[1:0] = 1;
	OPMODE[3:2] = 1;
	OPMODE[7] = 0;
	repeat(10) @(negedge CLK);

	A = 5;
	B = 6;
	C = 7;
	D = 8;

	OPMODE[6] = 1; 
	OPMODE[4] = 1;
	OPMODE[5] = 1;
	OPMODE[1:0] = 0;
	OPMODE[3:2] = 2;
	OPMODE[7] = 0;
	repeat(5) @(negedge CLK);

 	A = 5;
	B = 4;
	C = 1;
	D = 10;

	OPMODE[6] = 1; 
	OPMODE[4] = 1;
	OPMODE[5] = 1;
	OPMODE[1:0] = 1;
	OPMODE[3:2] = 0;
	OPMODE[7] = 0;
	repeat(5) @(negedge CLK);

	A = 8;
	B = 2;
	C = 7;
	D = 6;

	OPMODE[6] = 0; 
	OPMODE[4] = 1;
	OPMODE[5] = 1;
	OPMODE[1:0] = 2;
	OPMODE[3:2] = 3;
	OPMODE[7] = 0;
	repeat(5) @(negedge CLK);

	A = 11;
	B = 24;
	C = 13;
	D = 50;

	OPMODE[6] = 1; 
	OPMODE[4] = 1;
	OPMODE[5] = 0;
	OPMODE[1:0] = 0;
	OPMODE[3:2] = 0;
	OPMODE[7] = 1;
	repeat(5) @(negedge CLK);
	$stop;
end 
endmodule