`timescale 1ns/1ns

module fifo(
    clk, rst, data_in, data_out);

parameter w = 128;
parameter initial_v = {w{1'b0}};

input clk, rst;
input[7:0] data_in;
output[w-1:0] data_out;

reg[w-1:0] data_out_reg, data_out_next;

//bloc always combinational
always @(*) begin
    data_out_next[w-9:0] = data_out_reg[w-1:8];    //shiftez spre dreapta cu 8 biti
	data_out_next[w-1:w-8] = data_in;              //adaug in fifo pachetul de 8 biti de date
end

//bloc always secvential
always @(posedge clk, negedge rst) begin
    if( !rst ) begin
	    data_out_reg <= initial_v;
	end
	else begin
	    data_out_reg <= data_out_next;
	end
end

assign data_out = data_out_reg;

endmodule