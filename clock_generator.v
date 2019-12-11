`timescale 1ns/1ns

module clock_generator #(
    parameter freq_in = 100000000,
	parameter freq_out = 9600,
    parameter max_v = freq_in/freq_out,
	parameter bit_no = 16,
    parameter initial_v = {bit_no{1'b0}})(
	clk_in, rst, clk_out);
	
input clk_in, rst;
output clk_out;

reg clk_out_reg, clk_out_next;
reg[bit_no-1:0] count_reg, count_next;

//bloc combinational
always @(*) begin
    count_next = count_reg;
	clk_out_next = clk_out_reg;
	
	if( count_reg < max_v-1 ) begin
		count_next = count_reg + 1'b1;
		if( count_reg == (max_v/2 - 1) ) begin
		    clk_out_next = !clk_out_reg;
		end
	end
	else begin
	    clk_out_next = !clk_out_reg;
		count_next = 1'b0;
	end
end

//bloc secvential
always @(posedge clk_in, negedge rst) begin
    if( !rst ) begin
      count_reg <= initial_v;
	  clk_out_reg <= 1'b0;
	end
    else begin
      count_reg <= count_next;
	  clk_out_reg <= clk_out_next;
	end
end

assign clk_out = clk_out_reg;

endmodule