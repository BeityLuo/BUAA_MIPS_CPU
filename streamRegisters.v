`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:56:26 12/15/2020 
// Design Name: 
// Module Name:    streamRegisters 
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
module streamRegisters(
    );
endmodule

module IF_ID(
	input wire [31:0] PC,
	input wire [31:0] Instr,
	input wire clk,
	input wire reset,
	input wire enable,
	output reg [31:0] Out_PC,
	output reg [31:0] Out_Instr
);
	initial begin
		Out_PC = 32'h00000000;
		Out_Instr = 32'h00000000;
	end
	
	
	always @(posedge clk) begin
		if(reset) begin
			Out_PC <= 32'h00003000;
			Out_Instr <= 32'h00000000;
		end
		
		else if(enable) begin
			Out_PC <= PC;
			Out_Instr <= Instr;
		end
		else begin
			Out_PC <= Out_PC;
			Out_Instr <= Out_Instr;
		end
	end

endmodule

module ID_EX(
	input wire [31:0] RData1,
	input wire [31:0] RData2,
	input wire [31:0] PC,
	input wire [31:0] imm32,
	input wire clk,
	input wire reset,
	input wire enable,
	input wire clear,
	input wire [31:0] Instr,
	input wire [4:0] WAddr,
	output reg [4:0] Out_WAddr,
	output reg [31:0] Out_Instr,
	output reg [31:0] Out_RData1,
	output reg [31:0] Out_RData2,
	output reg [31:0] Out_PC,
	output reg [31:0] Out_imm32
);
	initial begin
		Out_Instr = 32'h00000000;
		Out_RData1 = 0;
		Out_RData2 = 0;
		Out_PC = 0;
		Out_imm32 = 0;
		Out_WAddr = 0;
	end
	always @(posedge clk) begin
		if(reset | clear) begin
			Out_RData1 <= 0;
			Out_RData2 <= 0;
			Out_imm32 <= 0;
			Out_PC <= 32'h00003000;
			Out_Instr <= 0;
			Out_WAddr <= 0;
		end
		else if(enable) begin
			Out_RData1 <= RData1;
			Out_RData2 <= RData2;
			Out_imm32 <= imm32;
			Out_PC <= PC;
			Out_Instr <= Instr;
			Out_WAddr <= WAddr;
		end
		else begin
		end
	end



endmodule

module EX_MEM(
	input wire [31:0] ALUResult,
	input wire [31:0] RData2,
	input wire [31:0] PC,
	input wire clk,
	input wire reset,
	input wire clear,
	input wire [31:0] Instr,
	input wire Overflow,
	input wire [4:0] WAddr,
	output reg [4:0] Out_WAddr,
	output reg Out_Overflow,
	output reg [31:0] Out_Instr,
	output reg [31:0] Out_ALUResult,
	output reg [31:0] Out_RData2,
	output reg [31:0] Out_PC
);
	initial begin
		Out_ALUResult = 0;
		Out_RData2 = 0;
		Out_PC = 32'h00003000;
		Out_Instr = 0;
		Out_Overflow = 0;
		Out_WAddr = 0;
	end
	always @(posedge clk) begin
		if(reset | clear) begin
			Out_ALUResult <= 0;
			Out_RData2 <= 0;
			Out_PC <= 32'h00003000;
			Out_Instr <= 0;
			Out_Overflow <= 0;
			Out_WAddr <= 0;
		end
		else begin
			Out_ALUResult <= ALUResult;
			Out_RData2 <= RData2;
			Out_PC <= PC;
			Out_Instr <= Instr;
			Out_Overflow <= Overflow;
			Out_WAddr <= WAddr;
		end
	end

endmodule

module MEM_WB(
	input wire [31:0] Data,
	input wire [31:0] ALUResult,
	input wire [31:0] PC,
	input wire clk,
	input wire reset,
	input wire [31:0] Instr,
	input wire Overflow,
	input wire [4:0] WAddr,
	output reg [4:0] Out_WAddr,
	output reg Out_Overflow,
	output reg [31:0] Out_Instr,
	output reg [31:0] Out_Data,
	output reg [31:0] Out_ALUResult,
	output reg [31:0] Out_PC
);
	initial begin
		Out_Data = 0;
		Out_ALUResult = 0;
		Out_PC = 32'h00003000;
		Out_Instr = 0;
		Out_Overflow = 0;
		Out_WAddr = 0;
	end
	always @(posedge clk) begin
		if(reset) begin
			Out_Data <= 0;
			Out_ALUResult <= 0;
			Out_PC <= 32'h00003000;
			Out_Instr <= 0;
			Out_Overflow = 0;
			Out_WAddr = 0;
		end
		else begin
			Out_ALUResult <= ALUResult;
			Out_Data <= Data;
			Out_PC <= PC;
			Out_Instr <= Instr;
			Out_Overflow <= Overflow;
			Out_WAddr <= WAddr;
		end
	end

endmodule



