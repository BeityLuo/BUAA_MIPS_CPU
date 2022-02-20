`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:11:59 12/28/2020 
// Design Name: 
// Module Name:    CMP_LessThan 
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
module CMP_LessThan(
	input wire [31:0] RData1,
	input wire [31:0] RData2,
	input wire CalcuSigned,
	output wire [31:0] Out
    );
	
	assign Out  = CalcuSigned ? $signed(RData1) < $signed(RData2) :
							   RData1 < RData2;
	
endmodule
