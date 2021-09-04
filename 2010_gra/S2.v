module S2(clk,
	  rst,
	  updown,
	  S2_done,
	  RB2_RW,
	  RB2_A,
	  RB2_D,
	  RB2_Q,
	  sen,
	  sd);

  input clk,
        rst,
        updown;
  
  output reg S2_done,RB2_RW;
  
  output reg [2:0] RB2_A;
  
  output reg [17:0] RB2_D;
  
  input [17:0] RB2_Q;
  
  inout sen,
        sd;


reg [5:0] step;
reg sd_temp;

assign sen = 1'bz;
assign sd = (updown)?sd_temp:1'bz;

wire [4:0] temp;
assign temp = 5'd17 - RB2_D[4:0];


wire [2:0] temp_A;
assign temp_A = RB2_A - 1;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		RB2_RW <= 1; 
		RB2_A <= 0;
		step <= 6'd20;
		S2_done <= 0;
	end
	else begin
		case(step)
			default:begin		
				RB2_D[step] <= sd;
				step <= step - 1;
			end
			6'd20:begin
				RB2_A[2] <= sd;
				step <= step - 1;
			end
			6'd19:begin
				RB2_A[1] <= sd;
				step <= step - 1;
			end
			6'd18:begin
				RB2_A[0] <= sd;
				step <= step - 1;
			end
			6'd0:begin
				RB2_D[0] <= sd;
				step[5] <= 1;
				RB2_RW <= 0;
			end
			6'd32:begin
				RB2_RW <= 1;
				if((&RB2_A)) begin
					S2_done <= 1;
					step <= 6'd63;
					RB2_D[4:0] <= 0;
				end
				else step <= 6'd20;
			end
			6'd63:begin
				sd_temp <= RB2_D[4];
				step <= step - 1;
			end
			6'd62:begin
				sd_temp <= RB2_D[3];
				step <= step - 1;
			end
			6'd61:begin
				sd_temp <= RB2_D[2];
				step <= step - 1;
			end
			6'd60:begin
				sd_temp <= RB2_D[1];
				step <= step - 1;
			end
			6'd59:begin
				sd_temp <= RB2_D[0];
				step <= step - 1;
				RB2_A <= temp_A;
			end
			6'd58:begin
				sd_temp <= RB2_Q[temp];
				step <= step - 1;
				RB2_A <= temp_A;
			end
			6'd57:begin
				sd_temp <= RB2_Q[temp];
				step <= step - 1;
				RB2_A <= temp_A;
			end
			6'd56:begin
				sd_temp <= RB2_Q[temp];
				step <= step - 1;
				RB2_A <= temp_A;
			end
			6'd55:begin
				sd_temp <= RB2_Q[temp];
				step <= step - 1;
				RB2_A <= temp_A;
			end
			6'd54:begin
				sd_temp <= RB2_Q[temp];
				step <= step - 1;
				RB2_A <= temp_A;
			end
			6'd53:begin
				sd_temp <= RB2_Q[temp];
				step <= step - 1;
				RB2_A <= temp_A;
			end
			6'd52:begin
				sd_temp <= RB2_Q[temp];
				step <= step - 1;
				RB2_A <= temp_A;
			end
			6'd51:begin
				sd_temp <= RB2_Q[temp];
				step <= step - 1;
			end
			6'd50:begin
				step <= 6'd63;
				RB2_D[4:0] <= RB2_D[4:0] + 1;
			end
		endcase
	end
end


endmodule
