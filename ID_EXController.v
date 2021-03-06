`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:30:22 12/15/2020 
// Design Name: 
// Module Name:    ID_EXController 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module ID_EXController(
	input wire [31:0] ID_EX_Instr,
	input wire [4:0] EX_MEM_WAddr,
	input wire [4:0] MEM_WB_WAddr,
	
	input wire Busy,
	
	
	output wire [3:0] ALUOp,
	output wire ALUSrc1, ALUSrc2,       // to seperate the transmit and the data path
	output wire CalcuSigned,
	output wire [1:0] MDOp,
	output wire [1:0] MDWrite,
	output wire [3:0] EX_ALUResultSrc,
	
	
	output wire [3:0] ALUSrc_RData1,// set two ALUSrc
	output wire [3:0] ALUSrc_RData2,
	output wire [3:0] DMSrc,
	output wire [3:0] Tnew,
	
	output wire Install
    );
	
	
	
	assign MDOp = Op == `CALCU ? 
				  Func == `MULT_FUNC | Func == `MULTU_FUNC? 2'b01 :
				  Func == `DIV_FUNC | Func == `DIVU_FUNC ? 2'b10 : 2'b00 : 2'b00;
	assign CalcuSigned = Op == `ADDI | Op == `SLTI | Op == `CALCU &
						 Func == `ADD_FUNC | Func == `SUB_FUNC | Func == `SLT_FUNC |
						 Func == `MULT_FUNC | Func == `DIV_FUNC;
	assign ALUSrc1 = Op == `CALCU & (Func == `SLL_FUNC | Func == `SRL_FUNC | Func == `SRA_FUNC);
	
	assign ALUSrc2 = Op == `ORI | Op == `ADDI | Op == `ADDIU | Op == `ANDI |
					Op == `XORI | Op == `LUI | Op == `LB | Op == `LBU |
					Op == `LH | Op == `LHU | Op == `LW | Op == `SB |
					Op == `SH | Op == `SW | Op == `SLTI | Op == `SLTIU;
	assign MDWrite = Op == `CALCU & Func == `MTHI_FUNC ? 2'b01 :
					 Op == `CALCU & Func == `MTLO_FUNC ? 2'b10 : 2'b00;
	assign EX_ALUResultSrc = Op == `CALCU & (Func == `SLT_FUNC | Func == `SLTU_FUNC) |
							 Op == `SLTI | Op == `SLTIU ? 4'h1 :
							 Op == `JAL | Op == `CALCU & Func == `JALR_FUNC ? 4'h2 :
							 Op == `CALCU & Func == `MFHI_FUNC ? 4'h3 :
							 Op == `CALCU & Func == `MFLO_FUNC ? 4'h4 : 4'h0;
	assign ALUOp = Op == `CALCU & (Func == `ADD_FUNC | Func == `ADDU_FUNC) | Op == `ADDI ? 4'h0 :
				   Op == `CALCU & (Func == `SUB_FUNC | Func == `SUBU_FUNC) ? 4'h1 :
				   Op == `CALCU & Func == `OR_FUNC | Op == `ORI ? 4'h2 :
				   Op == `CALCU & Func == `AND_FUNC | Op == `ANDI ? 4'h3 :
				   Op == `CALCU & Func == `XOR_FUNC | Op == `XORI ? 4'h4 :
				   Op == `CALCU & Func == `NOR_FUNC ? 4'h5 :
				   Op == `CALCU & (Func == `SLL_FUNC | Func == `SLLV_FUNC) ? 4'h6 :
				   Op == `CALCU & (Func == `SRL_FUNC | Func == `SRLV_FUNC) ? 4'h7 :
				   Op == `CALCU & (Func == `SRA_FUNC | Func == `SRAV_FUNC) ? 4'h8 :
				   4'h0;
				   
	
	
	//????????	
	wire [31:0] Instr = ID_EX_Instr[31:0];
	wire [5:0] Op = ID_EX_Instr[`OP];
	wire [5:0] Func = ID_EX_Instr[`FUNC];
	
	wire [4:0] RAddr1= Instr[`RS];//??????????Instr????????????????????????????????
	wire [4:0] RAddr2 = Instr[`RT];//??????????????????????????????????????
							//??????????????JAL??jalr????????????????????????
	assign ALUSrc_RData1 = RAddr1 == EX_MEM_WAddr && RAddr1 != 0 ? 4'b0001 :
						   RAddr1 == MEM_WB_WAddr && RAddr1 != 0 ? 4'b0010 :
						   4'b0000;
	assign ALUSrc_RData2 = RAddr2 == EX_MEM_WAddr && RAddr2 != 0 ? 4'b0001 :
						   RAddr2 == MEM_WB_WAddr && RAddr2 != 0 ? 4'b0010 : 
						   4'b0000;
	assign DMSrc = 		   RAddr2 == EX_MEM_WAddr && RAddr2 != 0 ? 4'b0001 :
						   RAddr2 == MEM_WB_WAddr && RAddr2 != 0 ? 4'b0010 : 
						   4'b0000;//DMSrc??????????
	///////////??????????????????//////////////////////////////////////////////////////
	assign Tnew =	   Op == `ORI | Op == `ADDI | Op == `ADDIU | Op == `ANDI | Op == `XORI |
					   Op == `LUI | Op == `SLTI | Op == `SLTIU |
					   Op == `SH | Op == `SW |  Op == `SB |
					   Op == `CALCU & (Func == `ADDU_FUNC | Func == `SUBU_FUNC | Func == `ADD_FUNC |
					   Func == `SUB_FUNC | Func == `OR_FUNC | Func == `AND_FUNC | Func == `XOR_FUNC |
					   Func == `NOR_FUNC | Func == `SLLV_FUNC | Func == `SRLV_FUNC | Func == `SRAV_FUNC|
					   Func == `SLL_FUNC | Func == `SRL_FUNC | Func == `SRA_FUNC |
					   Func == `SLT_FUNC | Func == `SLTU_FUNC) ? 4'h1 : 
					   Op == `LB | Op == `LBU | Op ==`LH |
					   Op == `LHU | Op == `LW ? 4'h2 : 4'h0;
//////////////////??????????//////////////////////////////////////
	assign Install =Busy & Op == `CALCU & (Func == `MULT_FUNC | Func == `MULTU_FUNC |
					Func == `DIV_FUNC | Func == `DIVU_FUNC | Func == `MFHI_FUNC | Func == `MTHI_FUNC |
					Func == `MFLO_FUNC | Func == `MTLO_FUNC);		   
	
					   
	
endmodule
