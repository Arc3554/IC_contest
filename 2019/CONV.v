  `timescale 1ns/10ps

module  CONV(
	input		clk,
	input		reset,
	output reg	busy,	
	input		ready,	
			
	output reg [11:0] iaddr,
	input [19:0] idata,	
	
	output reg	cwr,
	output reg [11:0] caddr_wr,
	output reg [19:0] cdata_wr,
	
	output reg	crd,
	output reg [11:0] caddr_rd,
	input [19:0] cdata_rd,
	
	output reg [2:0] csel
	);

reg [11:0] position;//y ,x
reg [3:0]  step;

reg [39:0] temp_all;
reg flag,done_0;
reg [19:0] temp1;
wire [39:0] mul;
wire left,right,up,down;

assign mul = idata * temp1;
assign left = (|position[5:0]==0)?1:0;
assign right = (&position[5:0])?1:0;
assign up = (position < 64)?1:0;
assign down = (position>4031)?1:0;


always @(posedge clk or posedge reset) begin
	if (reset) begin
		busy <= 0;
		iaddr <= 0;
		cwr <= 0;
		caddr_wr <= 12'b111111111111;
		cdata_wr <= 0;
		crd <= 0;
		caddr_rd <= 0;
		csel <= 0;

		position <= 0;
		step <= 0;
		flag <= 0;
		done_0 <= 0;
		temp_all <= 0;
	end
	else begin
		if (ready == 1) begin
			busy <= 1;
		end
		else begin
			if (done_0 == 0) begin
				case (step)
					4'b0000: begin 
						if (!flag) begin
							if(left||up) begin step <= step +1; end
							else begin 
								iaddr <= position-12'd65;
								flag <= 1;
								temp1 <= 20'h0A89E;
							end
						end
						else begin
							temp_all <= temp_all + mul;
							flag <= 0;
							step <= step +1;
						end
					end
					4'b0001: begin				
						if (!flag) begin
							if(up) begin step <= step +1; end
							else begin
								iaddr <= position-12'd64;
								flag <= 1;
								temp1 <= 20'h092D5;
							end
						end
						else begin
							temp_all <= temp_all + mul;
							flag <= 0;
							step <= step +1;
						end
					end
					4'b0010: begin 
						if (!flag) begin
							if(up||right) begin step <= step +1; end
							else begin 
								iaddr <= position-12'd63;
								flag <= 1;
								temp1 <= 20'h06D43;
							end
						end
						else begin
							temp_all <= temp_all + mul;
							flag <= 0;
							step <= step +1;
						end
					end
					4'b0011: begin 
						if (!flag) begin
							if(left) begin step <= step +1; end
							else begin 
								iaddr <= position-12'd1;
								flag <= 1;
								temp1 <= 20'h01004;
							end
						end
						else begin
							temp_all <= temp_all + mul;
							flag <= 0;
							step <= step +1;
						end
					end
					4'b0100: begin 
						if (!flag) begin
							iaddr <= position;
							flag <= 1;
							temp1 <= 20'h0708F;
						end
						else begin
							temp_all <= temp_all - mul;
							flag <= 0;
							step <= step +1;
						end
					end
					4'b0101: begin 
						if (!flag) begin
							if(right) begin step <= step +1; end
							else begin 
								iaddr <= position+12'd1;
								flag <= 1;
								temp1 <= 20'h091AC;
							end
						end
						else begin
							temp_all <= temp_all - mul;
							flag <= 0;
							step <= step +1;
						end
					end
					4'b0110: begin 
						if (!flag) begin
							if(left||down) begin step <= step +1; end
							else begin 
								iaddr <= position+12'd63;
								flag <= 1;
								temp1 <= 20'h05929;
							end
						end
						else begin
							temp_all <= temp_all - mul;
							flag <= 0;
							step <= step +1;
						end
					end
					4'b0111: begin 
						if (!flag) begin
							if(down) begin step <= step +1; end
							else begin 
								iaddr <= position+12'd64;
								flag <= 1;
								temp1 <= 20'h037CC;
							end
						end
						else begin
							temp_all <= temp_all - mul;
							flag <= 0;
							step <= step +1;
						end
					end
					4'b1000: begin 
						if (!flag) begin
							if(down||right) begin step <= step +1; end
							else begin 
								iaddr <= position+12'd65;
								flag <= 1;
								temp1 <= 20'h053E7;
							end
						end
						else begin
							temp_all <= temp_all - mul;
							flag <= 0;
							step <= step +1;
						end
					end
					4'b1001: begin
						temp_all <= temp_all + 40'h0013100000;
						step <= step +1;
					end
					4'b1010: begin 
						cdata_wr <= (temp_all[39]==1)? 0 :
									(temp_all[15]==1)? temp_all[35:16] + 1 : temp_all[35:16];
						step <= 0;
						caddr_wr <= caddr_wr + 1;
						csel <= 3'b001;
						cwr <= 1;
						temp_all <= 0;
						if (position == 12'd4095) done_0 <= 1;
						position <= position +1;
					end
				endcase
			end
			else begin
				if (!flag) begin
					flag <= 1;
					caddr_wr <= 12'b111111111111;
					cdata_wr <= 0;
					csel <= 0;
					cwr <= 0;
					crd <= 1;
					temp_all <= 0;
				end
				else begin
					case (step[2:0])
						3'b000: begin 	
							csel <= 3'b001;
							caddr_rd <= position;
							cwr <= 0;
							step <= step +1;
						end
						3'b001: begin
							temp_all <= cdata_rd;
							step <= step +1;
							caddr_rd <= position+12'd1;
						end
						3'b010: begin 				
							temp_all <= (cdata_rd > temp_all)? cdata_rd :temp_all;
							step <= step +1;
							caddr_rd <= position+12'd64;
						end
						3'b011: begin
							temp_all <= (cdata_rd > temp_all)? cdata_rd :temp_all;
							step <= step +1;
							caddr_rd <= position+12'd65;
						end
						3'b100: begin	
							cdata_wr <= (cdata_rd > temp_all)? cdata_rd:temp_all;
							csel <= 3'b011;
							cwr <= 1;
							caddr_wr <= caddr_wr + 1;
							if (position == 12'd4030) step <= step + 1;
							else if (position[5:0]==6'd62) begin position <= position + 12'd66; step <= 0;end
							else begin position <= position + 12'd2; step <= 0; end
						end
						3'b101: begin
							busy <= 0;
						end
					endcase
				end		
			end
		end
	end
end

endmodule




