module TPA(clk, reset_n, 
	   SCL, SDA, 
	   cfg_req, cfg_rdy, cfg_cmd, cfg_addr, cfg_wdata, cfg_rdata);
input clk; 
input reset_n;
// Two-Wire Protocol slave interface 
input SCL;  
inout SDA;

// Register Protocal Master interface 
input cfg_req;
output reg cfg_rdy;
input cfg_cmd;
input [7:0]cfg_addr;
input [15:0]cfg_wdata;
output reg [15:0]cfg_rdata;

reg	[15:0] Register_Spaces	[0:255];
reg [1:0] rim_step;
reg [5:0] twp_step;
reg [7:0] twp_addr;
reg [15:0] twp_wdata;
reg rim_write,twp_write;//讀還是寫
reg wait_state;//同時寫入
reg rim_first,twp_first;

assign SDA = (twp_step == 6'b011100||twp_step==6'b101111)?1:(twp_step == 6'b011110)?0:(twp_step > 6'b011110 && twp_step < 6'b101111)?twp_wdata[twp_step-31]:1'bz;

always @(posedge clk or negedge reset_n) begin
	if(!reset_n) begin
		cfg_rdy <= 0;
		cfg_rdata <= 0;
		
		rim_step <= 0;
		wait_state <= 0;
		twp_step <= 0;
		rim_write <= 0;
		twp_write <= 0;
		twp_addr <= 0;
		twp_wdata <= 0;
		rim_first <= 0;
		twp_first <= 0;
	end
	else begin
		case(rim_step)
			2'b00: begin
				if(cfg_req) begin
					rim_step <= rim_step+1;//指令觸發
					if(twp_step == 0 && SDA == 0) wait_state <= 1;
					else if(twp_step > 0) begin
						twp_first <= 1;
						rim_first <= 0;
					end
				end
			end
			2'b01:begin
				rim_write <= cfg_cmd;
				cfg_rdy <= 1;
				rim_step <= rim_step+1;
			end
			2'b10:begin
				if(rim_write) begin
					if (rim_first && (twp_step>9 && twp_step<27)) begin //rim 在前 檢查addr是否相同
						if(twp_addr != cfg_addr) begin
							Register_Spaces[twp_addr] <= twp_wdata;
						end
						rim_step <= rim_step + 1;
					end
					else if(wait_state == 0) begin
						Register_Spaces[cfg_addr] <= cfg_wdata;
						rim_step <= rim_step + 1;
					end
				end
				else begin
					cfg_rdata <= Register_Spaces[cfg_addr];
					rim_step <= rim_step + 1;
				end	
			end
			2'b11: begin
				cfg_rdy <= 0;
				rim_step <= rim_step + 1;
			end
		endcase
		case(twp_step)
			6'b000000: begin
				if(!SDA) begin
					twp_step <= twp_step + 1;//指令觸發
					if(rim_step > 0) begin
						twp_first <= 0;
						rim_first <= 1;
					end
				end
			end
			6'b000001: begin
				twp_write <= SDA;
				twp_step <= twp_step+1;			
			end
			6'b000010: begin
				twp_addr[0] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b000011: begin
				twp_addr[1] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b000100: begin
				twp_addr[2] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b000101: begin
				twp_addr[3] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b000110: begin
				twp_addr[4] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b000111: begin
				twp_addr[5] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b001000: begin
				twp_addr[6] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b001001: begin
				twp_addr[7] <= SDA;
				if(twp_write) twp_step <= twp_step+1;
				else twp_step <= 6'b011011;
			end
			6'b001010: begin
				twp_wdata[0] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b001011: begin
				twp_wdata[1] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b001100: begin
				twp_wdata[2] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b001101: begin
				twp_wdata[3] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b001110: begin
				twp_wdata[4] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b001111: begin
				twp_wdata[5] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b010000: begin
				twp_wdata[6] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b010001: begin
				twp_wdata[7] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b010010: begin
				twp_wdata[8] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b010011: begin
				twp_wdata[9] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b010100: begin
				twp_wdata[10] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b010101: begin
				twp_wdata[11] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b010110: begin
				twp_wdata[12] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b010111: begin
				twp_wdata[13] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b011000: begin
				twp_wdata[14] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b011001: begin
				twp_wdata[15] <= SDA;
				twp_step <= twp_step+1;	
			end
			6'b011010: begin		
				if(wait_state) begin //同時
					if(twp_addr != cfg_addr) begin
						Register_Spaces[twp_addr] <= twp_wdata;
					end
					wait_state <= 0;
				end
				else if (twp_first && rim_write) begin //twp 在前 檢查addr是否相同
					if(twp_addr != cfg_addr) begin
						Register_Spaces[twp_addr] <= twp_wdata;
					end
				end
				else Register_Spaces[twp_addr] <= twp_wdata;//twp在後 一定寫入
				twp_step <= 0;
			end
			6'b011011: begin
				twp_step <= twp_step+1;
			end
			6'b011100: begin
				//SDA <= 1;
				twp_step <= twp_step+1;
				twp_wdata <= Register_Spaces[twp_addr];
			end
			6'b011101: begin
				//SDA <= 0;
				twp_step <= twp_step+1;
			end
			6'b011110: begin
				//SDA <= twp_wdata[0];
				twp_step <= twp_step+1;
			end
			6'b011111: begin
				//SDA <= twp_wdata[1];
				twp_step <= twp_step+1;
			end
			6'b100000: begin
				//SDA <= twp_wdata[2];
				twp_step <= twp_step+1;
			end
			6'b100001: begin
				//SDA <= twp_wdata[3];
				twp_step <= twp_step+1;
			end
			6'b100010: begin
				//SDA <= twp_wdata[4];
				twp_step <= twp_step+1;
			end
			6'b100011: begin
				//SDA <= twp_wdata[5];
				twp_step <= twp_step+1;
			end
			6'b100100: begin
				//SDA <= twp_wdata[6];
				twp_step <= twp_step+1;
			end
			6'b100101: begin
				//SDA <= twp_wdata[7];
				twp_step <= twp_step+1;
			end
			6'b100110: begin
				//SDA <= twp_wdata[8];
				twp_step <= twp_step+1;
			end
			6'b100111: begin
				//SDA <= twp_wdata[9];
				twp_step <= twp_step+1;
			end
			6'b101000: begin
				//SDA <= twp_wdata[10];
				twp_step <= twp_step+1;
			end
			6'b101001: begin
				//SDA <= twp_wdata[11];
				twp_step <= twp_step+1;
			end
			6'b101010: begin
				//SDA <= twp_wdata[12];
				twp_step <= twp_step+1;
			end
			6'b101011: begin
				//SDA <= twp_wdata[13];
				twp_step <= twp_step+1;
			end
			6'b101100: begin
				//SDA <= twp_wdata[14];
				twp_step <= twp_step+1;
			end
			6'b101101: begin
				//SDA <= twp_wdata[15];
				twp_step <= twp_step+1;
			end
			6'b101110: begin
				//SDA <= 1;
				twp_step <= twp_step+1;
			end
			6'b101111: begin
				twp_step <= twp_step+1;
			end
			6'b110000: begin
				twp_step <= 0;
			end
		endcase
	end
end
endmodule
