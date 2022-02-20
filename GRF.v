`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:11:40 11/27/2020 
// Design Name: 
// Module Name:    GRF 
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
module GRF(
	input wire [31:0] PC,
	input wire [4:0] R1,
	input wire [4:0] R2,
	input wire [4:0] WReg,
	input wire [31:0] Data,
	input wire clk,
	input wire reset,
	input wire RegWrite,
	output reg [31:0] RData1,
	output reg [31:0] RData2
    );
	reg [31:0] regMatrix[0:31];
	integer i;
	
	initial begin
		for(i = 0; i < 32; i = i + 1) begin
				regMatrix[i] <= 32'h00000000;
		end
	end

	always @(posedge clk) begin
		if(reset == 1) begin
			for(i = 0; i < 32; i = i + 1) begin
				regMatrix[i] <= 32'h00000000;
			end
		end
		else if(RegWrite == 1) begin
			$display("%d@%h: $%d <= %h", $time, PC, WReg, Data);
			if(WReg != 0)
				regMatrix[WReg] <= Data;
		end
		else begin
		end
	end
	
	always @(*) begin
//���������൱����ת�����൱��EX/WB�Ĵ�����ID�׶�ת��
//Ȼ��ʵ����ID�׶β��ᡰʹ�á��Ĵ�����ֵ������ϸ���ͳһ��������Ӧ�ý�GRF����
//WB�Ĵ�����Ȼ������WB�Ĵ�����EX��MEM��ת������GRF�����������Ͳ��ҽ�DM������ѡ����ǰ��EX�׶Σ�
//���Ա�������������ת��ͨ·
		if(R1 == WReg & R1 != 0)
			RData1 = Data;
		else
			RData1 = regMatrix[R1];
		if(R2 == WReg & R2 != 0)
			RData2 = Data;
		else
			RData2 = regMatrix[R2];
	end

endmodule
