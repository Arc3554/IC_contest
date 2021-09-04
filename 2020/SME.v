module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output reg valid;


reg [7:0] string_buffer [0:31],pattern_buffer[0:9];
reg [3:0] pattern_length,pattern_count;
reg [5:0] string_length,string_count;
reg flag;
reg first_string;

wire headsign = (pattern_buffer[0] == 8'd94)? 1:0;
wire dollarsign = (pattern_buffer[pattern_length - 4'd1] == 8'd36)? 1:0;

always@(posedge clk or posedge reset) begin
	if (reset) begin
		match <= 0;
		match_index <= 0;
		valid <= 0;
		
		pattern_count <= 0;
		pattern_length <= 0;
		string_length <= 0;
		string_count <= 0;
		first_string <= 0;
		flag <= 0;
		
	end
	else begin
		if (isstring) begin	
			if (first_string == 0) begin
				string_length <= 5'd1;
				string_buffer[0] <= chardata;
			end
			else begin
				string_length <= string_length+1;
				string_buffer[string_length] <= chardata;		
			end
			first_string <= 1;
			valid <= 0;
		end
		else begin
			if(ispattern) begin
				valid <= 0;
				match <= 0;
				pattern_buffer[pattern_length] <= chardata;
				pattern_length <= pattern_length+1;
			end
			else begin
				case ({headsign,dollarsign})
					2'b11: begin
						if (pattern_count == 0 && (string_count == 0 || string_buffer[string_count]==8'd32)) begin
							pattern_count <= pattern_count + 1;
							match <= 1;
							flag <= (string_count == 0)?1:0;
							valid <= 0;
						end
						else if (string_count + pattern_length - 1 <= string_length && pattern_count < pattern_length-1) begin
							if (string_buffer[string_count+pattern_count]==pattern_buffer[pattern_count]||pattern_buffer[pattern_count]==8'd46) begin
								pattern_count <= pattern_count + 1;
								match <= 1;
								match_index <= (string_count==0)? 0: string_count+1;
							end
							else begin
								pattern_count <= 0;
								match <= 0;
								string_count <= string_count + 1;
								match_index <= 0;
							end
							valid <= 0;
						end
						else if (pattern_count == pattern_length-1 && (string_buffer[string_count+pattern_count-flag]==8'd32||string_count+pattern_count-flag == string_length)) begin
							match <= 1;
							valid <= 1;
							pattern_count <= 0;
							string_count <= 0;
							pattern_length <= 0;
							first_string <= 0;
							flag <= 0;
						end
						else if (string_count == string_length-1) begin
							match <= 0;				
							valid <= 1;
							pattern_count <= 0;
							string_count <= 0;
							pattern_length <= 0;
							first_string <= 0;	
							flag <= 0;
						end
						else begin
							pattern_count <= 0;
							match <= 0;
							string_count <= string_count + 1;
							match_index <= 0;
							flag <= 0;
							valid <= 0;
						end	
					end
					2'b10: begin
						if (pattern_count == 0 && (string_count == 0 || string_buffer[string_count]==8'd32)) begin
							pattern_count <= pattern_count + 1;
							match <= 1;
						end
						else if (string_count + pattern_length <= string_length && pattern_count < pattern_length) begin
							if (string_buffer[string_count+pattern_count]==pattern_buffer[pattern_count]||pattern_buffer[pattern_count]==8'd46) begin
								pattern_count <= pattern_count + 1;
								match <= 1;
								match_index <= string_count+1;
							end
							else begin
								pattern_count <= 0;
								match <= 0;
								string_count <= string_count + 1;
								match_index <= 0;
							end
						end
						else begin
							valid <= 1;
							pattern_count <= 0;
							string_count <= 0;
							pattern_length <= 0;
							first_string <= 0;
						end
					end
					2'b01: begin
						if (string_count + pattern_length -1  <= string_length && pattern_count < pattern_length-1) begin
							if (string_buffer[string_count+pattern_count]==pattern_buffer[pattern_count]||pattern_buffer[pattern_count]==8'd46) begin
								pattern_count <= pattern_count + 1;
								match <= 1;
								match_index <= string_count;
							end
							else begin
								pattern_count <= 0;
								match <= 0;
								string_count <= string_count + 1;
								match_index <= 0;
							end
						end
						else if (pattern_count == pattern_length-1 && (string_buffer[string_count+pattern_count]==8'd32||string_count+pattern_count == string_length)) begin
							match <= 1;
							valid <= 1;
							pattern_count <= 0;
							string_count <= 0;
							pattern_length <= 0;
							first_string <= 0;
						end
						else if (string_count == string_length) begin
							match <= 0;				
							valid <= 1;
							pattern_count <= 0;
							string_count <= 0;
							pattern_length <= 0;
							first_string <= 0;	
						end
						else begin
							pattern_count <= 0;
							match <= 0;
							string_count <= string_count + 1;
							match_index <= 0;
						end				
					end
					2'b00: begin
						if (string_count + pattern_length <= string_length && pattern_count < pattern_length) begin
							if (string_buffer[string_count+pattern_count]==pattern_buffer[pattern_count]||pattern_buffer[pattern_count]==8'd46) begin
								pattern_count <= pattern_count + 1;
								match <= 1;
								match_index <= string_count;
							end
							else begin
								pattern_count <= 0;
								match <= 0;
								string_count <= string_count + 1;
								match_index <= 0;
							end
						end
						else begin
							valid <= 1;
							pattern_count <= 0;
							string_count <= 0;
							pattern_length <= 0;
							first_string <= 0;
						end
					end
					
				endcase
			end
		end
	
	end
end

endmodule