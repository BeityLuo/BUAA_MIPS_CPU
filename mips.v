`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:37:01 11/24/2020 
// Design Name: 
// Module Name:    mips 
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
module mips(
	input wire clk,
    input wire reset
    );
	// reg clk;
	// reg reset;
	// initial begin
	// 	clk = 0;
	// 	reset = 1;
	// 	#5 reset = 0;
	// end
	// always #10 clk = ~clk;
	
	//元件的输出接口 
	wire [31:0] PC_Out;
	wire [31:0] IM_Out;
	wire [31:0] Adder_Out, NAdder_Out;
	
	wire [31:0] GRF_RData1, GRF_RData2;
	wire [31:0] EXT_Out;
	wire [31:0] Shifter_Out;
	wire [31:0] CMPSrcMux_rs, CMPSrcMux_rt;
	wire [31:0] PCSrcMux_Out;
	
	wire [31:0] ALU_Out;
	wire ALU_Overflow;
	wire [31:0] ALUSrcMux_Out1, ALUSrcMux_Out2;
	wire [31:0] CMP_LessThan_Out;
	wire [31:0] MD_HI, MD_LO;
	wire [31:0] DMSrcMux_Out;
	wire [31:0] EX_ALUResultSrcMux_Out;
	
	wire [31:0] DM_Out;
	wire [31:0] MemEXT_Out;

	wire [31:0] regWriteMux_Out;
	
	wire [4:0] IF_ID_WAddr, ID_EX_WAddr, EX_MEM_WAddr, MEM_WB_WAddr;

//////////////////////流水寄存器的输出接口///////////////////////////////////////
	
	
	wire [31:0] IF_ID_PC, IF_ID_Instr;
	
	wire [31:0] ID_EX_Instr, ID_EX_RData1, ID_EX_RData2;
	wire [31:0] ID_EX_PC, ID_EX_imm32;
	
	wire [31:0] EX_MEM_Instr, EX_MEM_ALUResult, EX_MEM_RData2, EX_MEM_PC;
	wire EX_MEM_Overflow;
	
	wire [31:0] MEM_WB_Instr, MEM_WB_Data, MEM_WB_ALUResult, MEM_WB_PC;
	wire MEM_WB_Overflow;
	
///////////////数据通路控制信号的接口//////////////////////////////////////////////
	
	wire Lui, SLeftEXT_imm16, LeftEXT_imm5, RsToPC, J_imm26;
	wire [3:0] Branch, CMPSrc_rs, CMPSrc_rt, PCSrc_RsToPC;
	wire Cmp;
	
	wire ALUSrc1, ALUSrc2, CalcuSigned;
	wire [1:0] MDOp, MDWrite;
	wire [3:0] ALUOp, EX_ALUResultSrc, ALUSrc_RData1, ALUSrc_RData2, DMSrc;
	wire Busy;

	wire LoadSigned;
	wire [3:0] MemWrite, MemRead;

	wire MemToReg, PCToReg, RegWrite;


	//暂停控制信号的输出接口
	wire IF_IDInstall, ID_EXInstall;
	wire PCEnable, IF_IDEnable, ID_EXEnable;
	wire ID_EXClear, EX_MEMClear;
	//控制器之间的寄存器地址、Tnew等信号
	wire [3:0] ID_EX_Tnew, EX_MEM_Tnew, MEM_WB_Tnew;

	
	//==============IF段=========================================
	PC PC(
		.Addr(PCSrcMux_Out),
		.clk(clk),
		.reset(reset),
		.enable(PCEnable),
		.Out(PC_Out)
	);
	
	IM IM(
		.Addr(PC_Out[13:2]),
		.Out(IM_Out)
	);
	
	Adder Adder(
		.PC(PC_Out),
		.Out(Adder_Out)
	);
	//注意！要使用NAdder永远在ID级使用，使用的是上一个PC，Adder是下一个PC，不能用
	NAdder NAdder(
		.Shifter(Shifter_Out),
		.PC(IF_ID_PC),
		.Out(NAdder_Out)
	);
	
	IF_ID IF_ID(
		.PC(PC_Out),
		.Instr(IM_Out),
		.clk(clk),
		.reset(reset),
		.enable(IF_IDEnable),
		.Out_PC(IF_ID_PC),
		.Out_Instr(IF_ID_Instr)
	);
	//==============ID段=========================================
	always @(*) begin
		//$monitor("IF_ID_Instr[`RS] = %h\n", IF_ID_Instr[`RS]);
	end

	GRF GRF(
		.PC(MEM_WB_PC),
		.R1(IF_ID_Instr[`RS]),
		.R2(IF_ID_Instr[`RT]),
		.WReg(MEM_WB_WAddr),
		.Data(regWriteMux_Out),
		.clk(clk),
		.reset(reset),
		.RegWrite(RegWrite),
		.RData1(GRF_RData1),
		.RData2(GRF_RData2)
	);
	EXT EXT(
		.imm16(IF_ID_Instr[`IMM16]),
		.imm26(IF_ID_Instr[`IMM26]),
		.imm5(IF_ID_Instr[`SA]),
		.Lui(Lui),
		.J_imm26(J_imm26),
		.SLeftEXT_imm16(SLeftEXT_imm16),
		.LeftEXT_imm5(LeftEXT_imm5),
		.Out(EXT_Out)
	);
	Shifter Shifter(
		.EXT(EXT_Out),
		.Out(Shifter_Out)
	);
	
	CMP CMP(
		.RData1(CMPSrcMux_rs),
		.RData2(CMPSrcMux_rt),
		.Branch(Branch),
		.Cmp(Cmp)
	);
	CMPSrcMux CMPSrcMux(
		.RData1(GRF_RData1),
		.RData2(GRF_RData2),
		.ID_EX_PC(ID_EX_PC),
		.EX_MEM_ALUResult(EX_MEM_ALUResult),
		.MEM_WB_regWriteMux(regWriteMux_Out),
		.CMPSrc_rs(CMPSrc_rs),
		.CMPSrc_rt(CMPSrc_rt),
		.Out_rs(CMPSrcMux_rs),
		.Out_rt(CMPSrcMux_rt)
	);
	
	PCSrcMux PCSrcMux(
		.Cmp(Cmp),
		.RsToPC(RsToPC),
		.J_imm26(J_imm26),
		.Adder(Adder_Out),
		.NAdder(NAdder_Out),
		.Shifter(Shifter_Out),
		.RData1(GRF_RData1),
		.PCSrc_RsToPC(PCSrc_RsToPC),
		.ID_EX_PC(ID_EX_PC),
		.EX_MEM_ALUResult(EX_MEM_ALUResult),
		.MEM_WB_regWriteMux(regWriteMux_Out),
		.Out(PCSrcMux_Out)
	);
	
	ID_EX ID_EX(
		.RData1(GRF_RData1),
		.RData2(GRF_RData2),
		.PC(IF_ID_PC),
		.imm32(EXT_Out),
		.clk(clk),
		.reset(reset),
		.clear(ID_EXClear),
		.enable(ID_EXEnable),
		.Instr(IF_ID_Instr),
		.WAddr(IF_ID_WAddr),
		.Out_WAddr(ID_EX_WAddr),
		.Out_Instr(ID_EX_Instr),
		.Out_RData1(ID_EX_RData1),
		.Out_RData2(ID_EX_RData2),
		.Out_PC(ID_EX_PC),
		.Out_imm32(ID_EX_imm32)
	);
	
	
	//==============EX段=========================================
	ALU ALU(
		.RData1(ALUSrcMux_Out1),
		.RData2(ALUSrcMux_Out2),
		.ALUOp(ALUOp),
		.CalcuSigned(CalcuSigned),
		.Overflow(ALU_Overflow),
		.Out(ALU_Out)
	);
	ALUSrcMux ALUSrcMux(
		.RData1(ID_EX_RData1),
		.RData2(ID_EX_RData2),
		.imm32(ID_EX_imm32),
		.ALUSrc1(ALUSrc1),
		.ALUSrc2(ALUSrc2),
		.ALUSrc_RData1(ALUSrc_RData1),
		.ALUSrc_RData2(ALUSrc_RData2),
		.EX_MEM_ALUResult(EX_MEM_ALUResult),
		.MEM_WB_regWriteMux(regWriteMux_Out),
		.Out1(ALUSrcMux_Out1),
		.Out2(ALUSrcMux_Out2)
	);
	CMP_LessThan CMP_LessThan(
		.RData1(ALUSrcMux_Out1),
		.RData2(ALUSrcMux_Out2),
		.CalcuSigned(CalcuSigned),
		.Out(CMP_LessThan_Out)
	);
	MD MD(
		.RData1(ALUSrcMux_Out1),
		.RData2(ALUSrcMux_Out2),
		.MDOp(MDOp),
		.MDWrite(MDWrite),
		.CalcuSigned(CalcuSigned),
		.clk(clk),
		.reset(reset),
		.Busy(Busy),
		.HI(MD_HI),
		.LO(MD_LO)
	);
	DMSrcMux DMSrcMux(
		.ID_EX_RData2(ID_EX_RData2),
		.EX_MEM_ALUResult(EX_MEM_ALUResult),
		.MEM_WB_regWriteMux(regWriteMux_Out),
		.DMSrc(DMSrc),
		.Out(DMSrcMux_Out)
	);
	EX_ALUResultSrcMux EX_ALUResultSrcMux(
		.ALUResult(ALU_Out),
		.LT(CMP_LessThan_Out),
		.ID_EX_PC(ID_EX_PC),
		.HI(MD_HI),
		.LO(MD_LO),
		.EX_ALUResultSrc(EX_ALUResultSrc),
		.Out(EX_ALUResultSrcMux_Out)
	);
	EX_MEM EX_MEM(
		.ALUResult(EX_ALUResultSrcMux_Out),
		.RData2(DMSrcMux_Out),
		.PC(ID_EX_PC),
		.clk(clk),
		.reset(reset),
		.clear(EX_MEMClear),
		.Instr(ID_EX_Instr),
		.Overflow(ALU_Overflow),
		.WAddr(ID_EX_WAddr),
		.Out_Overflow(EX_MEM_Overflow),
		.Out_WAddr(EX_MEM_WAddr),
		.Out_Instr(EX_MEM_Instr),
		.Out_ALUResult(EX_MEM_ALUResult),
		.Out_RData2(EX_MEM_RData2),
		.Out_PC(EX_MEM_PC)
	);
//==============MEM段=========================================

	DM DM(
		.PC(EX_MEM_PC),
		.Addr(EX_MEM_ALUResult[15:2]),
		.Data(EX_MEM_RData2),
		.clk(clk),
		.reset(reset),
		.MemWrite(MemWrite),
		.Out(DM_Out)
	);
	MemEXT MemEXT(
		.Data(DM_Out),
		.LoadSigned(LoadSigned),
		.MemRead(MemRead),
		.Out(MemEXT_Out)
	);
	
	MEM_WB MEM_WB(
		.Data(MemEXT_Out),
		.ALUResult(EX_MEM_ALUResult),
		.PC(EX_MEM_PC),
		.clk(clk),
		.reset(reset),
		.Instr(EX_MEM_Instr),
		.Overflow(EX_MEM_Overflow),
		.WAddr(EX_MEM_WAddr),
		.Out_WAddr(MEM_WB_WAddr),
		.Out_Overflow(MEM_WB_Overflow),
		.Out_Instr(MEM_WB_Instr),
		.Out_Data(MEM_WB_Data),
		.Out_ALUResult(MEM_WB_ALUResult),
		.Out_PC(MEM_WB_PC)
	);
	regWriteMux regWriteMux(
		.PC(MEM_WB_PC),
		.ALUResult(MEM_WB_ALUResult),
		.Data(MEM_WB_Data),
		.PCToReg(PCToReg),
		.MemToReg(MemToReg),
		.Out(regWriteMux_Out)
	);
//==============WB段和ID段合二为一了=========================================
//==============Controller段=========================================
	
	InstallController InstallController(
		.IF_IDInstall(IF_IDInstall),
		.ID_EXInstall(ID_EXInstall),
		.PCEnable(PCEnable),
		.IF_IDEnable(IF_IDEnable),
		.ID_EXEnable(ID_EXEnable),
		.ID_EXClear(ID_EXClear),
		.EX_MEMClear(EX_MEMClear)
	);
	IF_IDController IF_IDController(
		.IF_ID_Instr(IF_ID_Instr),
		.ID_EX_WAddr(ID_EX_WAddr),
		.EX_MEM_WAddr(EX_MEM_WAddr),
		.MEM_WB_WAddr(MEM_WB_WAddr),
		.ID_EX_Tnew(ID_EX_Tnew),
		.EX_MEM_Tnew(EX_MEM_Tnew),
		.MEM_WB_Tnew(MEM_WB_Tnew),
		
		.Lui(Lui),
		.SLeftEXT_imm16(SLeftEXT_imm16),
		.LeftEXT_imm5(LeftEXT_imm5),
		.Branch(Branch),
		.RsToPC(RsToPC),
		.J_imm26(J_imm26),
		
		.CMPSrc_rs(CMPSrc_rs),
		.CMPSrc_rt(CMPSrc_rt),
		.PCSrc_RsToPC(PCSrc_RsToPC),
		
		.Install(IF_IDInstall),
		.WAddr(IF_ID_WAddr)
	);
	
	ID_EXController ID_EXController(
		.ID_EX_Instr(ID_EX_Instr),
		.EX_MEM_WAddr(EX_MEM_WAddr),
		.MEM_WB_WAddr(MEM_WB_WAddr),
		
		.Busy(Busy),

		.ALUOp(ALUOp),
		.ALUSrc1(ALUSrc1),
		.ALUSrc2(ALUSrc2),
		.CalcuSigned(CalcuSigned),
		.MDOp(MDOp),
		.MDWrite(MDWrite),
		.EX_ALUResultSrc(EX_ALUResultSrc),
		.ALUSrc_RData1(ALUSrc_RData1),
		.ALUSrc_RData2(ALUSrc_RData2),
		.DMSrc(DMSrc),
		.Tnew(ID_EX_Tnew),
		.Install(ID_EXInstall)
	);
	
	EX_MEMController EX_MEMController(
		.EX_MEM_Instr(EX_MEM_Instr),
		.MEM_WB_Instr(MEM_WB_Instr),
		.MEM_WB_WAddr(MEM_WB_WAddr),
		.ALULast(EX_MEM_ALUResult[1:0]),
		
		.MemWrite(MemWrite),
		.MemRead(MemRead),
		.LoadSigned(LoadSigned),
		
		.Tnew(EX_MEM_Tnew)
	);
	
	MEM_WBController MEM_WBController(
		.MEM_WB_Instr(MEM_WB_Instr),
		.Overflow(MEM_WB_Overflow),
		.PCToReg(PCToReg),
		.MemToReg(MemToReg),
		.RegWrite(RegWrite),
		.Tnew(MEM_WB_Tnew)
	);
	
	
endmodule