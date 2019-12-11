`timescale 1ns/1ns

//`define clock_cycle_time 3'b101

module clock_generator_TB;
parameter delay = 5;

reg clk_in_TB, rst_TB;
wire clk_out;

clock_generator #( .freq_in(100), .freq_out(20), .w(3) ) GEN( .clk_in(clk_in_TB), .rst(rst_TB), .clk_out(clk_out) );

initial begin
    forever
	#delay clk_in_TB = !clk_in_TB;
end

initial begin
    clk_in_TB = 1'b0;
	rst_TB = 1'b0;
	#2 rst_TB = 1'b1;
end

endmodule