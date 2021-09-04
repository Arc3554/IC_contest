`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output  reg [13:0] 	gray_addr;
output  reg gray_req;
input   	gray_ready;
input   [7:0] 	gray_data;
output  reg [13:0] 	lbp_addr;
output  reg	lbp_valid;
output  reg [7:0] 	lbp_data;
output  reg finish;

reg [3:0]  step;
reg [13:0] position;//y ,x
reg [7:0] center;
//====================================================================
always @(posedge clk or posedge reset) begin
	if (reset) begin
		lbp_valid <= 0;
		gray_addr <= 0;
		lbp_addr <= 0;
		finish <= 0;
		lbp_data <= 0;
		
		step <= 0;
		position <= 129;
		//center <= 0;
	end
	else begin
		gray_req <= 1;
		case (step)
			4'b0000: begin
				if ((&position[6:0])||(|position[6:0])==0) begin 
					if (position == 16255) finish <= 1;
					else position <= position + 1;
				end
				else begin
					gray_addr <= position;
					step <= step + 1;
				end
			end
			4'b0001: begin
				step <= step + 1;
				center <= gray_data;
				gray_addr <= position - 129;
			end
			4'b0010:begin
				step <= step + 1;
				if (gray_data>= center) lbp_data [0] <= 1;
				gray_addr <= position - 128;
			end
			4'b0011:begin
				step <= step + 1;
				if (gray_data>= center) lbp_data [1] <= 1;
				gray_addr <= position - 127;
			end
			4'b0100:begin
				step <= step + 1;
				if (gray_data>= center) lbp_data [2] <= 1;
				gray_addr <= position - 1;
			end
			4'b0101:begin
				step <= step + 1;
				if (gray_data>= center) lbp_data [3] <= 1;
				gray_addr <= position + 1;
			end
			4'b0110:begin
				step <= step + 1;
				if (gray_data>= center) lbp_data [4] <= 1;
				gray_addr <= position + 127;
			end
			4'b0111:begin
				step <= step + 1;
				if (gray_data>= center) lbp_data [5] <= 1;
				gray_addr <= position + 128;
			end
			4'b1000:begin
				step <= step + 1;
				if (gray_data>= center) lbp_data [6] <= 1;
				gray_addr <= position + 129;
			end
			4'b1001:begin
				step <= step + 1;
				if (gray_data>= center) lbp_data [7] <= 1;
				lbp_valid <= 1;
				lbp_addr <= position ;
			end
			4'b1010: begin
				position <= position + 1;
				lbp_valid <= 0;
				step <= 0;
				lbp_data <= 0;
			end
		endcase
	end
end
endmodule
