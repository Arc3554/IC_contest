module S2(clk,
	  rst,
	  S2_done,
	  RB2_RW,
	  RB2_A,
	  RB2_D,
	  RB2_Q,
	  sen,
	  sd);

input clk, rst;
output reg S2_done, RB2_RW;
output reg [2:0] RB2_A;
output reg [17:0] RB2_D;
input [17:0] RB2_Q;
input sen, sd;

reg [4:0] step;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		RB2_RW <= 1;// 讀取
		RB2_A <= 0;
		step <= 5'd20;
		S2_done <= 0;
	end
	else begin
		case(step)
			default:begin		
				RB2_D[step] <= sd;
				step <= step - 1;
			end
			5'd20:begin
				RB2_RW <= 1;
				RB2_A[2] <= sd;
				step <= step - 1;
				if((&RB2_A)) begin
					S2_done <= 1;
				end
			end
			5'd19:begin
				RB2_A[1] <= sd;
				step <= step - 1;
			end
			5'd18:begin
				RB2_A[0] <= sd;
				step <= step - 1;
			end
			5'd0:begin
				RB2_D[0] <= sd;
				RB2_RW <= 0;
				step <= 5'd20;
			end
		endcase
	end
end
endmodule
