`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:54:09 11/24/2020 
// Design Name: 
// Module Name:    IM 
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
module IM(
    input wire [13:2] Addr,
	output reg [31:0] Out
    );
	
	reg [31:0] regMatrix [0:4095];
	
	initial begin
		$readmemh("code.txt", regMatrix);
	end
	// PAY ATTENTION HERE!!!!!!
	always @(*) begin
		Out = regMatrix[Addr - 12'hc00];
		//$display("IM_Out = %h\n", Out);
	end

	

endmodule
