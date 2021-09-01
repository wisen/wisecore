`timescale 1ns/1ps

module wisecore_soc_tb();

//reg     CLOCK_50;
reg CLOCK_1;
reg     rst;
  
       
initial begin
    //CLOCK_50 = 1'b0;
    //forever #10 CLOCK_50 = ~CLOCK_50;
    CLOCK_1 = 1'b0;
    forever #1 CLOCK_1 = ~CLOCK_1;
end

initial begin
    rst = 1'b1;
    //#195 rst = 1'b0;
    //#1000 $stop;
    #10 rst = 1'b0;
    #50 $stop;
end

wisecore_soc wisecore_soc_inst0(
    //.clk(CLOCK_50),
    .clk(CLOCK_1),
    .rst(rst)
);

endmodule