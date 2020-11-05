`timescale 1ns/1ns

module top_level_module(
    clk, rst, rx, format_err, h_sync, v_sync, data_out);
	
input clk, rst, rx;
output format_err;
output h_sync, v_sync;
output[7:0] data_out;

wire valid;
wire uart_clk, vga_clk;
wire[7:0] data_uart;
wire[127:0] data_fifo;
//wire[7:0] data_vga;
//reg[7:0] data_out_reg, data_out_next;

parameter bit_no = 16;
parameter reg_no = 16;
parameter freq_in = 100000000;      //100MHz
parameter uart_freq = 153600;       //9600 * 16
parameter vga_freq = 25000000;      //25MHz


clock_generator #( .freq_in(freq_in), .freq_out(uart_freq), .bit_no(bit_no) ) UART_CLK( .clk_in(clk), .rst(rst), .clk_out(uart_clk) );    //generam clk pt uart
clock_generator #( .freq_in(freq_in), .freq_out(vga_freq), .bit_no(bit_no) ) VGA_CLK( .clk_in(clk), .rst(rst), .clk_out(vga_clk) );       //generam clk pt vga

uart UART_TOP( .clk(uart_clk), .rst(rst), .rx(rx), .format_err(format_err), .data_out(data_uart), .valid(valid) );                        //instantiem modulul uart
fifo #( .w(8*reg_no) ) FIFO( .clk(valid), .rst(rst), .data_in(data_uart), .data_out(data_fifo) );                                         //valid = 1(activ) inseamna ca avem un pachet complet de date, il trimitem in fifo
vga_sync VGA_TOP( .clk(vga_clk), .rst(rst), .data_in(data_fifo), .data_out(data_out), .h_sync(h_sync), .v_sync(v_sync) );                 //datele din fifo le trimitem in vga     


/*always @(*) begin
    data_out_next = data_out_reg;
	
	if( valid ) begin
	    data_out_next = data_uart; 
	end
end

always @(posedge uart_clk, negedge rst) begin
    if( !rst ) begin
	    data_out_reg <= 8'b0;
	end
	else begin
	    data_out_reg <= data_out_next;
	end
end

assign data_out = data_out_reg;*/

endmodule