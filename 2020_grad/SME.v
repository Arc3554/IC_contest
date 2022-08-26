module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output reg valid;

reg [7:0] string_buffer [33:0],pattern_buffer[7:0];//指最後+1
reg [5:0] string_length,string_pointer;//0~33
reg [3:0] pattern_length,pattern_pointer,pattern_pointer_temp;//0~8

wire [3:0] pattern_pointer_plus1;
assign pattern_pointer_plus1 = pattern_pointer + 4'd1;

wire [5:0] string_pointer_plus1;
assign string_pointer_plus1 = string_pointer + 6'd1;

reg [1:0] state,next_state;
reg wait_flag,have_star;

wire pattern_flag = (string_pointer==string_length || pattern_pointer == pattern_length)?1'b1:0;
wire [5:0] s_pointer_plus_p_pointer = string_pointer + pattern_pointer;

always@(*) begin
	case(state)
		0:begin
			if(isstring || ispattern) next_state = 0;
			else next_state = 1;
		end
		1:begin
			next_state = 2;
		end
		2:begin
			if(pattern_flag) next_state = 3;
			else next_state = 2;
		end
		3:begin
			next_state = 0;
		end
	endcase	
end

always@(posedge clk or posedge reset) begin
	if(reset) state <= 0;
	else state <= next_state;
end


always@(posedge clk or posedge reset) begin
	if(reset) begin
		wait_flag <= 1;
		pattern_length <= 0;
		string_buffer[1] <= 0;
		string_buffer[2] <= 0;
		string_buffer[3] <= 0;
		string_buffer[4] <= 0;
		string_buffer[5] <= 0;
		string_buffer[6] <= 0;
		string_buffer[7] <= 0;
		string_buffer[8] <= 0;
		string_buffer[9] <= 0;
		string_buffer[10] <= 0;
		string_buffer[11] <= 0;
		string_buffer[12] <= 0;
		string_buffer[13] <= 0;
		string_buffer[14] <= 0;
		string_buffer[15] <= 0;
		string_buffer[16] <= 0;
		string_buffer[17] <= 0;
		string_buffer[18] <= 0;
		string_buffer[19] <= 0;
		string_buffer[20] <= 0;
		string_buffer[21] <= 0;
		string_buffer[22] <= 0;
		string_buffer[23] <= 0;
		string_buffer[24] <= 0;
		string_buffer[25] <= 0;
		string_buffer[26] <= 0;
		string_buffer[27] <= 0;
		string_buffer[28] <= 0;
		string_buffer[29] <= 0;
		string_buffer[30] <= 0;
		string_buffer[31] <= 0;
		string_buffer[32] <= 0;
		string_buffer[33] <= 0;
		string_pointer <= 1;
	end
	else begin
		case(state)
			0:begin
				if(isstring) begin
					if(wait_flag) begin
						wait_flag <= 0;
					end
					string_pointer <= string_pointer_plus1;
					string_buffer[string_pointer] <= chardata;
				end
				else if(ispattern)begin
					pattern_buffer[pattern_length] <= chardata;
					pattern_length <= pattern_length + 1;
					
				end
				valid <= 0;
				
				match_index <= 0;
				have_star <= 0;
				pattern_pointer <= 0;
			end
			1:begin
				if(!wait_flag) begin
					string_length <= string_pointer_plus1;
					string_buffer[string_pointer] <= 8'd32;
				end
				string_buffer[0] <= 8'd32;
				string_pointer <= 0;
				wait_flag<=1;
				
			end
			2:begin
				if(!pattern_flag) begin
					if(pattern_buffer[pattern_pointer]==8'd94) begin//^
						if(string_buffer[s_pointer_plus_p_pointer]==8'd32) begin
							pattern_pointer <= pattern_pointer_plus1;
							wait_flag <= 0;
							match_index <= string_pointer;
							match <= 1;
						end
						else begin
							pattern_pointer <= 0;
							string_pointer <= string_pointer_plus1;
							wait_flag <= 1;
						end
						
					end
					
					else if(pattern_buffer[pattern_pointer]==8'd36) begin//$
						if(string_buffer[s_pointer_plus_p_pointer - have_star]==8'd32) begin
							pattern_pointer <= pattern_pointer_plus1;
						end
						else begin
							string_pointer <= string_pointer_plus1;
							match <= 0;
							pattern_pointer <= 0;
						end
					end
					
					else if(pattern_buffer[pattern_pointer]==8'd46) begin//.
						pattern_pointer <= pattern_pointer_plus1;
					end
					
					else if(pattern_buffer[pattern_pointer]==8'd42) begin//*
						have_star <= 1;

						pattern_pointer_temp <= pattern_pointer_plus1;
						pattern_pointer <= pattern_pointer_plus1;
					end
					
					else begin
						if(string_buffer[s_pointer_plus_p_pointer - have_star]==pattern_buffer[pattern_pointer]) begin
							match_index <= (have_star)? match_index:string_pointer - wait_flag;
							pattern_pointer <= pattern_pointer_plus1;
							match <= 1;
						end
						else begin
							pattern_pointer <= (have_star)? pattern_pointer_temp:0;
							match <= 0;
							string_pointer <= string_pointer_plus1;
							wait_flag <= 1;
						end
					end
				end
			end
			3:begin
				valid <= 1;
				pattern_length <= 0;
				wait_flag <= 1;
				string_pointer <= 1;
			end
		endcase
	end
end
endmodule
