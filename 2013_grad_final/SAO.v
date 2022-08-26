`timescale 1ns/10ps

module SAO ( clk, reset, in_en, din, sao_type, sao_band_pos, sao_eo_class, sao_offset, lcu_x, lcu_y, lcu_size, busy, finish);
input   clk;
input   reset;
input   in_en;
input   [7:0]  din;
input   [1:0]  sao_type;
input   [4:0]  sao_band_pos;
input          sao_eo_class;
input   [15:0] sao_offset;
input   [2:0]  lcu_x;
input   [2:0]  lcu_y;
input   [1:0]  lcu_size;
output  reg busy;
output  reg finish;

reg [11:0] position,next_position;//(y,x)(64,64)
reg [13:0] position_out;
reg [1:0] state;
reg wen;
wire [7:0] data_out;
reg [7:0] data_in;
reg [7:0] data_input;
reg [3:0] sao_offset_4part;
reg [7:0] data_in_buffer [127:0],last_buf;

reg flag_neg;
reg up,down,left,right;

wire up_down;
wire left_right;
assign up_down = up&&down;
assign left_right = left&&right;

reg [8:0] data_in_BOEO;
reg [7:0] wait_counter;
reg pre_flag;
reg wait_done;
wire cen;
assign cen = 1'b0;

	sram_16384x8 golden_sram(.Q(data_out), .CLK(clk), .CEN(cen), .WEN(wen), .A(position_out), .D(data_in)); 

always@(*) begin
	data_input = (in_en)?din:last_buf;
	if(sao_type == 0 || sao_type == 1) wait_done = 1;
	else begin
		if(sao_eo_class == 0 && wait_counter >= 1) wait_done = 1;
		else if(sao_eo_class) begin
			case(lcu_size)
				0:begin
					if(wait_counter >= 16) wait_done = 1;
					else wait_done = 0;
				end
				1:begin
					if(wait_counter >= 32) wait_done = 1;
					else wait_done = 0;
				end
				default:begin
					if(wait_counter >= 64) wait_done = 1;
					else wait_done = 0;
				end
			endcase
		end
		else wait_done = 0;
	end
	
	next_position = position + 1;
	case(lcu_size)
		0:begin
			position_out = {lcu_y[2:0],position[7:4],lcu_x[2:0],position[3:0]};
			if(next_position[3:0] == 4'b1111) right = 0;
			else right = 1;
			if(next_position[3:0]==4'b0000) left = 0;
			else left = 1;
			if(next_position[7:4] == 4'b1111) down = 0;
			else down = 1;
			if(next_position[7:4]==4'b0000) up = 0;
			else up = 1;
		end
		1:begin
			position_out = {lcu_y[1:0],position[9:5],lcu_x[1:0],position[4:0]};
			if(next_position[4:0] == 5'b11111) right = 0;
			else right = 1;
			if(next_position[4:0]==5'b00000) left = 0;
			else left = 1;
			if(next_position[9:5] == 5'b11111) down = 0;
			else down = 1;
			if(next_position[9:5]==5'b00000) up = 0;
			else up = 1;
		end
		default:begin
			position_out = {lcu_y[0],position[11:6],lcu_x[0],position[5:0]};
			if(next_position[5:0] == 6'b111111) right = 0;
			else right = 1;
			if(next_position[5:0]==6'b000000) left = 0;
			else left = 1;
			if(next_position[11:6] == 6'b111111) down = 0;
			else down = 1;
			if(next_position[11:6]==6'b000000) up = 0;
			else up = 1;
		end
	endcase
	
	case(sao_type)
		0:begin		
			sao_offset_4part = 0;
			flag_neg = 0;
			data_in_BOEO = 0;
		end
		1:begin
			if(data_input[7:3] == sao_band_pos) begin
				sao_offset_4part = (sao_offset[15])?(~sao_offset[15:12]+1):sao_offset[15:12];
				flag_neg = sao_offset[15];
			end
			else if(data_input[7:3] == sao_band_pos + 1) begin
				sao_offset_4part = (sao_offset[11])?(~sao_offset[11:8]+1):sao_offset[11:8];
				flag_neg = sao_offset[11];
			end
			else if(data_input[7:3] == sao_band_pos + 2) begin
				sao_offset_4part = (sao_offset[7])?(~sao_offset[7:4]+1):sao_offset[7:4];
				flag_neg = sao_offset[7];
			end
			else if(data_input[7:3] == sao_band_pos + 3) begin
				sao_offset_4part = (sao_offset[3])?(~sao_offset[3:0]+1):sao_offset[3:0];
				flag_neg = sao_offset[3];
			end
			else begin
				sao_offset_4part = 0;
				flag_neg = 0;
			end
			data_in_BOEO = (flag_neg)?data_input - sao_offset_4part:data_input + sao_offset_4part;
		end
		default:begin
			if(sao_eo_class) begin
				case(lcu_size)
					0:begin
						if(data_in_buffer[16]<data_in_buffer[0]&&data_in_buffer[16]<data_input) begin
							sao_offset_4part = (sao_offset[15])?(~sao_offset[15:12]+1):sao_offset[15:12];
							flag_neg = sao_offset[15];
						end
						else if ((data_in_buffer[16]<data_in_buffer[0] && data_in_buffer[16]==data_input)||(data_in_buffer[16]==data_in_buffer[0] && data_in_buffer[16]<data_input)) begin
							sao_offset_4part = (sao_offset[11])?(~sao_offset[11:8]+1):sao_offset[11:8];
							flag_neg = sao_offset[11];
						end
						else if ((data_in_buffer[16]>data_in_buffer[0] && data_in_buffer[16]==data_input)||(data_in_buffer[16]==data_in_buffer[0] && data_in_buffer[16]>data_input)) begin
							sao_offset_4part = (sao_offset[7])?(~sao_offset[7:4]+1):sao_offset[7:4];
							flag_neg = sao_offset[7];
						end
						else if(data_in_buffer[16]>data_in_buffer[0]&&data_in_buffer[16]>data_input) begin
							sao_offset_4part = (sao_offset[3])?(~sao_offset[3:0]+1):sao_offset[3:0];
							flag_neg = sao_offset[3];
						end
						else begin
							sao_offset_4part = 0;
							flag_neg = 0;
						end
						data_in_BOEO = (flag_neg)?data_in_buffer[16] - sao_offset_4part:data_in_buffer[16] + sao_offset_4part;
					end
					1:begin
						if(data_in_buffer[32]<data_in_buffer[0]&&data_in_buffer[32]<data_input) begin
							sao_offset_4part = (sao_offset[15])?(~sao_offset[15:12]+1):sao_offset[15:12];
							flag_neg = sao_offset[15];
						end
						else if ((data_in_buffer[32]<data_in_buffer[0] && data_in_buffer[32]==data_input)||(data_in_buffer[32]==data_in_buffer[0] && data_in_buffer[32]<data_input)) begin
							sao_offset_4part = (sao_offset[11])?(~sao_offset[11:8]+1):sao_offset[11:8];
							flag_neg = sao_offset[11];
						end
						else if ((data_in_buffer[32]>data_in_buffer[0] && data_in_buffer[32]==data_input)||(data_in_buffer[32]==data_in_buffer[0] && data_in_buffer[32]>data_input)) begin
							sao_offset_4part = (sao_offset[7])?(~sao_offset[7:4]+1):sao_offset[7:4];
							flag_neg = sao_offset[7];
						end
						else if(data_in_buffer[32]>data_in_buffer[0]&&data_in_buffer[32]>data_input) begin
							sao_offset_4part = (sao_offset[3])?(~sao_offset[3:0]+1):sao_offset[3:0];
							flag_neg = sao_offset[3];
						end
						else begin
							sao_offset_4part = 0;
							flag_neg = 0;
						end
						data_in_BOEO = (flag_neg)?data_in_buffer[32] - sao_offset_4part:data_in_buffer[32] + sao_offset_4part;
					end
					default:begin
						if(data_in_buffer[64]<data_in_buffer[0]&&data_in_buffer[64]<data_input) begin
							sao_offset_4part = (sao_offset[15])?(~sao_offset[15:12]+1):sao_offset[15:12];
							flag_neg = sao_offset[15];
						end
						else if ((data_in_buffer[64]<data_in_buffer[0] && data_in_buffer[64]==data_input)||(data_in_buffer[64]==data_in_buffer[0] && data_in_buffer[64]<data_input)) begin
							sao_offset_4part = (sao_offset[11])?(~sao_offset[11:8]+1):sao_offset[11:8];
							flag_neg = sao_offset[11];
						end
						else if ((data_in_buffer[64]>data_in_buffer[0] && data_in_buffer[64]==data_input)||(data_in_buffer[64]==data_in_buffer[0] && data_in_buffer[64]>data_input)) begin
							sao_offset_4part = (sao_offset[7])?(~sao_offset[7:4]+1):sao_offset[7:4];
							flag_neg = sao_offset[7];
						end
						else if(data_in_buffer[64]>data_in_buffer[0]&&data_in_buffer[64]>data_input) begin
							sao_offset_4part = (sao_offset[3])?(~sao_offset[3:0]+1):sao_offset[3:0];
							flag_neg = sao_offset[3];
						end
						else begin
							sao_offset_4part = 0;
							flag_neg = 0;
						end
						data_in_BOEO = (flag_neg)?data_in_buffer[64] - sao_offset_4part:data_in_buffer[64] + sao_offset_4part;
					end
				endcase
			end
			else begin
				if(data_in_buffer[1]<data_in_buffer[0]&&data_in_buffer[1]<data_input) begin
					sao_offset_4part = (sao_offset[15])?(~sao_offset[15:12]+1):sao_offset[15:12];
					flag_neg = sao_offset[15];
				end
				else if ((data_in_buffer[1]<data_in_buffer[0] && data_in_buffer[1]==data_input)||(data_in_buffer[1]==data_in_buffer[0] && data_in_buffer[1]<data_input)) begin
					sao_offset_4part = (sao_offset[11])?(~sao_offset[11:8]+1):sao_offset[11:8];
					flag_neg = sao_offset[11];
				end
				else if ((data_in_buffer[1]>data_in_buffer[0] && data_in_buffer[1]==data_input)||(data_in_buffer[1]==data_in_buffer[0] && data_in_buffer[1]>data_input)) begin
					sao_offset_4part = (sao_offset[7])?(~sao_offset[7:4]+1):sao_offset[7:4];
					flag_neg = sao_offset[7];
				end
				else if(data_in_buffer[1]>data_in_buffer[0]&&data_in_buffer[1]>data_input) begin
					sao_offset_4part = (sao_offset[3])?(~sao_offset[3:0]+1):sao_offset[3:0];
					flag_neg = sao_offset[3];
				end
				else begin
					sao_offset_4part = 0;
					flag_neg = 0;
				end
				
				data_in_BOEO = (flag_neg)?data_in_buffer[1] - sao_offset_4part:data_in_buffer[1] + sao_offset_4part;
			end
		end
	endcase
	
end

always@(posedge clk) begin
	if(state == 0)begin
		if(wait_done) begin
			if(lcu_size == 0) begin
				position[11:8] <= 4'b1111;
				position[7:0] <= position[7:0] + 1;
			end
			else if (lcu_size == 1) begin
				position[11:10] <= 2'b11;
				position[9:0] <= position[9:0] + 1;
			end
			else position <= position + 1;
		end
	end
	else if(state == 2) position <= 12'b1111_1111_1111;
end

integer i;

always@(posedge clk or posedge reset) begin
	if(reset) begin
		busy <= 0;
		state <= 2;
		pre_flag <= 0;
		finish <= 0;
	end
	else begin
		case(state)
			0:begin //load_data
				if(position == 12'd4093 - (wait_counter>>1)) begin
					busy <= 1;
					pre_flag <= 1;
				end
				else if(&position && pre_flag) begin			
					state <= 1;
					pre_flag <= 0;
					wen <= 1;
				end
				else wen <= 0;
				last_buf <= data_input;
				
				case(sao_type)
					0:begin
						data_in <= data_input;
					end
					1:begin
						if(data_in_BOEO[8]) begin
							if(flag_neg) begin
								data_in <= 0;
							end
							else begin
								data_in <= 8'd255;
							end
						end
						else begin
							data_in <= data_in_BOEO[7:0];
						end
					end
					
 					2:begin
						if(sao_eo_class) begin
							case(lcu_size)
								0:begin
									if(wait_counter!=32) begin
										wait_counter <= wait_counter + 1;
									end
									if(up_down==0) begin
										data_in <= data_in_buffer[16];
									end
									else if(wait_done)begin
										if(data_in_BOEO[8]) begin
											if(flag_neg) begin
												data_in <= 0;
											end
											else begin
												data_in <= 8'd255;
											end
										end
										else begin
											data_in <= data_in_BOEO[7:0];
										end
									end
									for(i=0;i<31;i=i+1)begin
										data_in_buffer[i] <= data_in_buffer[i+1];
									end
									data_in_buffer[31] <= data_input;
								end
								1:begin
									if(wait_counter!=64) begin
										wait_counter <= wait_counter + 1;
									end
									if(up_down==0) begin
										data_in <= data_in_buffer[32];
									end
									else if(wait_done)begin
										if(data_in_BOEO[8]) begin
											if(flag_neg) begin
												data_in <= 0;
											end
											else begin
												data_in <= 8'd255;
											end
										end
										else begin
											data_in <= data_in_BOEO[7:0];
										end
									end
									for(i=0;i<63;i=i+1)begin
										data_in_buffer[i] <= data_in_buffer[i+1];
									end
									data_in_buffer[63] <= data_input;
								end
								2:begin
									if(wait_counter!=128) begin
										wait_counter <= wait_counter + 1;
									end
									if(up_down==0) begin
										data_in <= data_in_buffer[64];
									end
									else if(wait_done)begin
										if(data_in_BOEO[8]) begin
											if(flag_neg) begin
												data_in <= 0;
											end
											else begin
												data_in <= 8'd255;
											end
										end
										else begin
											data_in <= data_in_BOEO[7:0];
										end
									end
									for(i=0;i<127;i=i+1)begin
										data_in_buffer[i] <= data_in_buffer[i+1];
									end
									data_in_buffer[127] <= data_input;
								end
							endcase
						end
						else begin
							if(wait_counter!=2) begin
								wait_counter <= wait_counter + 1;
								
							end
							if(left_right==0) begin
								data_in <= data_in_buffer[1];
							end
							else begin
								if(data_in_BOEO[8]) begin
									if(flag_neg) begin
										data_in <= 0;
									end
									else begin
										data_in <= 8'd255;
									end
								end
								else begin
									data_in <= data_in_BOEO[7:0];
								end
							end
							data_in_buffer[0] <= data_in_buffer[1];
							data_in_buffer[1] <= data_input;
						end
					end 
				endcase
				
			end
			1:begin //檢查是否結束
				state <= 2;					
				busy <= 0;
				
				case(lcu_size)
					0:begin
						if(lcu_x == 7 && lcu_y == 7) finish <= 1;
					end
					1:begin
						if(lcu_x == 3 && lcu_y == 3) finish <= 1;
					end
					default:begin
						if(lcu_x == 1 && lcu_y == 1) finish <= 1;				
					end
				endcase
			end
			2:begin
				state <= 0;
				wait_counter <= 0;
			end
		endcase
	end
end
endmodule
