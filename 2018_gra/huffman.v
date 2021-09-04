`timescale 1ns/10ps
module huffman ( clk, reset, gray_valid, gray_data, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);
input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output reg CNT_valid;
output [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output reg code_valid;
output [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output [7:0] M1, M2, M3, M4, M5, M6;

reg [2:0] step;
reg [22:0] temp [0:5];
reg [2:0] count,count2;
reg [5:0] buffer;

assign CNT1 = temp[0][19:13];
assign CNT2 = temp[1][19:13];
assign CNT3 = temp[2][19:13];
assign CNT4 = temp[3][19:13];
assign CNT5 = temp[4][19:13];
assign CNT6 = temp[5][19:13];
assign HC1 = temp[0][12:8];
assign HC2 = temp[1][12:8];
assign HC3 = temp[2][12:8];
assign HC4 = temp[3][12:8];
assign HC5 = temp[4][12:8];
assign HC6 = temp[5][12:8];
assign M1 = temp[0][7:3];
assign M2 = temp[1][7:3];
assign M3 = temp[2][7:3];
assign M4 = temp[3][7:3];
assign M5 = temp[4][7:3];
assign M6 = temp[5][7:3];

wire [2:0] count3;
assign count3 = count2 + 1;

always @(posedge clk or posedge reset) begin
	if(reset) begin
		step <= 0;
		temp[0] <= 23'd0;
		temp[1] <= 23'd1;
		temp[2] <= 23'd2;
		temp[3] <= 23'd3;
		temp[4] <= 23'd4;
		temp[5] <= 23'd5;
		count <= 0;
		count2 <= 3'd4;
	end
	else begin
		case (step)
			3'b000:begin
				if(gray_valid) begin
					temp[gray_data[2:0] - 1][19:13] <= temp[gray_data[2:0] - 1][19:13] + 1;
					count[2] <= 1'b1;
				end
				else if (count != 0) begin
					step[0] <= 1'b1;
					CNT_valid <= 1'b1;
				end
			end
			3'b001:begin
				CNT_valid <= 0;
				if(temp[count + 1][19:13]>temp[count][19:13]) begin
					temp[count] <= temp[count + 1];
					temp[count + 1] <= temp[count];
					count <= 3'd4;
				end
				else if (count != 0) count <= count - 1;
				else begin
					step[1] <= 1'b1;
					count <= 3'd5;
				end
			end
			3'b011:begin
				temp[count2][19:13] <= temp[count2][19:13] + temp[count3][19:13];
				step[0] <= 1'b0;
				buffer <= {temp[count3][22:20],temp[count2][22:20]};
			end
			3'b010:begin //編碼
				if((temp[count][22:20] == buffer[5:3] && buffer[5:3] != 0)|| count == count3) begin
					temp[count][22:20] <= count2;//group
					temp[count][7:3] <= {temp[count][6:3],1'b1};//M
					temp[count][12:8] <= temp[count][12:8]|(temp[count][7:3]^({temp[count][6:3],1'b1}));//hc
				end
				else if((temp[count][22:20] == buffer[2:0] && buffer[2:0] != 0)|| count == count2) begin
					temp[count][22:20] <= count2;
					temp[count][7:3] <= {temp[count][6:3],1'b1};
				end	
				if(!count2&&!count) step[2] <= 1'b1;
				else if(!count) begin
					count <= count2 - 1;
					count2 <= count2 - 1;
					step[1:0] <= 2'b01;
				end
				else count <= count - 1;
			end
			3'b110:begin
 				temp[temp[0][2:0]] <= temp[0];
				temp[temp[1][2:0]] <= temp[1];
				temp[temp[2][2:0]] <= temp[2];
				temp[temp[3][2:0]] <= temp[3];
				temp[temp[4][2:0]] <= temp[4];
				temp[temp[5][2:0]] <= temp[5];				
				step[0] <= 1'b1;
				code_valid <= 1'b1;
			end
			3'b111:begin	
				code_valid <= 0;
			end
		endcase
	end
end
endmodule



/* `timescale 1ns/10ps
module huffman ( clk, reset, gray_valid, gray_data, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);
input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output reg CNT_valid;
output [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output reg code_valid;
output [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output [7:0] M1, M2, M3, M4, M5, M6;


reg [2:0] step;
reg next_step;

// reg [2:0] position [0:5];
// reg [2:0] how_many [0:5];

// reg [7:0] CNT_temp [0:5];
// reg [7:0] M_temp [0:5];
// reg [7:0] HC_temp [0:5]; 

reg [22:0] temp [0:5];//CNT_7,HC_5,M_5,POS,NUM

reg [2:0] count,count2;

assign CNT1 = temp[0][22:16];
assign CNT2 = temp[1][22:16];
assign CNT3 = temp[2][22:16];
assign CNT4 = temp[3][22:16];
assign CNT5 = temp[4][22:16];
assign CNT6 = temp[5][22:16];
assign HC1 = temp[0][15:11];
assign HC2 = temp[1][15:11];
assign HC3 = temp[2][15:11];
assign HC4 = temp[3][15:11];
assign HC5 = temp[4][15:11];
assign HC6 = temp[5][15:11];
assign M1 = temp[0][10:6];
assign M2 = temp[1][10:6];
assign M3 = temp[2][10:6];
assign M4 = temp[3][10:6];
assign M5 = temp[4][10:6];
assign M6 = temp[5][10:6];

always @(posedge clk or posedge reset) begin
	if(reset) begin
		step <= 0;
		temp[0] <= 30'd1;
		temp[1] <= 30'd9;
		temp[2] <= 30'd17;
		temp[3] <= 30'd25;
		temp[4] <= 30'd33;
		temp[5] <= 30'd41;
		
		next_step <= 1'b1;
		count <= 0;
		count2 <= 3'd4;
	end
	else begin
		case (step)
			3'b000:begin
				if(gray_valid) begin
					temp[gray_data[2:0] - 3'd1][22:16] <= temp[gray_data[2:0] - 3'd1][22:16] + 7'd1;
					count[2] <= 1'b1;
				end
				else if (count != 3'd0) begin
					step[0] <= 1'b1;
					CNT_valid <= 1'b1;
				end
			end
			3'b001:begin
				CNT_valid <= 1'b0;
				if(temp[count + 3'd1][22:16]>temp[count][22:16]||(temp[count + 3'd1][22:16]==temp[count][22:16] && temp[count + 3'd1][10:6] < temp[count][10:6])) begin
					temp[count] <= temp[count + 3'd1];
					temp[count + 3'd1] <= temp[count];
					count <= 3'd4;
				end
				else if (count != 3'd0) count <= count - 3'd1;
				else begin
					step[0] <= next_step;
					step[1] <= 1'b1;
					count <= 3'd4;
				end
			end
			3'b011:begin
				temp[count2][22:16] <= temp[count2][22:16] + temp[count2 + 3'd1][22:16];
				temp[count2][2:0] <= temp[count2][2:0] + temp[count2 + 3'd1][2:0];
				step[1] <= 1'b0;
				next_step <= (count2 == 3'd1)? 1'b0 : 1'b1;
				count2 <= count2 - 3'd1;
			end
			3'b010:begin
				temp[count2][11] <= 0;
				temp[count2 + 3'd1][11] <= 1'b1;
				temp[0][6] <= 1'b1;
				temp[1][6] <= 1'b1;
				temp[2][6] <= 1'b1;
				temp[3][6] <= 1'b1;
				temp[4][6] <= 1'b1;
				temp[5][6] <= 1'b1;
				count <= 3'd0;
				step[0] <= (count2 == 3'd4)?1'b1:1'b0;
				step[2] <= 1'b1;
			end
			3'b110:begin
				if(temp[count][2:0] != 3'd1) begin
					temp[count][2:0] <= temp[count][2:0] - temp[count2 + 3'd2][2:0];
					temp[count][22:16] <= temp[count][22:16] - temp[count2 + 3'd2][22:16];
					temp[count][15:11] <= temp[count][15:11] << 1;
					temp[count2 + 3'd2][15:11] <= temp[count][15:11] << 1;
					temp[count][10:6] <= temp[count][10:6] << 1;
					temp[count2 + 3'd2][10:6] <= temp[count][10:6] << 1;
					
					step <= 3'b001;
					next_step <= 1'b0;
					count2 <= count2 + 3'd1;
					count <= count2 + 3'd1;
				end
				else begin
					count <= count + 3'd1;
				end
			end
			3'b111:begin
 				temp[temp[0][5:3]] <= temp[0];
				temp[temp[1][5:3]] <= temp[1];
				temp[temp[2][5:3]] <= temp[2];
				temp[temp[3][5:3]] <= temp[3];
				temp[temp[4][5:3]] <= temp[4];
				temp[temp[5][5:3]] <= temp[5];				
				step[1] <= 1'b0;
			end
			3'b101:begin	
				code_valid <= 1'b1;
				step[0] <= 1'b0;
			end
			3'b100:begin
				code_valid <= 0;
			end
		endcase
	end
end
endmodule
 */
/* `timescale 1ns/10ps
module huffman ( clk, reset, gray_valid, gray_data, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);
input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output reg CNT_valid;
output [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output reg code_valid;
output [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output [7:0] M1, M2, M3, M4, M5, M6;


reg [2:0] step;
reg next_step;
reg [2:0] position [0:5];
reg [2:0] how_many [0:5];

reg [7:0] CNT_temp [0:5];
reg [7:0] M_temp [0:5];
reg [7:0] HC_temp [0:5];

reg [2:0] count,count2;

assign CNT1 = CNT_temp[0];
assign CNT2 = CNT_temp[1];
assign CNT3 = CNT_temp[2];
assign CNT4 = CNT_temp[3];
assign CNT5 = CNT_temp[4];
assign CNT6 = CNT_temp[5];
assign M1 = M_temp[0];
assign M2 = M_temp[1];
assign M3 = M_temp[2];
assign M4 = M_temp[3];
assign M5 = M_temp[4];
assign M6 = M_temp[5];
assign HC1 = HC_temp[0];
assign HC2 = HC_temp[1];
assign HC3 = HC_temp[2];
assign HC4 = HC_temp[3];
assign HC5 = HC_temp[4];
assign HC6 = HC_temp[5];

always @(posedge clk or posedge reset) begin
	if(reset) begin
		step <= 0;
		CNT_temp[1] <= 0;
		CNT_temp[2] <= 0;
		CNT_temp[3] <= 0;
		CNT_temp[4] <= 0;
		CNT_temp[5] <= 0;
		CNT_temp[0] <= 0;
		HC_temp[1] <= 0;
		HC_temp[2] <= 0;
		HC_temp[3] <= 0;
		HC_temp[4] <= 0;
		HC_temp[5] <= 0;
		HC_temp[0] <= 0;
		M_temp[0] <= 0;
		M_temp[1] <= 0;
		M_temp[2] <= 0;
		M_temp[3] <= 0;
		M_temp[4] <= 0;
		M_temp[5] <= 0;
		next_step <= 1'b1;
		position[0] <= 0;
		position[1] <= 3'd1;
		position[2] <= 3'd2;
		position[3] <= 3'd3;
		position[4] <= 3'd4;
		position[5] <= 3'd5;
		
		how_many[0] <= 3'd1;
		how_many[1] <= 3'd1;
		how_many[2] <= 3'd1;
		how_many[3] <= 3'd1;
		how_many[4] <= 3'd1;
		how_many[5] <= 3'd1;
		count <= 0;
		count2 <= 3'd4;
	end
	else begin
		case (step)
			3'b000:begin
				if(gray_valid) begin
					CNT_temp[gray_data[2:0] - 3'd1] <= CNT_temp[gray_data[2:0] - 3'd1] + 8'd1;
					count[2] <= 1'b1;
				end
				else if (count != 3'd0) begin
					step[0] <= 1'b1;
					CNT_valid <= 1'b1;
				end
			end
			3'b001:begin
				CNT_valid <= 1'b0;
				if(CNT_temp[count + 3'd1]>CNT_temp[count]||(CNT_temp[count + 3'd1]==CNT_temp[count] && M_temp[count + 3'd1] < M_temp[count])) begin
					CNT_temp[count] <= CNT_temp[count + 3'd1];
					CNT_temp[count + 3'd1] <= CNT_temp[count];
					position[count] <= position[count + 3'd1];
					position[count + 3'd1] <= position[count];
					how_many[count] <= how_many[count + 3'd1];
					how_many[count + 3'd1] <= how_many[count];
					HC_temp[count] <= HC_temp[count + 3'd1];
					HC_temp[count + 3'd1] <= HC_temp[count];
					M_temp[count] <= M_temp[count + 3'd1];
					M_temp[count + 3'd1] <= M_temp[count];
					count <= 3'd4;
				end
				else if (count != 3'd0) count <= count - 3'd1;
				else begin
					step[0] <= next_step;
					step[1] <= 1'b1;
					count <= 3'd4;
				end
			end
			3'b011:begin
				CNT_temp[count2] <= CNT_temp[count2] + CNT_temp[count2 + 3'd1];
				how_many[count2] <= how_many[count2] + how_many[count2 + 3'd1];
				step[1] <= 1'b0;
				next_step <= (count2 == 3'd1)? 1'b0 : 1'b1;
				count2 <= count2 - 3'd1;
			end
			3'b010:begin
				HC_temp[count2][0] <= 0;
				HC_temp[count2 + 3'd1][0] <= 1'b1;
				M_temp[1][0] <= 1'b1;
				M_temp[2][0] <= 1'b1;
				M_temp[3][0] <= 1'b1;
				M_temp[4][0] <= 1'b1;
				M_temp[5][0] <= 1'b1;
				M_temp[0][0] <= 1'b1;
				count <= 3'd0;
				step[0] <= (count2 == 3'd4)?1'b1:1'b0;
				step[2] <= 1'b1;
			end
			3'b110:begin
				if(how_many[count] != 3'd1) begin
					how_many[count] <= how_many[count] - how_many[count2 + 3'd2];
					CNT_temp[count] <= CNT_temp[count] - CNT_temp[count2 + 3'd2];
					
					HC_temp[count] <= HC_temp[count] << 1;
					HC_temp[count2 + 3'd2] <= HC_temp[count] << 1;
					M_temp[count] <= M_temp[count] << 1;
					M_temp[count2 + 3'd2] <= M_temp[count] << 1;
					
					step <= 3'b001;
					next_step <= 1'b0;
					count2 <= count2 + 3'd1;
					count <= count2 + 3'd1;
				end
				else begin
					count <= count + 3'd1;
				end
			end
			3'b111:begin
 				M_temp[position[0]] <= M_temp[0];
				M_temp[position[1]] <= M_temp[1];
				M_temp[position[2]] <= M_temp[2];
				M_temp[position[3]] <= M_temp[3];
				M_temp[position[4]] <= M_temp[4];
				M_temp[position[5]] <= M_temp[5];
				HC_temp[position[0]] <= HC_temp[0];
				HC_temp[position[1]] <= HC_temp[1];
				HC_temp[position[2]] <= HC_temp[2];
				HC_temp[position[3]] <= HC_temp[3];
				HC_temp[position[4]] <= HC_temp[4];
				HC_temp[position[5]] <= HC_temp[5];			
				step[1] <= 1'b0; 	
			end
			3'b101:begin	
				code_valid <= 1'b1;
				step[0] <= 1'b0;
			end
			3'b100:begin
				code_valid <= 0;
			end
		endcase
	end
end
endmodule */