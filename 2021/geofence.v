module geofence ( clk,reset,X,Y,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
output reg valid;
output reg is_inside;

reg signed [10:0] X_temp, Y_temp;
reg signed [10:0] X_buffer [5:0];
reg signed [10:0] Y_buffer [5:0];
reg [4:0] count;
reg signed [10:0] temp0,temp1,temp2,temp3;
reg signed [20:0] temp_reg;
wire signed [20:0] mul;

reg [2:0] cp;

assign mul = (temp0 - temp1) * (temp2 - temp3);

always@(posedge clk or posedge reset) begin

	if(reset) begin
		count <= 0;
		is_inside <= 0;
		valid <= 0;
		cp <= 0;
	end
	else begin
		case(count)
			0: begin
				X_temp <= X;
				Y_temp <= Y;
				count <= count+1;
			end
			1: begin
				X_buffer[0] <= X;
				Y_buffer[0] <= Y;
				count <= count+1;
			end
			2: begin
				X_buffer[1] <= X;
				Y_buffer[1] <= Y;
				count <= count+1;
			end
			3: begin
				X_buffer[2] <= X;
				Y_buffer[2] <= Y;
				count <= count+1;
			end
			4: begin
				X_buffer[3] <= X;
				Y_buffer[3] <= Y;
				count <= count+1;
			end
			5: begin
				X_buffer[4] <= X;
				Y_buffer[4] <= Y;
				count <= count+1;
			end
			6: begin
				X_buffer[5] <= X;
				Y_buffer[5] <= Y;
				count <= count+1;
			end
			7: begin
				count <= count+1;
				temp0 <= X_buffer[1];
				temp1 <= X_buffer[0];
				temp2 <= Y_buffer[2];
				temp3 <= Y_buffer[0];
			end
			8:begin
				temp_reg <= mul;
				temp0 <= Y_buffer[1];
				temp1 <= Y_buffer[0];
				temp2 <= X_buffer[2];
				temp3 <= X_buffer[0];
				count <= count+1;
			end
			9: begin
				if(temp_reg > mul) begin
					X_buffer[1] <= X_buffer[2];
					X_buffer[2] <= X_buffer[1];
					Y_buffer[1] <= Y_buffer[2];
					Y_buffer[2] <= Y_buffer[1];
					count <= 7;
				end
				else begin
					count <= count + 1;
					temp0 <= X_buffer[2];
					temp1 <= X_buffer[0];
					temp2 <= Y_buffer[3];
					temp3 <= Y_buffer[0];
				end
			end
			10: begin
				temp_reg <= mul;
				temp0 <= Y_buffer[2];
				temp1 <= Y_buffer[0];
				temp2 <= X_buffer[3];
				temp3 <= X_buffer[0];
				count <= count+1;				
			end
			11: begin
				if(temp_reg > mul) begin
					X_buffer[2] <= X_buffer[3];
					X_buffer[3] <= X_buffer[2];
					Y_buffer[2] <= Y_buffer[3];
					Y_buffer[3] <= Y_buffer[2];
					count <= 7;
				end
				else begin
					count <= count + 1;
					temp0 <= X_buffer[3];
					temp1 <= X_buffer[0];
					temp2 <= Y_buffer[4];
					temp3 <= Y_buffer[0];
				end
			end
			12: begin
				temp_reg <= mul;
				temp0 <= Y_buffer[3];
				temp1 <= Y_buffer[0];
				temp2 <= X_buffer[4];
				temp3 <= X_buffer[0];
				count <= count+1;						
			end
			13: begin
				if(temp_reg > mul) begin
					X_buffer[3] <= X_buffer[4];
					X_buffer[4] <= X_buffer[3];
					Y_buffer[3] <= Y_buffer[4];
					Y_buffer[4] <= Y_buffer[3];
					count <= 7;
				end
				else begin
					count <= count + 1;
					temp0 <= X_buffer[4];
					temp1 <= X_buffer[0];
					temp2 <= Y_buffer[5];
					temp3 <= Y_buffer[0];							
				end
			end
			14: begin
				temp_reg <= mul;
				temp0 <= Y_buffer[4];
				temp1 <= Y_buffer[0];
				temp2 <= X_buffer[5];
				temp3 <= X_buffer[0];
				count <= count+1;				
			end
			15: begin
				if(temp_reg > mul) begin
					X_buffer[4] <= X_buffer[5];
					X_buffer[5] <= X_buffer[4];
					Y_buffer[4] <= Y_buffer[5];
					Y_buffer[5] <= Y_buffer[4];
					count <= 7;
				end
				else begin
					count <= count + 1;
					temp0 <= X_buffer[0];
					temp1 <= X_temp;
					temp2 <= Y_buffer[1];
					temp3 <= Y_buffer[0];
				end
			end
			16: begin
				temp_reg <= mul;
				count <= count + 1;
				temp0 <= Y_buffer[0];
				temp1 <= Y_temp;
				temp2 <= X_buffer[1];
				temp3 <= X_buffer[0];
			end
			17:begin
				if (temp_reg > mul) begin
					cp <= cp + 1;
				end
				count <= count + 1;
				temp0 <= X_buffer[1];
				temp1 <= X_temp;
				temp2 <= Y_buffer[2];
				temp3 <= Y_buffer[1];
			end	
			18:begin
				temp_reg <= mul;
				count <= count + 1;
				temp0 <= Y_buffer[1];
				temp1 <= Y_temp;
				temp2 <= X_buffer[2];
				temp3 <= X_buffer[1];
			end
			19:begin
				if (temp_reg > mul) begin
					cp <= cp + 1;
				end
				count <= count + 1;
				temp0 <= X_buffer[2];
				temp1 <= X_temp;
				temp2 <= Y_buffer[3];
				temp3 <= Y_buffer[2];
			end
			20:begin
				temp_reg <= mul;
				count <= count + 1;
				temp0 <= Y_buffer[2];
				temp1 <= Y_temp;
				temp2 <= X_buffer[3];
				temp3 <= X_buffer[2];
			end
			21: begin
				if (temp_reg > mul) begin
					cp <= cp + 1;
				end
				count <= count + 1;
				temp0 <= X_buffer[3];
				temp1 <= X_temp;
				temp2 <= Y_buffer[4];
				temp3 <= Y_buffer[3];
			end
			22: begin
				temp_reg <= mul;
				count <= count + 1;
				temp0 <= Y_buffer[3];
				temp1 <= Y_temp;
				temp2 <= X_buffer[4];
				temp3 <= X_buffer[3];			
			end
			23: begin
				if (temp_reg > mul) begin
					cp <= cp + 1;
				end
				count <= count + 1;
				temp0 <= X_buffer[4];
				temp1 <= X_temp;
				temp2 <= Y_buffer[5];
				temp3 <= Y_buffer[4];			
			end
			24: begin
				temp_reg <= mul;
				count <= count + 1 ;
				temp0 <= Y_buffer[4];
				temp1 <= Y_temp;
				temp2 <= X_buffer[5];
				temp3 <= X_buffer[4];
			end
			25: begin
				if (temp_reg > mul) begin
					cp <= cp + 1;
				end
				count <= count + 1;
				temp0 <= X_buffer[5];
				temp1 <= X_temp;
				temp2 <= Y_buffer[0];
				temp3 <= Y_buffer[5];		
			end
			26:begin
				temp_reg <= mul;
				count <= count + 1 ;
				temp0 <= Y_buffer[5];
				temp1 <= Y_temp;
				temp2 <= X_buffer[0];
				temp3 <= X_buffer[5];
			end
			27:begin
				if (temp_reg > mul) begin
					cp <= cp + 1;
				end
				count <= count + 1;
			end
			28: begin
				if (cp == 6 || cp == 0) is_inside <= 1;
				else is_inside <= 0;
				valid <= 1;
				count <= count + 1;
			end
			29:begin
				valid <= 0;
				is_inside <= 0;
				count <= 0;	
				cp <= 0;				
			end
		endcase
	end

end

endmodule