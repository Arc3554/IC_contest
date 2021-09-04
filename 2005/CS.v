`timescale 1ns/10ps
/*
 * IC Contest Computational System (CS)
*/
module CS(Y, X, reset, clk);

input clk, reset; 
input [7:0] X;
output reg [9:0] Y;

reg [10:0] X_reg [8:0];
reg [10:0] X_appr_reg;
reg [11:0] X_avg_reg,X_reg_9[8:0];
reg [3:0] step;
reg flag;

always @(*) begin
	X_avg_reg = X_reg [0]+X_reg [1]+X_reg [2]+X_reg [3] + X_reg [4] + X_reg [5] + X_reg [6] + X_reg [7] + X;
	X_reg_9[0] = X_reg[0] + (X_reg[0]<<3);
	X_reg_9[1] = X_reg[1] + (X_reg[1]<<3);
	X_reg_9[2] = X_reg[2] + (X_reg[2]<<3);
	X_reg_9[3] = X_reg[3] + (X_reg[3]<<3);
	X_reg_9[4] = X_reg[4] + (X_reg[4]<<3);
	X_reg_9[5] = X_reg[5] + (X_reg[5]<<3);
	X_reg_9[6] = X_reg[6] + (X_reg[6]<<3);
	X_reg_9[7] = X_reg[7] + (X_reg[7]<<3);
	X_reg_9[8] = ((X + X) + (X + X)) + ((X + X) + (X + X)) + X;
end


always @(posedge clk or posedge reset) begin
	if (reset) begin
		X_reg [0] <= 0;
		X_reg [1] <= 0;
		X_reg [2] <= 0;
		X_reg [3] <= 0;
		X_reg [4] <= 0;
		X_reg [5] <= 0;
		X_reg [6] <= 0;
		X_reg [7] <= 0;
		step <= 0;
		flag <= 0;
	end
	else begin
		X_reg [8] <= X_reg [0];
		X_reg [0] <= X_reg [1];
		X_reg [1] <= X_reg [2];
		X_reg [2] <= X_reg [3];
		X_reg [3] <= X_reg [4];
		X_reg [4] <= X_reg [5];
		X_reg [5] <= X_reg [6];
		X_reg [6] <= X_reg [7];
		X_reg [7] <= X;
		if (step == 4'd8) begin
			if (X_reg_9[8] == X_avg_reg) X_appr_reg <= X;
			else if (X_reg_9[0] == X_avg_reg) X_appr_reg <= X_reg[0];
			else if (X_reg_9[1] == X_avg_reg) X_appr_reg <= X_reg[1];
			else if (X_reg_9[2] == X_avg_reg) X_appr_reg <= X_reg[2];
			else if (X_reg_9[3] == X_avg_reg) X_appr_reg <= X_reg[3];
			else if (X_reg_9[4] == X_avg_reg) X_appr_reg <= X_reg[4];
			else if (X_reg_9[5] == X_avg_reg) X_appr_reg <= X_reg[5];
			else if (X_reg_9[6] == X_avg_reg) X_appr_reg <= X_reg[6];
			else if (X_reg_9[7] == X_avg_reg) X_appr_reg <= X_reg[7];
			else begin
				if (X_avg_reg - X_reg_9[8] <= X_avg_reg - X_reg_9[0] && X_avg_reg - X_reg_9[8] <= X_avg_reg - X_reg_9[1] && X_avg_reg - X_reg_9[8] <= X_avg_reg - X_reg_9[2] && X_avg_reg - X_reg_9[8] <= X_avg_reg - X_reg_9[3] && X_avg_reg - X_reg_9[8] <= X_avg_reg - X_reg_9[4] && X_avg_reg - X_reg_9[8] <= X_avg_reg - X_reg_9[5] && X_avg_reg - X_reg_9[8] <= X_avg_reg - X_reg_9[6] && X_avg_reg - X_reg_9[8] <= X_avg_reg - X_reg_9[7]) X_appr_reg <= X;
				else if (X_avg_reg - X_reg_9[0] <= X_avg_reg - X_reg_9[8] && X_avg_reg - X_reg_9[0] <= X_avg_reg - X_reg_9[1] && X_avg_reg - X_reg_9[0] <= X_avg_reg - X_reg_9[2] && X_avg_reg - X_reg_9[0] <= X_avg_reg - X_reg_9[3] && X_avg_reg - X_reg_9[0] <= X_avg_reg - X_reg_9[4] && X_avg_reg - X_reg_9[0] <= X_avg_reg - X_reg_9[5] && X_avg_reg - X_reg_9[0] <= X_avg_reg - X_reg_9[6] && X_avg_reg - X_reg_9[0] <= X_avg_reg - X_reg_9[7]) X_appr_reg <= X_reg[0];
				else if (X_avg_reg - X_reg_9[1] <= X_avg_reg - X_reg_9[8] && X_avg_reg - X_reg_9[1] <= X_avg_reg - X_reg_9[0] && X_avg_reg - X_reg_9[1] <= X_avg_reg - X_reg_9[2] && X_avg_reg - X_reg_9[1] <= X_avg_reg - X_reg_9[3] && X_avg_reg - X_reg_9[1] <= X_avg_reg - X_reg_9[4] && X_avg_reg - X_reg_9[1] <= X_avg_reg - X_reg_9[5] && X_avg_reg - X_reg_9[1] <= X_avg_reg - X_reg_9[6] && X_avg_reg - X_reg_9[1] <= X_avg_reg - X_reg_9[7]) X_appr_reg <= X_reg[1];
				else if (X_avg_reg - X_reg_9[2] <= X_avg_reg - X_reg_9[8] && X_avg_reg - X_reg_9[2] <= X_avg_reg - X_reg_9[0] && X_avg_reg - X_reg_9[2] <= X_avg_reg - X_reg_9[1] && X_avg_reg - X_reg_9[2] <= X_avg_reg - X_reg_9[3] && X_avg_reg - X_reg_9[2] <= X_avg_reg - X_reg_9[4] && X_avg_reg - X_reg_9[2] <= X_avg_reg - X_reg_9[5] && X_avg_reg - X_reg_9[2] <= X_avg_reg - X_reg_9[6] && X_avg_reg - X_reg_9[2] <= X_avg_reg - X_reg_9[7]) X_appr_reg <= X_reg[2];
				else if (X_avg_reg - X_reg_9[3] <= X_avg_reg - X_reg_9[8] && X_avg_reg - X_reg_9[3] <= X_avg_reg - X_reg_9[0] && X_avg_reg - X_reg_9[3] <= X_avg_reg - X_reg_9[1] && X_avg_reg - X_reg_9[3] <= X_avg_reg - X_reg_9[2] && X_avg_reg - X_reg_9[3] <= X_avg_reg - X_reg_9[4] && X_avg_reg - X_reg_9[3] <= X_avg_reg - X_reg_9[5] && X_avg_reg - X_reg_9[3] <= X_avg_reg - X_reg_9[6] && X_avg_reg - X_reg_9[3] <= X_avg_reg - X_reg_9[7]) X_appr_reg <= X_reg[3];
				else if (X_avg_reg - X_reg_9[4] <= X_avg_reg - X_reg_9[8] && X_avg_reg - X_reg_9[4] <= X_avg_reg - X_reg_9[0] && X_avg_reg - X_reg_9[4] <= X_avg_reg - X_reg_9[1] && X_avg_reg - X_reg_9[4] <= X_avg_reg - X_reg_9[2] && X_avg_reg - X_reg_9[4] <= X_avg_reg - X_reg_9[3] && X_avg_reg - X_reg_9[4] <= X_avg_reg - X_reg_9[5] && X_avg_reg - X_reg_9[4] <= X_avg_reg - X_reg_9[6] && X_avg_reg - X_reg_9[4] <= X_avg_reg - X_reg_9[7]) X_appr_reg <= X_reg[4];
				else if (X_avg_reg - X_reg_9[5] <= X_avg_reg - X_reg_9[8] && X_avg_reg - X_reg_9[5] <= X_avg_reg - X_reg_9[0] && X_avg_reg - X_reg_9[5] <= X_avg_reg - X_reg_9[1] && X_avg_reg - X_reg_9[5] <= X_avg_reg - X_reg_9[2] && X_avg_reg - X_reg_9[5] <= X_avg_reg - X_reg_9[3] && X_avg_reg - X_reg_9[5] <= X_avg_reg - X_reg_9[4] && X_avg_reg - X_reg_9[5] <= X_avg_reg - X_reg_9[6] && X_avg_reg - X_reg_9[5] <= X_avg_reg - X_reg_9[7]) X_appr_reg <= X_reg[5];
				else if (X_avg_reg - X_reg_9[6] <= X_avg_reg - X_reg_9[8] && X_avg_reg - X_reg_9[6] <= X_avg_reg - X_reg_9[0] && X_avg_reg - X_reg_9[6] <= X_avg_reg - X_reg_9[1] && X_avg_reg - X_reg_9[6] <= X_avg_reg - X_reg_9[2] && X_avg_reg - X_reg_9[6] <= X_avg_reg - X_reg_9[3] && X_avg_reg - X_reg_9[6] <= X_avg_reg - X_reg_9[4] && X_avg_reg - X_reg_9[6] <= X_avg_reg - X_reg_9[5] && X_avg_reg - X_reg_9[6] <= X_avg_reg - X_reg_9[7]) X_appr_reg <= X_reg[6];
				else if (X_avg_reg - X_reg_9[7] <= X_avg_reg - X_reg_9[8] && X_avg_reg - X_reg_9[7] <= X_avg_reg - X_reg_9[0] && X_avg_reg - X_reg_9[7] <= X_avg_reg - X_reg_9[1] && X_avg_reg - X_reg_9[7] <= X_avg_reg - X_reg_9[2] && X_avg_reg - X_reg_9[7] <= X_avg_reg - X_reg_9[3] && X_avg_reg - X_reg_9[7] <= X_avg_reg - X_reg_9[4] && X_avg_reg - X_reg_9[7] <= X_avg_reg - X_reg_9[5] && X_avg_reg - X_reg_9[7] <= X_avg_reg - X_reg_9[6]) X_appr_reg <= X_reg[7];
			end
			flag <= 1;
		end
		else step <= step +1;
	end
end

always @(negedge clk) begin
	if (flag == 1) begin
		Y <= (X_avg_reg - X + X_reg[8] + X_appr_reg + (X_appr_reg<<3))>>3;
	end
end


endmodule
