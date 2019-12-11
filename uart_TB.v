`timescale 1ns/1ns

`define clock_cycle_time 1'b1

module uart_TB;
parameter delay = 32*`clock_cycle_time;
parameter baudrate = 16*`clock_cycle_time;

reg clk_TB, rst_TB, rx_TB;
reg clk_bdr;
wire valid, format_err;
wire[7:0] data_out;

uart UART( .clk(clk_TB), .rst(rst_TB), .rx(rx_TB), .valid(valid), .format_err(format_err), .data_out(data_out) );

initial begin
    forever
    #(`clock_cycle_time) clk_TB = !clk_TB;
end

initial begin
    forever
    #baudrate clk_bdr = !clk_bdr;
end

initial begin
    clk_TB = 1'b0;
	clk_bdr = 1'b0;
	rst_TB = 1'b0;
	rx_TB = 1'b1;
	#(2*delay) rst_TB= 1'b1;
	
	#(2*delay) rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;

	#(2*delay) rx_TB = 1'b0;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b1;
	
	#(2*delay) rx_TB = 1'b0;
	
	#(9*delay) rx_TB = 1'b1;
	#(2*delay) rx_TB = 1'b0;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	
	#(4*delay) rx_TB = 1'b1;
	#(2*delay) rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	#delay rx_TB = 1'b0;
	#delay rx_TB = 1'b1;
	
end

endmodule