`timescale 1ns/1ns

`define clock_cycle_time 1'b1 
module vga_sync_TB;

parameter delay = 5*`clock_cycle_time;

reg clk_TB, rst_TB;
reg[127:0] data_in;
wire h_sync, v_sync;
wire[7:0] data_out;

vga_sync VGA( .clk(clk_TB), .rst(rst_TB), .data_in(data_in), .data_out(data_out), .h_sync(h_sync), .v_sync(v_sync) );

initial begin
    forever
    #(`clock_cycle_time) clk_TB = !clk_TB;
end

initial begin
    clk_TB = 1'b0;
	rst_TB = 1'b0;
	#(delay) rst_TB= 1'b1;
	
	//#(2*delay) data_in = 8'hAA;
	//#(2*delay) data_in = 8'h55;
	//#(2*delay) data_in = 8'hAA;
end

endmodule