module S1(clk,
	  rst,
	  updown,
	  S1_done,
	  RB1_RW,
	  RB1_A,
	  RB1_D,
	  RB1_Q,
	  sen,
	  sd);

  input clk,
        rst,
        updown;

  output reg S1_done,RB1_RW;
  
  output reg [4:0] RB1_A;
  
  output reg [7:0] RB1_D;
  
  input [7:0] RB1_Q;
  
  inout sen,
        sd;

reg [5:0] step;
reg sd_temp_step;

wire [5:0] temp_step;
assign temp_step = step - 1;

assign sen = 1'b0;
assign sd = (updown == 0)?sd_temp_step:1'bz;


always @(negedge clk or posedge rst) begin
	if(rst) begin
		RB1_RW <= 1;//讀取
		step <= 6'd20;
		RB1_D[2:0] <= 3'b111;
		RB1_A <= 5'd17;
		S1_done <= 0;
	end
	else begin
		case(step)
			default:begin
				sd_temp_step <= RB1_Q[RB1_D[2:0]];
				step <= temp_step;
				RB1_A <= temp_step;
			end
			6'd20:begin
				sd_temp_step <= ~RB1_D[2];
				step <= temp_step;
			end
			6'd19:begin
				sd_temp_step <= ~RB1_D[1];
				step <= temp_step;
			end
			6'd18:begin
				sd_temp_step <= ~RB1_D[0];
				step <= temp_step;
				RB1_A <= temp_step;
			end
			6'd0:begin
				sd_temp_step <= RB1_Q[RB1_D[2:0]];
				step[5] <= 1;
				RB1_D[2:0] <= RB1_D[2:0] - 1;
			end
			6'd32:begin	
				if(&(RB1_D[2:0])) step[0] <= 1;
				else step <= 6'd20;
			end
			6'd33:begin
				step <= 6'd63;
			end
			6'd63:begin
				RB1_A[4] <= sd;
				step <= temp_step;
			end
			6'd62:begin
				RB1_A[3] <= sd;
				step <= temp_step;
			end
			6'd61:begin
				RB1_A[2] <= sd;
				step <= temp_step;
			end
			6'd60:begin
				RB1_A[1] <= sd;
				step <= temp_step;
			end
			6'd59:begin
				RB1_A[0] <= sd;
				step <= temp_step;
			end
			6'd58:begin
				RB1_D[7] <= sd;
				step <= temp_step;
			end
			6'd57:begin
				RB1_D[6] <= sd;
				step <= temp_step;
			end
			6'd56:begin
				RB1_D[5] <= sd;
				step <= temp_step;
			end
			6'd55:begin
				RB1_D[4] <= sd;
				step <= temp_step;
			end
			6'd54:begin
				RB1_D[3] <= sd;
				step <= temp_step;
			end
			6'd53:begin
				RB1_D[2] <= sd;
				step <= temp_step;
			end
			6'd52:begin
				RB1_D[1] <= sd;
				step <= temp_step;
			end
			6'd51:begin
				RB1_D[0] <= sd;
				step <= temp_step;
				RB1_RW <= 0;
			end
			6'd50:begin
				if(RB1_A == 5'd17) S1_done <= 1;
				step <= 6'd63;
				RB1_RW <= 1;
			end
		endcase
	end
end


endmodule
