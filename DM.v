`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:59:22 11/24/2020 
// Design Name: 
// Module Name:    DM 
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
module DM(
	input wire [31:0] PC,
    input wire [15:2] Addr,
    input wire [31:0] Data,
    input wire reset,
	input wire clk,
    input wire [3:0] MemWrite,
    output reg [31:0] Out
    );
	reg [31:0] regMatrix [0:32'h2fff];
	integer i;
	
	initial begin
		for(i = 0; i < 1024; i = i + 1)
			regMatrix[i] <= 32'h00000000;
	end
	
	always @(posedge clk) begin
		if(reset) begin
			for(i = 0; i < 1024; i = i + 1)
				regMatrix[i] <= 32'h00000000;
		end
		else begin
			if(MemWrite == 4'b0001) begin
				regMatrix[Addr][7:0] <= Data[7:0];
				$display("%d@%h: *%h <= %h", $time, PC, {{16{1'b0}}, Addr[15:2], {2{1'b0}}}, {regMatrix[Addr][31:8], Data[7:0]});
			end
			else if(MemWrite == 4'b0010) begin
				regMatrix[Addr][15:8] <= Data[7:0];
				$display("%d@%h: *%h <= %h", $time, PC, {{16{1'b0}}, Addr[15:2], {2{1'b0}}}, {regMatrix[Addr][31:16], Data[7:0], regMatrix[Addr][7:0]});
			end
			else if(MemWrite == 4'b0100) begin
				regMatrix[Addr][23:16] <= Data[7:0];
				$display("%d@%h: *%h <= %h", $time, PC, {{16{1'b0}}, Addr[15:2], {2{1'b0}}}, {regMatrix[Addr][31:24], Data[7:0], regMatrix[Addr][15:0]});
			end
			else if(MemWrite == 4'b1000) begin
				regMatrix[Addr][31:24] <= Data[7:0];
				$display("%d@%h: *%h <= %h", $time, PC, {{16{1'b0}}, Addr[15:2], {2{1'b0}}}, {Data[7:0], regMatrix[Addr][23:0]});
			end
			else if(MemWrite == 4'b0011) begin
				regMatrix[Addr][15:0] <= Data[15:0];
				$display("%d@%h: *%h <= %h", $time, PC, {{16{1'b0}}, Addr[15:2], {2{1'b0}}}, {regMatrix[Addr][31:16], Data[15:0]});
			end
			else if(MemWrite == 4'b1100) begin
				regMatrix[Addr][31:16] <= Data[15:0];
				$display("%d@%h: *%h <= %h", $time, PC, {{16{1'b0}}, Addr[15:2], {2{1'b0}}}, {Data[15:0], regMatrix[Addr][31:16]});
			end
			else if(MemWrite == 4'b1111) begin
				regMatrix[Addr] <= Data;
				$display("%d@%h: *%h <= %h", $time, PC, {{16{1'b0}}, Addr[15:2], {2{1'b0}}}, Data);
			end
			else begin
			end
		end
	end
	always @(*) begin
		Out <= regMatrix[Addr];
	end
	
endmodule
