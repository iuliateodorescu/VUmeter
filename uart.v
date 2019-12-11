`timescale 1ns/ 1ns

`define idle 3'b000
`define transmission_start 3'b001
`define reading 3'b010
`define transmission_stop 3'b011
`define error 3'b100

module uart(
    clk, rst, rx, format_err, data_out, valid );
	
input clk, rst, rx;
output valid, format_err;
output[7:0] data_out;

reg valid_reg, valid_next;
reg format_err_reg, format_err_next;
reg[2:0] counter_reg, counter_next;
reg[7:0] data_out_reg, data_out_next;
reg[2:0] state_reg, state_next;

wire[3:0] COUNT_HIGH, COUNT_LOW, COUNT_16;
reg rst_cntr_reg, rst_cntr_next;
reg rst_chl_reg, rst_chl_next;

counter #( .w(4) ) COUNTER( .clk(clk), .rst(rst_cntr_reg), .count(COUNT_16) );
counter_high_low #( .bit_value(1'b1), .w(4) ) COUNTER_HIGH( .clk(clk), .rst(rst_chl_reg), .rx(rx), .count(COUNT_HIGH) );
counter_high_low #( .bit_value(1'b0), .w(4) ) COUNTER_LOW( .clk(clk), .rst(rst_chl_reg), .rx(rx), .count(COUNT_LOW) );

//bloc always combinational pentru construirea starii urmatoare
always @(*) begin
    state_next = state_reg;
	format_err_next = format_err_reg;
	valid_next = valid_reg;
	data_out_next = data_out_reg;
	counter_next = counter_reg;
	rst_cntr_next = rst_cntr_reg;
	rst_chl_next = rst_chl_reg;
	
	case( state_reg )
	`idle : begin
	    valid_next = 1'b0;
        counter_next = 3'b0;
        data_out_next = 8'b0;
		rst_cntr_next = 1'b0;
		rst_chl_next = 1'b0;
        if( !rx ) begin
	        state_next = `transmission_start;
			rst_cntr_next = 1'b1;
			rst_chl_next = 1'b1;
        end			
	    end
		
	`transmission_start: begin
	        if( COUNT_16 == 4'b1111 && COUNT_LOW > COUNT_HIGH) begin
			    rst_cntr_next = 1'b0;
			    rst_chl_next = 1'b0;
			    state_next = `reading;
			end
	        end
				
	`reading: begin
	      rst_chl_next = 1'b1;
		  rst_cntr_next = 1'b1;
	      if( COUNT_16 == 4'b1110 ) begin
	          data_out_next[6:0] = data_out_reg[7:1];
		      if( COUNT_HIGH > COUNT_LOW ) begin
			      data_out_next[7] = 1'b1;
			  end
			  else begin
			      data_out_next[7] = 1'b0;
			  end
			  rst_chl_next = 1'b0;
			  rst_cntr_next = 1'b0;
		      if( counter_reg < 3'b111 ) begin
		          counter_next = counter_reg + 1'b1;
		      end
		      else begin
		          state_next = `transmission_stop;
		      end
		  end
	    end
    
    `transmission_stop: begin
			rst_cntr_next = 1'b1;
			rst_chl_next = 1'b1;
			if( COUNT_16==4'b1110 ) begin
			    if( COUNT_HIGH > COUNT_LOW ) begin
				    valid_next = 1'b1;
                    format_err_next = 1'b0;
					state_next = `idle;
				end
				else begin
				    valid_next = 1'b0;
			        format_err_next = 1'b1;
					state_next = `error;
				end
				rst_cntr_next = 1'b0;
				rst_chl_next = 1'b0;
			end
			
            end

    `error: begin
	    if( rx ) begin
		    format_err_next = 1'b0;
		    state_next = `idle;
	    end
        end
		
    default: begin
	    end
    endcase
end

//bloc always secvential pentru actualizarea starii curente
always @(posedge clk, negedge rst) begin
    if( !rst ) begin
	    state_reg <= 3'b0;
	    format_err_reg <= 1'b0;
	    valid_reg <= 1'b0;
	    data_out_reg <= 8'b0;
	    counter_reg <= 3'b0;
	    rst_cntr_reg <= 1'b0;
		rst_chl_reg <= 1'b0;
    end
    else begin
	    state_reg <= state_next;
	    format_err_reg <= format_err_next;
	    valid_reg <= valid_next;
	    data_out_reg <= data_out_next;
	    counter_reg <= counter_next;
	    rst_cntr_reg <= rst_cntr_next;
		rst_chl_reg <= rst_chl_next;
    end
end

assign format_err = format_err_reg;
assign valid = valid_reg;
assign data_out = data_out_reg;

endmodule