`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:30:22 12/15/2020 
// Design Name: 
// Module Name:    ID_EXController 
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

module InstallController(
    input wire IF_IDInstall,
    input wire ID_EXInstall,
    output reg PCEnable,
    output reg IF_IDEnable,
    output reg ID_EXEnable,
    output reg ID_EXClear,
    output reg EX_MEMClear
);
    always @(*) begin
        if(IF_IDInstall) begin
            PCEnable = 0;
            IF_IDEnable = 0;
            ID_EXClear = 1;
        end
        else if(ID_EXInstall) begin
            PCEnable = 0;
            IF_IDEnable = 0;
            ID_EXEnable = 0;
            EX_MEMClear = 1;
        end
        else begin
            PCEnable = 1;
            IF_IDEnable = 1;
            ID_EXEnable = 1;
            ID_EXClear = 0;
            EX_MEMClear = 0;
        end
    
    end

endmodule