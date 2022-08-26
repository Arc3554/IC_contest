`timescale 1ns/10ps
module LEDDC( DCK, DAI, DEN, GCK, Vsync, mode, rst, OUT);
input           DCK;
input           DAI;
input           DEN;
input           GCK;
input           Vsync;
input           mode;
input           rst;
output reg [15:0]   OUT;

reg [4:0] D_count;
reg [15:0] D_in_sram_data;
reg [7:0] D_in_sram_addr;
reg [7:0] G_out_reg [15:0];
reg [7:0] S_in_sram_addr;
reg toggle_bit;
reg [1:0] G_state;
reg [15:0] counter;
wire [15:0] D_out_sram_data;
reg D_CEN,round;
sram_512x16 sram(.QA(D_out_sram_data),.AA({!toggle_bit,S_in_sram_addr}),.CLKA(GCK),.CENA(1'b0),.AB({toggle_bit,D_in_sram_addr}),.DB(D_in_sram_data),.CLKB(DCK),.CENB(D_CEN)); //A:read B:write

integer i;

always@(posedge DCK or posedge rst) begin
	if(rst) begin
		D_count <= 0;
		D_in_sram_addr <= 8'b11111111;
		toggle_bit <= 0;
		D_CEN <= 1;
	end
	else begin
		if(DEN) begin
			if(D_count[4] == 0) begin
				D_in_sram_data[D_count[2:0]] <= DAI;
			end
			else begin
				D_in_sram_data[{1'b1,D_count[2:0]}] <= DAI;
			end
			
			D_count <= D_count + 1;
			
			if(&D_count) begin
				D_in_sram_addr <= D_in_sram_addr + 1;
				D_CEN <= 0;
			end
		end
		else begin
			if (D_CEN == 0 && D_count == 0) begin
				if(&D_in_sram_addr)toggle_bit <= ~toggle_bit;
			end
			D_CEN <= 1;
		end
	end
end

always@(posedge GCK or posedge rst) begin
	if(rst) begin
		S_in_sram_addr <= 0;
		G_state <= 0;
		round <= 1;
		counter <= 0;
	end
	else begin
		if(Vsync) begin
			case(G_state)
				0:begin
					G_state <= G_state + 1;
					S_in_sram_addr <= S_in_sram_addr + 1;
				end
				1:begin
					G_out_reg[(counter[3:0]<<1)+1] <= D_out_sram_data[15:8];
					G_out_reg[counter[3:0]<<1] <= D_out_sram_data[7:0];
					counter[3:0] <= counter[3:0] + 1;
					if(counter[3:0] == 7) begin
						G_state <= G_state + 1;
						counter <= 0;
					end
					else S_in_sram_addr <= S_in_sram_addr + 1;
				end
				2:begin
					for(i=0;i<16;i=i+1) begin
						OUT[i] <= (counter >= ({G_out_reg[i],G_out_reg[i]}>>mode)+(G_out_reg[i][0]&round&mode))?0:1;
					end
					counter <= counter + 1;
				end
			endcase
		end
		else begin
			G_state <= 0;
			counter <= 0;
			if(counter != 0) begin
				round <= (!S_in_sram_addr)?~round:round;
			end
		end
	end
end

endmodule
