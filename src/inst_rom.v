`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 23:43:45
// Design Name: 
// Module Name: inst_rom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module inst_rom(
    input wire ce,
    input wire[31:0] addr,
    
    output reg[31:0] inst
    );
    
reg[31:0] inst_rom[0:31];
//initial $readmemh("inst_rom.data", inst_rom);
//initial $readmemh("inst_rom_v0.2_01.data", inst_rom);
//initial $readmemh("inst_rom_v0.2_02.data", inst_rom);
//initial $readmemh("inst_rom_v0.2_03.data", inst_rom);
//initial $readmemh("inst_rom_v0.2_04.data", inst_rom);
initial $readmemh("inst_rom_v0.3_01.data", inst_rom);

always @(*)
begin
    if (ce == 1'b0)
        begin
            inst <= 32'h0;
        end
    else
        begin
            inst <= inst_rom[addr[10:2]];
        end
end
endmodule
