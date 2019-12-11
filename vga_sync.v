`timescale 1ns/1ns

`define BLACK 8'h0
`define WHITE 8'hFF
`define RED 8'h7
`define YELLOW 8'h3F
`define GREEN 8'h38

module vga_sync(
    clk, rst, data_in, data_out, h_sync, v_sync);

parameter pack_no = 16;
parameter w = pack_no*8;
parameter initial_v = {10{1'b0}};
parameter factor = 2;

//porturi intrare si iesire	
input clk;
input rst;                   //activ pe 0
input[w-1:0] data_in;
output[7:0] data_out;        //data_out[7:6] blue, data_out[5:3] green, data_out[2:0] red;
output h_sync, v_sync;       //active pe 0

//semnale de tip registru
reg[7:0] data_out_reg, data_out_next;
reg h_sync_reg, h_sync_next;
reg v_sync_reg, v_sync_next;
reg[9:0] h_cnt_reg, h_cnt_next;
reg[9:0] v_cnt_reg, v_cnt_next;
reg[9:0] x;
reg[9:0] y;
reg[7:0] data_aux;

//parametri
//orizontal -> pixeli
parameter H_DISPLAY = 640;
parameter H_RETRACE = 96;
parameter H_FP = 16;
parameter H_BP = 48;
parameter H_WIDTH = H_FP + H_RETRACE + H_BP + H_DISPLAY;
parameter H_RETRACE_END = H_FP + H_RETRACE;
parameter H_DISPLAY_BEGIN = H_FP + H_RETRACE + H_BP;

//vertical -> linii
parameter V_DISPLAY = 480;
parameter V_RETRACE = 2;
parameter V_FP = 10;
parameter V_BP = 33;
parameter V_HEIGHT = V_DISPLAY + V_FP + V_RETRACE + V_BP;
parameter V_RETRACE_BEGIN = V_DISPLAY + V_FP;
parameter V_RETRACE_END = V_DISPLAY + V_FP + V_RETRACE;

integer i;

//bloc combinational
always @(*) begin
    h_cnt_next = h_cnt_reg;
	v_cnt_next = v_cnt_reg;
	h_sync_next = h_sync_reg;
	v_sync_next = v_sync_reg;
	data_out_next = data_out_reg;
	
	data_aux = data_in[w-1:w-8];
	
	//numaram pixelii de pe linie si liniile de pe ecran
    if (h_cnt_reg == (H_WIDTH - 1)) begin      //am ajuns la finalul liniei, incepem sa nr pixelii de la 0
		h_cnt_next = initial_v;
		if (v_cnt_reg == (V_HEIGHT - 1)) begin //am parcurs toate liniile
			v_cnt_next = initial_v;
		end
		else begin                             //final de linie, mai sunt linii de parcurs
			v_cnt_next = v_cnt_reg + 1'b1;
		end
	end
	else begin                                 //in interiorul unei linii
		h_cnt_next = h_cnt_reg + 1'b1;
	end
	
	//vedem in ce zona ne gasim
	if( v_cnt_reg >= V_RETRACE_BEGIN && v_cnt_reg<V_RETRACE_END ) begin       //zona verticala de sync
	    data_out_next = `BLACK;
		v_sync_next = 1'b0;
		if( h_cnt_reg >= H_FP && h_cnt_reg < H_RETRACE_END ) begin            //zona orizontala de sync
            h_sync_next = 1'b0;
        end		
		else begin
		    h_sync_next = 1'b1;
		end
	end
	else begin
	    if( ( v_cnt_reg >= V_DISPLAY && v_cnt_reg < V_RETRACE_BEGIN ) || ( v_cnt_reg >= V_RETRACE_END && v_cnt_reg < V_HEIGHT ) ) begin        //zona verticala de FP si BP
		    data_out_next = `BLACK;
			v_sync_next = 1'b1;
			if( h_cnt_reg >= H_FP && h_cnt_reg < H_RETRACE_END ) begin                                                                         //zona orizontala de sync
			    h_sync_next = 1'b0;
			end
			else begin
			    h_sync_next = 1'b1;
			end
		end
		else begin                                                         //zona verticala de display
		    v_sync_next = 1'b1;
		    if( h_cnt_reg >= H_FP && h_cnt_reg<H_RETRACE_END ) begin       //zona orizontala de sync
			    data_out_next = `BLACK;
				h_sync_next = 1'b0;
			end
			else begin
			    h_sync_next = 1'b1;
				if( ( h_cnt_reg >= 0 && h_cnt_reg<H_FP ) || ( h_cnt_reg >= H_RETRACE_END && h_cnt_reg<H_DISPLAY_BEGIN ) ) begin    //zona orizontala de FP si BP
				    data_out_next = `BLACK;
				end
				else begin                                                 //zona orizontala de display
				    //coordonatele unui pixel in zona de display
					x = h_cnt_reg - H_DISPLAY_BEGIN;
					y = v_cnt_reg;
					
					/*for( i=0; i<pack_no; i=i+1 ) begin
					    if( y >= (V_DISPLAY/pack_no)*i && y < (V_DISPLAY/pack_no)*(i+1) ) begin
						    if( x > 0 && x <= data_aux[7:0]*factor ) begin
							    if( x > 0 && x <300 ) begin
								    data_out_next = `GREEN;
								end
								else begin
								    if( x >= 300 && x < 500 ) begin
									    data_out_next = `YELLOW;
									end
									else begin
									    data_out_next = `RED;
									end
								end
							end
							else begin
							    data_out_next = `BLACK;
							end
							data_aux = data_aux >> 8;
						end
					end*/
					
					
					if( y >= 175 && y < 350 ) begin//175 350
					    if( x >= 65 && x<= (data_aux*factor)+64 ) begin
						    if( x>=65 && x < 400 ) begin
							    data_out_next = `GREEN;
							end
							else begin
							    if( x >= 400 && x < 520 ) begin
								    data_out_next = `YELLOW;
								end
								else begin
								    data_out_next = `RED;
								end
							end
						end
						else begin
						    data_out_next = `BLACK;
						end
					    /*if( x >=0 && x <200 ) begin//0 200
						    data_out_next = `WHITE;
						end
						else begin
						    if( x >= 200 && x < 400 ) begin//200 400
							    data_out_next = `GREEN;
							end
							else begin
							    if( x >= 400 && x < 600 ) begin//400 600
								    data_out_next = `YELLOW;
								end
								else begin
								    data_out_next = `RED;
								end
							end
						end*/
					end
					else begin
					    data_out_next = `BLACK;
					end
				end
			end
		end
	end
end


//bloc secvential
always @(posedge clk, negedge rst) begin
    if( !rst ) begin
	    h_sync_reg <= 1'b1;
		v_sync_reg <= 1'b1;
		h_cnt_reg <= 0;
		v_cnt_reg <= 0;
		data_out_reg <= 8'h0;
	end
	else begin
        h_sync_reg <= h_sync_next;
        v_sync_reg <= v_sync_next;
		h_cnt_reg <= h_cnt_next;
		v_cnt_reg <= v_cnt_next;
		data_out_reg <= data_out_next;
    end		
end

assign data_out = data_out_reg;
assign h_sync = h_sync_reg;
assign v_sync = v_sync_reg;

endmodule