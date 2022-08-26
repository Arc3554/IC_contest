module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output busy;
output reg valid;
output [7:0] candidate;//最大64 6:0

reg [5:0] counter;
wire [3:0] now_x,now_y;

wire [7:0] temp_2;//4*4=8
reg [6:0] left_reg_1,left_reg_2;

reg [3:0] step,next_step;
reg signed [3:0] temp;
reg flag_left,flag_mid;
wire flag;
reg [6:0] candidate_reg;

assign candidate = {1'b0,candidate_reg};
assign now_x = counter[2:0] + 1;
assign now_y = counter[5:3] + 1;
assign busy = 0;

assign temp_2 = temp * temp;
assign flag = (left_reg_1 + left_reg_2 <= temp_2)?1'b1:0;

always@(*)begin
	if(step == 4'b1011) begin
		if (&counter) begin 
			next_step = 0;
		end
		else begin
			next_step = 1;
		end
	end
	else begin
		next_step = step + 1;
	end
	
	if(step == 4'b1011 && &counter) begin
		valid = 1;
	end
	else valid = 0;
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		step <= 0;
		counter <= 0;
	end
	else begin
		step <= next_step;
		case (step)
			4'b0000:begin
				candidate_reg <= 0;
			end
			4'b0001:begin
				temp <= now_x - central[23:20];
			end
			4'b0010:begin
				left_reg_1 <= temp_2;
				temp <= now_y - central[19:16];
			end
			4'b0011:begin
				left_reg_2 <= temp_2;
				temp <= radius[11:8];
			end
			4'b0100:begin
				flag_left <= flag;
				temp <= now_x - central[15:12];
			end
			4'b0101:begin
				left_reg_1 <= temp_2;
				temp <= now_y - central[11:8];
			end
			4'b0110:begin
				left_reg_2 <= temp_2;
				temp <= radius[7:4];
			end
			4'b0111:begin
				flag_mid <= flag;
				temp <= now_x - central[7:4];
			end
			4'b1000:begin
				left_reg_1 <= temp_2;
				temp <= now_y - central[3:0];
			end
			4'b1001:begin
				left_reg_2 <= temp_2;
				temp <= radius[3:0];
			end
			4'b1010:begin
				case(mode)
					2'b00:begin
						if(flag_left) begin
							candidate_reg <= candidate_reg + 1;
						end
					end
					2'b01:begin
						if(flag_left & flag_mid) begin
							candidate_reg <= candidate_reg + 1;
						end
					end
					2'b10:begin
						if(flag_left ^ flag_mid) begin
							candidate_reg <= candidate_reg + 1;
						end
					end
					2'b11:begin
						if((!flag_left & flag_mid & flag)||(flag_left & !flag_mid & flag)||(flag_left & flag_mid & !flag)) begin
							candidate_reg <= candidate_reg + 1;
						end
					end
				endcase
													
			end
			4'b1011:begin
				counter <= counter + 1;
			end
		endcase
	end
end

endmodule

/*module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output reg busy;
output reg valid;
output [7:0] candidate;//最大64 6:0

reg [5:0] counter;
wire [3:0] now_x,now_y;

wire [7:0] temp_2;//4*4=8
reg [6:0] left_reg_1,left_reg_2;

reg [3:0] step;
reg signed [3:0] temp;
reg flag_left,flag_mid;
wire flag;
reg [6:0] candidate_reg;

assign candidate = {1'b0,candidate_reg};
assign now_x = counter[2:0] + 1;
assign now_y = counter[5:3] + 1;

assign temp_2 = temp * temp;
assign flag = (left_reg_1 + left_reg_2 <= temp_2)?1'b1:0;


always @(posedge clk or posedge rst) begin
	if (rst) begin
		busy <= 0;
	end
	else begin
		if (en == 1) begin
			busy <= 1;
			counter <= 0;
			valid <= 0;
			candidate_reg <= 0;
			step <= 0;
		end
		else begin
			case (step)
				4'b0000:begin
					temp <= now_x - central[23:20];
				end
				4'b0001:begin
					left_reg_1 <= temp_2;
					temp <= now_y - central[19:16];
				end
				4'b0010:begin
					left_reg_2 <= temp_2;
					temp <= radius[11:8];
				end
				4'b0011:begin
					flag_left <= flag;
					temp <= now_x - central[15:12];
				end
				4'b0100:begin
					left_reg_1 <= temp_2;
					temp <= now_y - central[11:8];
				end
				4'b0101:begin
					left_reg_2 <= temp_2;
					temp <= radius[7:4];
				end
				4'b0110:begin
					flag_mid <= flag;
					temp <= now_x - central[7:4];
				end
				4'b0111:begin
					left_reg_1 <= temp_2;
					temp <= now_y - central[3:0];
				end
				4'b1000:begin
					left_reg_2 <= temp_2;
					temp <= radius[3:0];
				end
				4'b1001:begin
					case(mode)
						2'b00:begin
							if(flag_left) begin
								candidate_reg <= candidate_reg + 1;
							end
						end
						2'b01:begin
							if(flag_left & flag_mid) begin
								candidate_reg <= candidate_reg + 1;
							end
						end
						2'b10:begin
							if(flag_left ^ flag_mid) begin
								candidate_reg <= candidate_reg + 1;
							end
						end
						2'b11:begin
							if((!flag_left & flag_mid & flag)||(flag_left & !flag_mid & flag)||(flag_left & flag_mid & !flag)) begin
								candidate_reg <= candidate_reg + 1;
							end
						end
					endcase
				
				end
				4'b1010:begin
					busy <= 0;
										
					if (&counter) begin 
						valid <= 1;
					end
					counter <= counter + 1;
				end
			endcase
			step <= step + 1;
		end
	end
end

endmodule*/