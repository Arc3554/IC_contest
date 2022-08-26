module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output Valid );

reg [2:0] a [7:0];
reg [3:0] state,next_state;
reg [2:0] swap;

reg [9:0] cost_all;//1024


wire [3:0] b [7:0];

wire [2:0] position [5:0];

wire [9:0] cost_plus_Cost;
assign cost_plus_Cost = cost_all + Cost;

assign b[0] = 8;
assign b[1] = swap>=1||a[1]<a[swap] ? 8 : a[1];
assign b[2] = swap>=2||a[2]<a[swap] ? 8 : a[2];
assign b[3] = swap>=3||a[3]<a[swap] ? 8 : a[3];
assign b[4] = swap>=4||a[4]<a[swap] ? 8 : a[4];
assign b[5] = swap>=5||a[5]<a[swap] ? 8 : a[5];
assign b[6] = swap>=6||a[6]<a[swap] ? 8 : a[6];
assign b[7] = a[7]<=a[swap] ? 8 : a[7];

assign position[0] = b[2]<b[3] ? 2:3;
assign position[1] = b[4]<b[5] ? 4:5;
assign position[2] = b[6]<b[7] ? 6:7;
assign position[3] = b[1]<b[position[0]] ? 1:position[0];
assign position[4] = b[position[1]]<b[position[2]] ? position[1]:position[2];
assign position[5] = b[position[3]]<b[position[4]] ? position[3]:position[4];

always@(*) begin
	if(a[6]<a[7]) begin
		swap = 6;
	end
	else if(a[5]<a[6]) begin
		swap = 5;
	end
	else if(a[4]<a[5]) begin
		swap = 4;
	end
	else if(a[3]<a[4]) begin
		swap = 3;
	end
	else if(a[2]<a[3]) begin
		swap = 2;
	end
	else if(a[1]<a[2]) begin
		swap = 1;
	end
	else if(a[0]<a[1]) begin
		swap = 0;
	end
	else begin
		swap = 7;
	end
end

assign Valid = (&W && state ==8 )?1'b1:0;

always@(*) begin
	next_state = 4'dx;
	case (state)
		0 : next_state = 1;
		1 : next_state = 2;
		2 : next_state = 3;
		3 : next_state = 4;
		4 : next_state = 5;
		5 : next_state = 6;
		6 : next_state = 7;
		7 : next_state = 8;
		8 : next_state = 0;
	endcase
end

always@(posedge CLK or posedge RST) begin
	if(RST) state <= 0;
	else state <= next_state;
end

always@(posedge CLK or posedge RST) begin
	if(RST) begin
		a[0] <= 0;
		a[1] <= 1;
		a[2] <= 2;
		a[3] <= 3;
		a[4] <= 4;
		a[5] <= 5;
		a[6] <= 6;
		a[7] <= 7;
		MinCost <= 10'b1111111111;
		W <= 0;
		J <= 0;
	end
	else begin
		case(state)
		//窮舉
			0: begin
				W <= a[1];
				J <= 1;
				cost_all <= 0;
			end
			1: begin
				W <= a[2];
				J <= 2;
				cost_all <= cost_plus_Cost;
			end
			2: begin
				W <= a[3];
				J <= 3;
				cost_all <= cost_plus_Cost;
			end
			3: begin
				W <= a[4];
				J <= 4;
				cost_all <= cost_plus_Cost;
			end
			4: begin
				W <= a[5];
				J <= 5;
				cost_all <= cost_plus_Cost;
			end
			5: begin
				W <= a[6];
				J <= 6;
				cost_all <= cost_plus_Cost;
			end
			6: begin
				W <= a[7];
				J <= 7;
				cost_all <= cost_plus_Cost;
			end
			7: begin
				cost_all <= cost_plus_Cost;
				a[swap] <= a[position[5]];
				a[position[5]] <= a[swap];
				W <= swap;
			end
			8:begin
				if(MinCost > cost_plus_Cost) begin
					MinCost <= cost_plus_Cost;
					MatchCount <= 1;
				end
				else if (MinCost == cost_plus_Cost) begin
					MatchCount <= MatchCount + 1;
				end
				
				case(W)
					0: begin
						a[1] <= a[7];
						a[2] <= a[6];
						a[3] <= a[5];
						a[4] <= a[4];
						a[5] <= a[3];
						a[6] <= a[2];
						a[7] <= a[1];
					end
					1: begin
						a[2] <= a[7];
						a[3] <= a[6];
						a[4] <= a[5];
						a[5] <= a[4];
						a[6] <= a[3];
						a[7] <= a[2];
					end
					2: begin
						a[3] <= a[7];
						a[4] <= a[6];
						a[6] <= a[4];
						a[7] <= a[3];
					end
					3: begin
						a[4] <= a[7];
						a[5] <= a[6];
						a[6] <= a[5];
						a[7] <= a[4];
					end
					4: begin
						a[5] <= a[7];
						a[7] <= a[5];
					end
					5: begin
						a[6] <= a[7];
						a[7] <= a[6];
					end
				endcase
				W <= a[0];
				J <= 0;
			end
		endcase
	end
end

endmodule