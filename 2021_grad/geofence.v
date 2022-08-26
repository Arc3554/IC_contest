module geofence ( clk,reset,X,Y,R,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
input [10:0] R;
output reg valid;
output reg is_inside;

reg [5:0]  state,next_state;
reg [9:0]  X_buffer [5:0];
reg [9:0]  Y_buffer [5:0];
reg [10:0] R_buffer [5:0];
reg signed [20:0] mul_reg;

reg  [9:0] temp0,temp3;
reg  [10:0] temp1,temp2;
wire signed [10:0] mul_a,mul_b;
wire signed [20:0] mul;
wire [9:0] S; //理論上要12
reg [9:0] S_reg;//存s與前半更號
assign mul_a = temp0 - temp1;
assign mul_b = temp2 - temp3;
wire bigger_flag;

assign mul = mul_a * mul_b;

assign bigger_flag = (mul_reg < mul)?1'b1:0;//逆時鐘

assign S = (temp0+temp1+temp2)>>1;

wire [19:0] sqrt_in;//應該要21
wire [9:0] sqrt_out;

reg [21:0] area_reg,area_all_reg,next_area_all,next_area_reg;//應該要23


assign sqrt_in = mul + mul_reg;
DW_sqrt_inst m_sqrt_inst_1(sqrt_in, sqrt_out);


always@(*) begin
	if(state == 8 || state == 10 || state == 12 || state == 14) begin
		if (bigger_flag) next_state = 6;
		else next_state = state + 1;
	end
	else begin
		next_state = state + 1;
	end
	
	if (&state) begin
		valid = 1;
	end
	else valid = 0;
	
	if(area_all_reg < area_reg) begin
		is_inside = 0;
	end
	else begin
		is_inside = 1;
	end
	
	next_area_all = (state > 56)? area_all_reg - mul : area_all_reg + mul;
	next_area_reg = area_reg + mul;
end

always@(posedge clk or posedge reset) begin
	if(reset) begin
		state <= 0;
	end
	else begin
		state <= next_state;
	end
end

always@(posedge clk or posedge reset) begin
	if(reset) begin
		area_reg <= 0;
		area_all_reg <= 0;
	end
	else begin
		case(state)
			0:begin
				X_buffer[0] <= X;
				Y_buffer[0] <= Y;
				R_buffer[0] <= R;
			end
			1:begin
				X_buffer[1] <= X;
				Y_buffer[1] <= Y;
				R_buffer[1] <= R;
			end
			2:begin
				X_buffer[2] <= X;
				Y_buffer[2] <= Y;
				R_buffer[2] <= R;
			end
			3:begin
				X_buffer[3] <= X;
				Y_buffer[3] <= Y;
				R_buffer[3] <= R;
			end
			4:begin
				X_buffer[4] <= X;
				Y_buffer[4] <= Y;
				R_buffer[4] <= R;
			end
			5:begin
				X_buffer[5] <= X;
				Y_buffer[5] <= Y;
				R_buffer[5] <= R;
			end
			6: begin
				temp0 <= X_buffer[1];
				temp1 <= X_buffer[0];
				temp2 <= Y_buffer[2];
				temp3 <= Y_buffer[0];
			end
			7:begin
				mul_reg <= mul;
				temp0 <= Y_buffer[1];
				temp1 <= Y_buffer[0];
				temp2 <= X_buffer[2];
				temp3 <= X_buffer[0];
			end
			8: begin
				if(bigger_flag) begin
					X_buffer[1] <= X_buffer[2];
					X_buffer[2] <= X_buffer[1];
					Y_buffer[1] <= Y_buffer[2];
					Y_buffer[2] <= Y_buffer[1];
					R_buffer[1] <= R_buffer[2];
					R_buffer[2] <= R_buffer[1];
				end
				temp0 <= X_buffer[2];
				temp1 <= X_buffer[0];
				temp2 <= Y_buffer[3];
				temp3 <= Y_buffer[0];
			end
			9: begin
				mul_reg <= mul;
				temp0 <= Y_buffer[2];
				temp1 <= Y_buffer[0];
				temp2 <= X_buffer[3];
				temp3 <= X_buffer[0];				
			end
			10: begin
				if(bigger_flag) begin
					X_buffer[2] <= X_buffer[3];
					X_buffer[3] <= X_buffer[2];
					Y_buffer[2] <= Y_buffer[3];
					Y_buffer[3] <= Y_buffer[2];
					R_buffer[2] <= R_buffer[3];
					R_buffer[3] <= R_buffer[2];
				end
				temp0 <= X_buffer[3];
				temp1 <= X_buffer[0];
				temp2 <= Y_buffer[4];
				temp3 <= Y_buffer[0];
			end
			11: begin
				mul_reg <= mul;
				temp0 <= Y_buffer[3];
				temp1 <= Y_buffer[0];
				temp2 <= X_buffer[4];
				temp3 <= X_buffer[0];					
			end
			12: begin
				if(bigger_flag) begin
					X_buffer[3] <= X_buffer[4];
					X_buffer[4] <= X_buffer[3];
					Y_buffer[3] <= Y_buffer[4];
					Y_buffer[4] <= Y_buffer[3];
					R_buffer[3] <= R_buffer[4];
					R_buffer[4] <= R_buffer[3];
				end
				temp0 <= X_buffer[4];
				temp1 <= X_buffer[0];
				temp2 <= Y_buffer[5];
				temp3 <= Y_buffer[0];							
			end
			13: begin
				mul_reg <= mul;
				temp0 <= Y_buffer[4];
				temp1 <= Y_buffer[0];
				temp2 <= X_buffer[5];
				temp3 <= X_buffer[0];			
			end
			14: begin
				if(bigger_flag) begin
					X_buffer[4] <= X_buffer[5];
					X_buffer[5] <= X_buffer[4];
					Y_buffer[4] <= Y_buffer[5];
					Y_buffer[5] <= Y_buffer[4];
					R_buffer[4] <= R_buffer[5];
					R_buffer[5] <= R_buffer[4];
				end
				temp0 <= X_buffer[0];
				temp1 <= X_buffer[1];
				temp2 <= X_buffer[0];
				temp3 <= X_buffer[1];
			end
			15: begin
				mul_reg <= mul;
				temp0 <= Y_buffer[0];
				temp1 <= Y_buffer[1];
				temp2 <= Y_buffer[0];
				temp3 <= Y_buffer[1];
			end
			16: begin //取a得到S
				temp0 <= sqrt_out;
				temp1 <= R_buffer[0];
				temp2 <= R_buffer[1];
				mul_reg <= 0;
			end
			17: begin
				S_reg <= S;
				temp0 <= S;
				temp1 <= 0;
				temp2 <= S;
				temp3 <= temp0;//a

			end
			18: begin //s-a存起來
				temp0 <= S_reg;
				temp1 <= R_buffer[0];
				temp2 <= S_reg;
				temp3 <= R_buffer[1];
				S_reg <= sqrt_out;
			end
			19: begin
				temp0 <= S_reg;
				temp1 <= 0;
				temp2 <= sqrt_out;
				temp3 <= 0;
			end
			20: begin
				area_reg <= next_area_reg;
				temp0 <= X_buffer[1];
				temp1 <= X_buffer[2];
				temp2 <= X_buffer[1];
				temp3 <= X_buffer[2];
			end
			21: begin
				mul_reg <= mul;
				temp0 <= Y_buffer[1];
				temp1 <= Y_buffer[2];
				temp2 <= Y_buffer[1];
				temp3 <= Y_buffer[2];
			end
			22: begin //取a得到S
				temp0 <= sqrt_out;
				temp1 <= R_buffer[1];
				temp2 <= R_buffer[2];
				mul_reg <= 0;
			end
			23: begin
				S_reg <= S;
				temp0 <= S;
				temp1 <= 0;
				temp2 <= S;
				temp3 <= temp0;//a

			end
			24: begin //s-a存起來
				temp0 <= S_reg;
				temp1 <= R_buffer[1];
				temp2 <= S_reg;
				temp3 <= R_buffer[2];
				S_reg <= sqrt_out;
			end
			25: begin
				temp0 <= S_reg;
				temp1 <= 0;
				temp2 <= sqrt_out;
				temp3 <= 0;
			end
			26: begin
				area_reg <= next_area_reg;
				temp0 <= X_buffer[2];
				temp1 <= X_buffer[3];
				temp2 <= X_buffer[2];
				temp3 <= X_buffer[3];	
			end
			27: begin
				mul_reg <= mul;
				temp0 <= Y_buffer[2];
				temp1 <= Y_buffer[3];
				temp2 <= Y_buffer[2];
				temp3 <= Y_buffer[3];
			end
			28: begin //取a得到S
				temp0 <= sqrt_out;
				temp1 <= R_buffer[2];
				temp2 <= R_buffer[3];
				mul_reg <= 0;
			end
			29: begin
				S_reg <= S;
				temp0 <= S;
				temp1 <= 0;
				temp2 <= S;
				temp3 <= temp0;//a

			end
			30: begin //s-a存起來
				temp0 <= S_reg;
				temp1 <= R_buffer[2];
				temp2 <= S_reg;
				temp3 <= R_buffer[3];
				S_reg <= sqrt_out;
			end
			31: begin
				temp0 <= S_reg;
				temp1 <= 0;
				temp2 <= sqrt_out;
				temp3 <= 0;
			end
			32: begin
				area_reg <= next_area_reg;
				temp0 <= X_buffer[3];
				temp1 <= X_buffer[4];
				temp2 <= X_buffer[3];
				temp3 <= X_buffer[4];	
			end
			33: begin
				mul_reg <= mul;
				temp0 <= Y_buffer[3];
				temp1 <= Y_buffer[4];
				temp2 <= Y_buffer[3];
				temp3 <= Y_buffer[4];
			end
			34: begin //取a得到S
				temp0 <= sqrt_out;
				temp1 <= R_buffer[3];
				temp2 <= R_buffer[4];
				mul_reg <= 0;
			end
			35: begin
				S_reg <= S;
				temp0 <= S;
				temp1 <= 0;
				temp2 <= S;
				temp3 <= temp0;//a

			end
			36: begin //s-a存起來
				temp0 <= S_reg;
				temp1 <= R_buffer[3];
				temp2 <= S_reg;
				temp3 <= R_buffer[4];
				S_reg <= sqrt_out;
			end
			37: begin
				temp0 <= S_reg;
				temp1 <= 0;
				temp2 <= sqrt_out;
				temp3 <= 0;
			end
			38: begin
				area_reg <= next_area_reg;
				temp0 <= X_buffer[4];
				temp1 <= X_buffer[5];
				temp2 <= X_buffer[4];
				temp3 <= X_buffer[5];	
			end
			39: begin
				mul_reg <= mul;
				temp0 <= Y_buffer[4];
				temp1 <= Y_buffer[5];
				temp2 <= Y_buffer[4];
				temp3 <= Y_buffer[5];
			end
			40: begin //取a得到S
				temp0 <= sqrt_out;
				temp1 <= R_buffer[4];
				temp2 <= R_buffer[5];
				mul_reg <= 0;
			end
			41: begin
				S_reg <= S;
				temp0 <= S;
				temp1 <= 0;
				temp2 <= S;
				temp3 <= temp0;//a

			end
			42: begin //s-a存起來
				temp0 <= S_reg;
				temp1 <= R_buffer[4];
				temp2 <= S_reg;
				temp3 <= R_buffer[5];
				S_reg <= sqrt_out;
			end
			43: begin
				temp0 <= S_reg;
				temp1 <= 0;
				temp2 <= sqrt_out;
				temp3 <= 0;
			end
			44: begin
				area_reg <= next_area_reg;
				temp0 <= X_buffer[5];
				temp1 <= X_buffer[0];
				temp2 <= X_buffer[5];
				temp3 <= X_buffer[0];	
			end
			45: begin
				mul_reg <= mul;
				temp0 <= Y_buffer[5];
				temp1 <= Y_buffer[0];
				temp2 <= Y_buffer[5];
				temp3 <= Y_buffer[0];
			end
			46: begin //取a得到S
				temp0 <= sqrt_out;
				temp1 <= R_buffer[5];
				temp2 <= R_buffer[0];
				mul_reg <= 0;
			end
			47: begin
				S_reg <= S;
				temp0 <= S;
				temp1 <= 0;
				temp2 <= S;
				temp3 <= temp0;//a

			end
			48: begin //s-a存起來
				temp0 <= S_reg;
				temp1 <= R_buffer[5];
				temp2 <= S_reg;
				temp3 <= R_buffer[0];
				S_reg <= sqrt_out;
			end
			49: begin
				temp0 <= S_reg;
				temp1 <= 0;
				temp2 <= sqrt_out;
				temp3 <= 0;
			end
			50: begin
				area_reg <= next_area_reg;
				temp0 <= X_buffer[0];
				temp2 <= Y_buffer[1];
			end
			51: begin
				temp0 <= X_buffer[1];
				temp2 <= Y_buffer[2];
				area_all_reg <= next_area_all;
			end
			52: begin
				temp0 <= X_buffer[2];
				temp2 <= Y_buffer[3];
				area_all_reg <= next_area_all;
			end
			53: begin
				temp0 <= X_buffer[3];
				temp2 <= Y_buffer[4];
				area_all_reg <= next_area_all;
			end
			54: begin
				temp0 <= X_buffer[4];
				temp2 <= Y_buffer[5];
				area_all_reg <= next_area_all;
			end
			55: begin
				temp0 <= X_buffer[5];
				temp2 <= Y_buffer[0];
				area_all_reg <= next_area_all;
			end
			56: begin
				temp0 <= X_buffer[1];
				temp2 <= Y_buffer[0];
				area_all_reg <= next_area_all;
			end
			57: begin
				temp0 <= X_buffer[2];
				temp2 <= Y_buffer[1];
				area_all_reg <= next_area_all;
			end
			58: begin
				temp0 <= X_buffer[3];
				temp2 <= Y_buffer[2];
				area_all_reg <= next_area_all;
			end
			59: begin
				temp0 <= X_buffer[4];
				temp2 <= Y_buffer[3];
				area_all_reg <= next_area_all;
			end
			60: begin
				temp0 <= X_buffer[5];
				temp2 <= Y_buffer[4];
				area_all_reg <= next_area_all;
			end
			61: begin
				temp0 <= X_buffer[0];
				temp2 <= Y_buffer[5];
				area_all_reg <= next_area_all;
			end
			62: begin
				area_all_reg <= next_area_all>>1;
			end
			63: begin
				area_all_reg <= 0;
				area_reg <= 0;
			end
		endcase
	end

end


endmodule

module DW_sqrt_inst (radicand, square_root);
    parameter radicand_width = 20;
    parameter tc_mode        = 0;
  
    input  [radicand_width-1 : 0]       radicand;
    output [(radicand_width+1)/2-1 : 0] square_root;
    // Please add +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator 
    // command line (for simulation).
  
    // instance of DW_sqrt
    DW_sqrt #(radicand_width, tc_mode) 
      U1 (.a(radicand), .root(square_root));
endmodule