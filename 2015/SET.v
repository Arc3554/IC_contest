module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output reg busy;
output reg valid;
output reg [7:0] candidate;

reg [15:0] central_reg;
reg [7:0] radius_reg;
reg [1:0] mode_reg;
reg [3:0] now_x,now_y;
reg [7:0] a_num,b_num,a_and_b;

reg [8:0] radius_reg2_a,radius_reg2_b,x_diff_a,y_diff_a,x_diff_b,y_diff_b;

always @(*)begin
	radius_reg2_a = radius_reg[7:4] * radius_reg [7:4];
	radius_reg2_b = radius_reg[3:0] * radius_reg [3:0];
	x_diff_a = (now_x > central_reg[15:12]) ? now_x - central_reg[15:12] : central_reg[15:12] - now_x;
	y_diff_a = (now_y > central_reg[11:8]) ? now_y - central_reg[11:8] : central_reg[11:8] - now_y;
	x_diff_b = (now_x > central_reg[7:4]) ? now_x - central_reg[7:4] : central_reg[7:4] - now_x;
	y_diff_b = (now_y > central_reg[3:0]) ? now_y - central_reg[3:0] : central_reg[3:0] - now_y;
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		busy <= 0;
		valid <= 0;
		candidate <= 0;
	end
	else begin
		if (en == 1) begin
			central_reg <= central[23:8];
			radius_reg <= radius[11:4];
			mode_reg <= mode;
			busy <= 1;
			now_x <= 1;
			now_y <= 1;
			valid <= 0;
			candidate <= 0;
			a_num <= 0;
			b_num <= 0;
			a_and_b <= 0;
		end
		else if (valid == 1) begin
			valid <= 0;
			busy <= 0;
		end
		else begin
			case (mode_reg)
				2'b00:begin 
					if(x_diff_a*x_diff_a+y_diff_a*y_diff_a <= radius_reg2_a) candidate <= candidate + 1;
					
					if (now_x == 4'd8 && now_y == 4'd8) begin valid <= 1; end
					else if (now_x == 4'd8) begin now_y <= now_y+1; now_x <= 1; end
					else now_x <= now_x +1;
				end
				2'b01:begin 
					if(x_diff_a*x_diff_a+y_diff_a*y_diff_a <= radius_reg2_a && x_diff_b*x_diff_b+y_diff_b*y_diff_b <= radius_reg2_b) candidate <= candidate + 1;
					
					if (now_x == 4'd8 && now_y == 4'd8) begin valid <= 1; end
					else if (now_x == 4'd8) begin now_y <= now_y+1; now_x <= 1; end
					else now_x <= now_x +1;
				
				end
				2'b10:begin
					if(x_diff_a*x_diff_a+y_diff_a*y_diff_a <= radius_reg2_a ^ x_diff_b*x_diff_b+y_diff_b*y_diff_b <= radius_reg2_b) candidate <= candidate + 1;
					
					if (now_x == 4'd8 && now_y == 4'd8) begin valid <= 1; end
					else if (now_x == 4'd8) begin now_y <= now_y+1; now_x <= 1; end
					else now_x <= now_x +1;
				end
				2'b11:begin end
			endcase
		end
	end
end



endmodule
