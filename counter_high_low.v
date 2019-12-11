`timescale 1ns/1ns

module counter_high_low #(
    parameter bit_value = 1'b0,
    parameter w = 4,
    parameter initial_v = {w{1'b0}})(
    clk, rst, rx, count);

input clk, rst, rx;
output[w-1:0] count;

reg[w-1:0] count_reg, count_next;

//bloc combinational
always @(*) begin
    count_next = count_reg;
	
	    if( rx==bit_value ) begin
	        count_next = count_reg + 1'b1;
	    end
end

//bloc secvential
always @(posedge clk, negedge rst) begin
    if( !rst ) begin
	    count_reg <= initial_v;
	end
	else begin
	    count_reg <= count_next;
	end
end

assign count = count_reg;

endmodule	