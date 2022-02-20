`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:35:39 12/15/2020 
// Design Name: 
// Module Name:    EX_MEMController 
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

module EX_MEMController(
	input wire [31:0] EX_MEM_Instr,
	input wire [31:0] MEM_WB_Instr,
	input wire [4:0] MEM_WB_WAddr,
	input wire [1:0] ALULast,
	
	output wire [3:0] MemWrite,
	output wire [3:0] MemRead,
	output wire LoadSigned,
	
	//output wire [3:0] DMSrc,//DM�ĵ�ַ����Ҫ�õ��Ĵ�������ַ��ֵ����ALU�����
	output wire [3:0] Tnew
    );
	
	wire [31:0] Instr = EX_MEM_Instr;
	wire [5:0] Op = Instr[`OP];
	wire [5:0] Func = Instr[`FUNC];
	
	assign MemWrite = Op == `SB & ALULast[1:0] == 2'b00 ? 4'b0001 :
					  Op == `SB & ALULast[1:0] == 2'b01 ? 4'b0010 :
					  Op == `SB & ALULast[1:0] == 2'b10 ? 4'b0100 :
					  Op == `SB & ALULast[1:0] == 2'b11 ? 4'b1000 :
					  Op == `SH & ALULast[1] == 1'b0 ? 4'b0011 :
					  Op == `SH & ALULast[1] == 1'b1 ? 4'b1100 :
					  Op == `SW ? 4'b1111 : 4'h0;
	assign MemRead = (Op == `LB | Op == `LBU) & ALULast[1:0] == 2'b00 ? 4'b0001 :
					  (Op == `LB | Op == `LBU) & ALULast[1:0] == 2'b01 ? 4'b0010 :
					  (Op == `LB | Op == `LBU) & ALULast[1:0] == 2'b10 ? 4'b0100 :
					  (Op == `LB | Op == `LBU) & ALULast[1:0] == 2'b11 ? 4'b1000 :
					  (Op == `LH | Op == `LHU) & ALULast[1] == 1'b0 ? 4'b0011 :
					  (Op == `LH | Op == `LHU) & ALULast[1] == 1'b1 ? 4'b1100 :
					  Op == `LW ? 4'b1111 : 4'h0;
	assign LoadSigned = Op == `LB | Op == `LH ? 1 : 0;
	
	//����ת��
	wire [4:0] RAddr = EX_MEM_Instr[`RT];//RAddr��һ���ǵ���"rt"�����ڲ�ͬ��ָ�����ʹ�õĲ�ͬ������Op�����жϡ�
										 //����ֻ��swָ��Ҫ��rt�Ĵ�����ֵ
	
	//assign DMSrc = RAddr == MEM_WB_WAddr && RAddr != 0 ? 4'b0001 : 
	//			   4'b0000;

	//��ͣ��ת���ź�

	assign Tnew = Op == `LB | Op == `LBU |
				  Op ==`LH | Op == `LHU | Op == `LW ? 4'b0001 : 4'b0000;
	
endmodule
