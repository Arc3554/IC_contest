module S1(clk,
	  rst,
	  RB1_RW,
	  RB1_A,
	  RB1_D,
	  RB1_Q,
	  sen,
	  sd);

  input clk, rst;
  output reg RB1_RW;      // control signal for RB1: Read/Write
  output [4:0] RB1_A; // control signal for RB1: address
  output [7:0] RB1_D; // data path for RB1: input port
  input [7:0] RB1_Q;  // data path for RB1: output port
  output reg sen, sd;

reg [4:0] step;
reg [2:0] count;

//assign RB1_A = (step <= 5'd17)? step:0;
assign RB1_A = step;


always @(negedge clk or posedge rst) begin
	if(rst) begin
		sen <= 1;
		RB1_RW <= 1;//讀取
		step <= 5'd20;
		count <= 3'b111;
	end
	else begin
		case(step)
			default:begin
				sd <= RB1_Q[count];
				step <= step - 1;
			end
			5'd20:begin
				sen <= 0;
				sd <= ~count[2];
				step <= step - 1;
			end
			5'd19:begin
				sd <= ~count[1];
				step <= step - 1;
			end
			5'd18:begin
				sd <= ~count[0];
				step <= step - 1;
			end
			5'd0:begin
				sd <= RB1_Q[count];
				//step <= 5'd20;
				step[4] <= 1;
				step[2] <= 1;
				count <= count - 1;
			end
		endcase
	end
end

endmodule
