`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:56:02 11/25/2020 
// Design Name: 
// Module Name:    PC 
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
module PC(
    input wire [31:0] Addr,
	input wire clk,
	input wire reset,
	input wire enable,
	output reg [31:0] Out
    );
	initial begin
		Out <= 32'h00003000;
	end
	always @(posedge clk) begin
		if(reset) begin
			Out <= 32'h00003000;
		end
		else if(enable) begin
			Out <= Addr;
			//Out <= {{16{1'b0}}, Addr[15:0]};
		end
		else begin
			Out <= Out;
		end
	end	
endmodule
