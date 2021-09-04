module DT(
	input 			clk, 
	input			reset,
	output	reg		done ,
	output			sti_rd ,
	output	reg 	[9:0]	sti_addr ,
	input		[15:0]	sti_di,
	output	reg		res_wr ,
	output	reg		res_rd ,
	output	reg 	[13:0]	res_addr ,
	output	reg 	[7:0]	res_do,
	input		[7:0]	res_di
	);

reg [1:0] mode;
reg [3:0] step;
assign sti_rd = 1'b1;

always @(posedge clk or negedge reset) begin
	if (!reset) begin
		done <= 0;
		sti_addr <= 0;
		res_wr <= 1'b1 ;
		res_addr <= 14'd16383;
		res_do <= 0;
		
		mode <= 0;
		step <= 0;
	end
	else begin
		case (mode)
			2'b00:begin
				res_do[0] <= sti_di[4'd15-step];
				res_addr <= res_addr + 14'd1;
				step <= step + 4'd1;
				if (&step) sti_addr <= sti_addr + 10'd1;
				if((&sti_addr)&&(&step)) begin 
					mode <= mode+ 2'd1;
					res_wr<=0;
					res_rd <= 1'b1;
					res_addr <= 14'd129;
				end
			end
			2'b01:begin
				case (step[2:0])
					3'b000:begin
						if (res_addr == 14'd16255) mode <= mode + 2'd1;
						else if(res_di == 0) begin res_addr <= res_addr + 14'd1;res_do[4:0] <= 0;end
						else begin
							step[2:0] <= step[2:0] + 3'd1;
							res_addr <= res_addr - 14'd129;
						end				
					end
					3'b100:begin
						res_wr <= 0;
						step <= 0;
						res_addr <= res_addr + 14'd1;
					end
					default:begin //step 1~3
						step[2:0] <= step[2:0] + 3'd1;	
						if(step[2:0] == 3'b011) begin
							res_addr <= res_addr + 14'd127;
							res_do[4:0] <= (res_di[4:0] < res_do[4:0])? res_di[4:0]+5'd1:res_do[4:0]+5'd1;
							res_wr <= 1'b1;
						end
						else begin 
							res_addr <= res_addr + 14'd1;
							res_do[4:0] <= (res_di[4:0] < res_do[4:0])? res_di[4:0]:res_do[4:0];
						end
					end
					
				endcase//res_addr = 16255
			end
			2'b10: begin
				case (step[2:0])
					3'b000:begin
						if (res_addr == 14'd128) done <= 1'b1;
						else if(res_di == 0) begin res_addr <= res_addr - 14'd1; res_do[4:0] <= 0;end
						else begin
							res_do[4:0] <= (res_di[4:0] < res_do[4:0] + 5'd1)? res_di[4:0]:res_do[4:0]+5'd1;
							step[2:0] <= step[2:0] + 3'd1;
							res_addr <= res_addr + 14'd129;
						end
					end
					3'b100: begin
						res_wr <= 0;
						step <= 0;
						res_addr <= res_addr - 14'd1;
					end
					default:begin //step 1~3
						res_do[4:0] <= (res_di[4:0] + 5'd1 < res_do[4:0])? res_di[4:0]+5'd1:res_do[4:0];
						step[2:0] <= step[2:0] + 3'd1;	
						if(step[2:0] == 3'b011) begin 
							res_addr <= res_addr - 14'd127;
							res_wr <= 1'b1; 
						end
						else res_addr <= res_addr - 14'd1;
					end
				endcase
			end
		endcase
	end
end
endmodule