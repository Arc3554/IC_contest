module STI_DAC(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
	       so_data, so_valid,
	       oem_finish, oem_dataout, oem_addr,
	       odd1_wr, odd2_wr, odd3_wr, odd4_wr, even1_wr, even2_wr, even3_wr, even4_wr);

input		clk, reset;
input		load, pi_msb, pi_low, pi_end; 
input	[15:0]	pi_data;
input	[1:0]	pi_length;
input		pi_fill;
output reg so_data, so_valid;

output reg oem_finish, odd1_wr, odd2_wr, odd3_wr, odd4_wr, even1_wr, even2_wr, even3_wr, even4_wr;
output reg [4:0] oem_addr;
output reg [7:0] oem_dataout;
reg [3:0] counter;
reg [5:0] length_counter;
reg [1:0] OE_flag;
reg [3:0] oe_counter;
reg temp,block,end_flag;

wire [2:0]test;
assign test = 3'd7-length_counter[2:0];

always@(*)begin
	if(&OE_flag && &oem_addr && block == 0) oem_finish = 1;
	else oem_finish = 0;
end

//==============================================================================
always@(posedge clk or posedge reset) begin
	if(reset) begin
		so_valid <= 0;
		length_counter <= 0;
		end_flag <= 0;
	end
	else begin
		if(load) begin
			if(pi_length == 2'b00) begin
				if(pi_msb)begin
					counter <= (pi_low)?15:7;
				end
				else begin
					counter <= (pi_low)?8:0;
				end
			end
			else begin
				if(pi_msb)begin
					counter <= 15;
				end
				else begin
					counter <= 0;
				end
			end
			length_counter <= 0;
		end
		else if (length_counter[5:3] == (pi_length+1))begin
			if(pi_end) end_flag<=1;
			so_valid <=0;
			length_counter <= 0;
		end
		else begin
			length_counter <= length_counter + 1;
			if(end_flag) begin
				so_data <= 0;
				oem_dataout <= 0;
				so_valid <= 1;
			end
			else begin
				so_valid <= 1;
				case(pi_length)
					2'b00:begin
						so_data <= pi_data[counter];
						oem_dataout[test] <= pi_data[counter];
						counter <= (pi_msb)?counter - 1:counter + 1;	
					end
					2'b01:begin
						so_data <= pi_data[counter];
						oem_dataout[test] <= pi_data[counter];
						counter <= (pi_msb)?counter - 1:counter + 1;	
					end
					2'b10:begin
						if(length_counter<8 &&  (pi_fill!=pi_msb))begin
							so_data <= 0;
							oem_dataout[test] <= 0;
						end
						else if(|length_counter[5:4] && (pi_fill==pi_msb))begin
							so_data <= 0;
							oem_dataout[test] <= 0;
						end
						else begin
							so_data <= pi_data[counter];
							oem_dataout[test] <= pi_data[counter];
							counter <= (pi_msb)?counter - 1:counter + 1;
						end
					end
					2'b11:begin
						if(length_counter<16 && (pi_fill!=pi_msb))begin
							so_data <= 0;
							oem_dataout[test] <= 0;
						end
						else if(|length_counter[5:4] &&(pi_fill ==pi_msb))begin
							so_data <= 0;
							oem_dataout[test] <= 0;
						end
						else begin
							so_data <= pi_data[counter];
							oem_dataout[test] <= pi_data[counter];
							counter <= (pi_msb)?counter - 1:counter + 1;
						end
					end
				endcase	
			end
		end
	end
end

always@(negedge clk or posedge reset) begin
	if(reset)begin
		odd1_wr <= 0;
		odd2_wr <= 0;
		odd3_wr <= 0;
		odd4_wr <= 0;
		even1_wr <= 0;
		even2_wr <= 0;
		even3_wr <= 0;
		even4_wr <= 0;
		oem_addr <= 0;
		block <= 0;
		OE_flag <= 0;
		oe_counter <= 0;
		temp<=0;
	end
	else begin
		
		if(|length_counter[2:0] ==0 && |length_counter != 0)begin
			case(OE_flag)
				2'b00:begin
					if(&oem_addr && block == 0)odd2_wr <= 1;
					else begin
						odd1_wr <= ~(oe_counter[3]^oe_counter[0]);
						even1_wr <= oe_counter[3]^oe_counter[0];
					end
				end
				2'b01:begin
					if(&oem_addr&& block == 0)odd3_wr <= 1;
					else begin
						odd2_wr <= ~(oe_counter[3]^oe_counter[0]);
						even2_wr <= oe_counter[3]^oe_counter[0];
					end
				end
				2'b10:begin
					if(&oem_addr&& block == 0)odd4_wr <= 1;
					else begin
						odd3_wr <= ~(oe_counter[3]^oe_counter[0]);
						even3_wr <= oe_counter[3]^oe_counter[0];
					end
				end
				2'b11:begin
					odd4_wr <= ~(oe_counter[3]^oe_counter[0]);
					even4_wr <= oe_counter[3]^oe_counter[0];
				end
			endcase
			block <= oe_counter[3]^oe_counter[0];
			
			if(oe_counter[0] == 0 && temp)begin
				{OE_flag,oem_addr} <= {OE_flag,oem_addr} + 1;
			end
			oe_counter <= oe_counter + 1;
			temp <= 1;
		end 
		else begin
			odd1_wr <= 0;
			odd2_wr <= 0;
			odd3_wr <= 0;
			odd4_wr <= 0;
			even1_wr <= 0;
			even2_wr <= 0;
			even3_wr <= 0;
			even4_wr <= 0;
		end
	end
end


endmodule
