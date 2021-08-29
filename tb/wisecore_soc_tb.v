`timescale 1ns/1ps

module wisecore_soc_tb();

reg     CLOCK_50;
reg     rst;
  
       
initial begin
    CLOCK_50 = 1'b0;
    forever #10 CLOCK_50 = ~CLOCK_50;
end

initial begin
    rst = 1'b1;
    #195 rst = 1'b0;
    #1000 $stop;
end

wisecore_soc wisecore_soc_inst0(
    .clk(CLOCK_50),
    .rst(rst)
);

endmodule