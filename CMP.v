`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:00:01 12/15/2020 
// Design Name: 
// Module Name:    CMP 
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
module CMP(
	input wire [31:0] RData1,
	input wire [31:0] RData2,
	input wire [3:0] Branch,
	output wire Cmp
    );
	assign Cmp = Branch == 4'h1 & RData1 == RData2 |
				 Branch == 4'h2 & RData1 != RData2 |
				 Branch == 4'h3 & $signed(RData1) < 0 |
				 Branch == 4'h4 & $signed(RData1) <= 0 |
				 Branch == 4'h5 & $signed(RData1) > 0 |
				 Branch == 4'h6 & $signed(RData1) >= 0;
endmodule
