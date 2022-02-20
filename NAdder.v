`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:37:49 11/27/2020 
// Design Name: 
// Module Name:    NAdder 
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
module NAdder(
	input wire [31:0] Shifter,
	input wire [31:0] PC,
	output wire [31:0] Out
    );
	assign Out = Shifter + PC + 4;
endmodule
