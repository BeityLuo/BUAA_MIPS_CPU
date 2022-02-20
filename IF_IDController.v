`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:05:15 12/15/2020 
// Design Name: 
// Module Name:    IF_IDController 
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
`define MAXTUSE  4'b0111

module IF_IDController(
	input wire [31:0] IF_ID_Instr,

	//����ת������ͣ���ź�
	input wire [4:0] ID_EX_WAddr,
	input wire [4:0] EX_MEM_WAddr,//the write-register's address
	input wire [4:0] MEM_WB_WAddr,
	input wire [3:0] ID_EX_Tnew,
	input wire [3:0] EX_MEM_Tnew,
	input wire [3:0] MEM_WB_Tnew,
	
	output wire Lui,
	output wire SLeftEXT_imm16,
	output wire LeftEXT_imm5,
	
	output wire [3:0] Branch,
	// ��������Branch����PCSrcMux
	output wire RsToPC,
	output wire J_imm26,
	//��������ת�������ź�
	output wire [3:0] CMPSrc_rs,
	output wire [3:0] CMPSrc_rt,
	output wire [3:0] PCSrc_RsToPC,
	
	
	//������ͣ�ź�
	output wire Install,
	
	output wire [4:0] WAddr
    );
	//��������ͨ·�ź�
	wire [31:0] Instr = IF_ID_Instr[31:0];
	wire [5:0] Op = IF_ID_Instr[`OP];
	wire [5:0] Func = IF_ID_Instr[`FUNC];
	

	assign Branch = Op == `BEQ ? 4'b0001 :
					Op == `BNE ? 4'b0010 :
					Op == `BLTZ & Instr[`RT] != `BGEZ_RT ? 4'b0011 :
					Op == `BLEZ ? 4'b0100 :
					Op == `BGTZ ? 4'b0101 :
					Op == `BGEZ ? 4'b0110 :
					4'b0000;
	assign SLeftEXT_imm16 = Op == `BEQ | Op == `BNE | Op == `BLTZ |
							Op == `BLEZ | Op == `BGTZ | Op == `BGEZ |
							Op == `ADDI | Op == `ADDIU | Op == `SLTI | Op == `SLTIU |
							Op == `LB | Op == `LBU | Op ==`LH | 
							Op == `LHU | Op == `LW | Op == `SB |
							Op == `SH | Op == `SW;
	assign Lui = Op == `LUI;
	assign RsToPC = Op == `CALCU & (Func == `JR_FUNC | Func == `JALR_FUNC);
	assign J_imm26 = Op == `J | Op == `JAL;
	assign LeftEXT_imm5 = Op == `CALCU & (Func == `SLL_FUNC | Func == `SRL_FUNC |
						  Func == `SRA_FUNC);
	
	

	//����ת���ź�
	//RAddr1��Ҫʹ�õĵ�һ���Ĵ�����ַ�������϶Բ�ͨ����ָ���ַ��ͬ�����������Ϊrs
	//����û��ֱ�Ӹ�ֵΪrs/rt��ԭ���ǣ�������ͣ�ź�ʱ��Ȼ��Ҫʹ��RAddr
	wire [4:0] RAddr1 =Op == `BEQ | Op == `BNE | Op == `BLEZ | Op == `BGTZ |
					   Op == `BLTZ | Op == `BGEZ |
					   Op == `CALCU & (Func == `JR_FUNC | Func == `JALR_FUNC) |
					   Op == `ORI | Op == `ADDI | Op == `ADDIU | Op == `ANDI | Op == `XORI |
					   Op == `LUI | Op == `SLTI | Op == `SLTIU |
					   Op == `LB | Op == `LBU | Op ==`LH |
					   Op == `LHU | Op == `LW | Op == `SB |
					   Op == `SH | Op == `SW |
					   Op == `CALCU & (Func == `ADDU_FUNC | Func == `SUBU_FUNC | Func == `ADD_FUNC |
					   Func == `SUB_FUNC | Func == `OR_FUNC | Func == `AND_FUNC | Func == `XOR_FUNC |
					   Func == `NOR_FUNC | Func == `SLLV_FUNC | Func == `SRLV_FUNC | Func == `SRAV_FUNC|
					   Func == `SLL_FUNC | Func == `SRL_FUNC | Func == `SRA_FUNC |
					   Func == `SLT_FUNC | Func == `SLTU_FUNC) ? Instr[`RS] : 5'b00000;
	wire [4:0] RAddr2 =Op == `BEQ | Op == `BNE | Op == `BLEZ | Op == `BGTZ |
					   Op == `CALCU & (Func == `ADDU_FUNC | Func == `SUBU_FUNC | Func == `ADD_FUNC |
					   Func == `SUB_FUNC | Func == `OR_FUNC | Func == `AND_FUNC | Func == `XOR_FUNC |
					   Func == `NOR_FUNC | Func == `SLLV_FUNC | Func == `SRLV_FUNC | Func == `SRAV_FUNC|
					   Func == `SLT_FUNC | Func == `SLTU_FUNC | Func == `SLL_FUNC | Func == `SRL_FUNC | 
					   Func == `SRA_FUNC) |
					   Op == `SB | Op == `SH | Op == `SW ? Instr[`RT] : 5'b00000;
	
	assign CMPSrc_rs = RAddr1 == EX_MEM_WAddr && RAddr1 != 0 ? 4'b0001 : 
					   RAddr1 == MEM_WB_WAddr && RAddr1 != 0 ? 4'b0010 :
					   RAddr1 == ID_EX_WAddr && RAddr1 != 0 ? 4'b0011 :
					   4'b0000;
	assign PCSrc_RsToPC = CMPSrc_rs;
	assign CMPSrc_rt = RAddr2 == EX_MEM_WAddr && RAddr2 != 0 ? 4'b0001 : 
					   RAddr2 == MEM_WB_WAddr && RAddr2 != 0 ? 4'b0010 :
					   RAddr2 == ID_EX_WAddr && RAddr2 != 0 ? 4'b0011 :
					   4'b0000;
	//////////////////������д���źţ��������´�///////////////
	assign WAddr = 	   Op == `CALCU & (Func == `ADDU_FUNC | Func == `SUBU_FUNC | Func == `ADD_FUNC |
					   Func == `SUB_FUNC | Func == `OR_FUNC | Func == `AND_FUNC | Func == `XOR_FUNC |
					   Func == `NOR_FUNC | Func == `SLLV_FUNC | Func == `SRLV_FUNC | Func == `SRAV_FUNC|
					   Func == `SLL_FUNC | Func == `SRL_FUNC | Func == `SRA_FUNC |
					   Func == `SLT_FUNC | Func == `SLTU_FUNC |
					   Func == `JALR_FUNC | Func == `MFHI_FUNC | Func == `MFLO_FUNC) ? Instr[`RD] :
					   Op == `ORI | Op == `ADDI | Op == `ADDIU | Op == `ANDI | Op == `XORI |
					   Op == `LUI | Op == `SLTI | Op == `SLTIU | Op == `LB | Op == `LBU |
					   Op ==`LH | Op == `LHU | Op == `LW ? Instr[`RT] :
					   Op == `JAL ? 5'b11111 : 5'b00000;
	
	
	
	//������ͣ�ź�
	wire [3:0] Tuse1 = Op == `BEQ | Op == `BNE | Op == `BLEZ | Op == `BGTZ |
					   Op == `BLTZ | Op == `BGEZ |
					   Op == `CALCU & (Func == `JR_FUNC | Func == `JALR_FUNC) ? 0 :
					   Op == `ORI | Op == `ADDI | Op == `ADDIU | Op == `ANDI | Op == `XORI |
					   Op == `LUI | Op == `SLTI | Op == `SLTIU |
					   Op == `LB | Op == `LBU | Op ==`LH |
					   Op == `LHU | Op == `LW | Op == `SB |
					   Op == `SH | Op == `SW |
					   Op == `CALCU & (Func == `ADDU_FUNC | Func == `SUBU_FUNC | Func == `ADD_FUNC |
					   Func == `SUB_FUNC | Func == `OR_FUNC | Func == `AND_FUNC | Func == `XOR_FUNC |
					   Func == `NOR_FUNC | Func == `SLLV_FUNC | Func == `SRLV_FUNC | Func == `SRAV_FUNC|
					   Func == `SLL_FUNC | Func == `SRL_FUNC | Func == `SRA_FUNC |
					   Func == `SLT_FUNC | Func == `SLTU_FUNC) ? 1 : 
					   `MAXTUSE;
	wire [3:0] Tuse2 = Op == `BEQ | Op == `BNE | Op == `BLEZ | Op == `BGTZ ? 0 :
					   Op == `CALCU & (Func == `ADDU_FUNC | Func == `SUBU_FUNC | Func == `ADD_FUNC |
					   Func == `SUB_FUNC | Func == `OR_FUNC | Func == `AND_FUNC | Func == `XOR_FUNC |
					   Func == `NOR_FUNC | Func == `SLLV_FUNC | Func == `SRLV_FUNC | Func == `SRAV_FUNC|
					   Func == `SLT_FUNC | Func == `SLTU_FUNC | Func == `SLL_FUNC | Func == `SRL_FUNC | 
					   Func == `SRA_FUNC) |
					   Op == `SB | Op == `SH | Op == `SW ? 1 : `MAXTUSE;
	
	assign Install =RAddr1 == ID_EX_WAddr & RAddr1 != 0 & Tuse1 < ID_EX_Tnew |
					RAddr1 == EX_MEM_WAddr & RAddr1 != 0 & Tuse1 < EX_MEM_Tnew |
					RAddr1 == MEM_WB_WAddr & RAddr1 != 0 & Tuse1 < MEM_WB_Tnew |
					RAddr2 == ID_EX_WAddr & RAddr2 != 0 & Tuse2 < ID_EX_Tnew |
					RAddr2 == EX_MEM_WAddr & RAddr2 != 0 & Tuse2 < EX_MEM_Tnew |
					RAddr2 == MEM_WB_WAddr & RAddr2 != 0 & Tuse2 < MEM_WB_Tnew;


endmodule