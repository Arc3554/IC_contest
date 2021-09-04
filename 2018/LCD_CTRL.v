module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);

input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;

output reg IROM_rd;
output reg [5:0] IROM_A;
output reg IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
output reg busy;
output reg done;

reg [2:0] row,col;        // record the position
reg [7:0] out_pos;         // output position
reg [3:0] cmd_reg;        // cmd temp
reg [7:0] data_buff[63:0]; // buf all data
reg [9:0] avg;
reg step;

localparam WRITE   = 4'd0;
localparam SHIFT_UP    = 4'd1;
localparam SHIFT_DOWN  = 4'd2;
localparam SHIFT_LEFT  = 4'd3;
localparam SHIFT_RIGHT = 4'd4;
localparam MAX = 4'd5;
localparam MIN = 4'd6;
localparam AVERAGE = 4'd7;
localparam C_ROTATE = 4'd8;
localparam ROTATE = 4'd9;
localparam MIRROR_X = 4'd10;
localparam MIRROR_Y = 4'd11;



always @ (*) begin
	out_pos = 8*row+col;
end




always @ ( posedge clk or posedge reset) begin  // Data process and control signal
	if (reset) begin
		busy <= 1;
		done <= 0;
		IROM_A <= 0;
		IROM_rd <= 1;
		step <= 0;	
		IRAM_valid <= 0;
		IRAM_A <= 0;
		IRAM_D <= 0;
	end
	else begin
 		if (IRAM_valid == 1) begin
			IRAM_A <= IRAM_A + 1;
		end 
		if (IROM_rd == 1) begin
			if (step == 0) begin 
				step <= 1; 
			end
			else begin
				step <= 0;
				data_buff[IROM_A] <= IROM_Q;
				IROM_A <= IROM_A + 1;
				if (IROM_A == 6'd63) begin
					IROM_rd <= 0;
					busy <= 0;

				end
			end
		end
		else if (IRAM_valid == 1) begin
			IRAM_D <= data_buff[IRAM_A+1];
			if (IRAM_A == 6'd63) begin
				IRAM_valid <= 0;
				busy <= 0;
				done <= 1;
			end
		end

		if ( cmd_valid == 1 && busy == 0 ) begin
			busy <= 1;
			cmd_reg <= cmd;
		end
		else begin
			case ( cmd_reg )
				WRITE: begin
					IRAM_valid <= 1;
					cmd_reg <= 4'd12;
					IRAM_D <= data_buff[0];
				end
				SHIFT_UP : begin
					if (row != 3'd1) begin
						row <= row-3'd1;
					end
					busy <= 0;
				end
				SHIFT_DOWN : begin
					if (row != 3'd7) begin
						row <= row+'d1;
					end
					busy <= 0;
				end
				SHIFT_LEFT : begin
					if (col != 3'd1) begin
						col <= col-3'd1;
					end
					busy <= 0;
				end
				SHIFT_RIGHT : begin
					if (col != 3'd7) begin
						col <= col+3'd1;
					end
					busy <= 0;
				end
				MAX : begin
					if (data_buff[out_pos]>=data_buff[out_pos-1] && data_buff[out_pos]>=data_buff[out_pos-8] && data_buff[out_pos]>=data_buff[out_pos-9]) begin
						data_buff[out_pos-9] <= data_buff[out_pos];
						data_buff[out_pos-8] <= data_buff[out_pos];
						data_buff[out_pos-1] <= data_buff[out_pos];
					end
					else if (data_buff[out_pos-1]>=data_buff[out_pos] && data_buff[out_pos-1]>=data_buff[out_pos-8] && data_buff[out_pos-1]>=data_buff[out_pos-9]) begin
						data_buff[out_pos-9] <= data_buff[out_pos-1];
						data_buff[out_pos-8] <= data_buff[out_pos-1];
						data_buff[out_pos] <= data_buff[out_pos-1];
					end
					else if (data_buff[out_pos-8]>=data_buff[out_pos] && data_buff[out_pos-8]>=data_buff[out_pos-1] && data_buff[out_pos-8]>=data_buff[out_pos-9]) begin
						data_buff[out_pos-9] <= data_buff[out_pos-8];
						data_buff[out_pos-1] <= data_buff[out_pos-8];
						data_buff[out_pos] <= data_buff[out_pos-8];
					end
					else if (data_buff[out_pos-9]>=data_buff[out_pos] && data_buff[out_pos-9]>=data_buff[out_pos-1] && data_buff[out_pos-9]>=data_buff[out_pos-8]) begin
						data_buff[out_pos-1] <= data_buff[out_pos-9];
						data_buff[out_pos-8] <= data_buff[out_pos-9];
						data_buff[out_pos] <= data_buff[out_pos-9];
					end
					busy <= 0;
				end
				MIN : begin
					if (data_buff[out_pos]<=data_buff[out_pos-1] && data_buff[out_pos]<=data_buff[out_pos-8] && data_buff[out_pos]<=data_buff[out_pos-9]) begin
						data_buff[out_pos-9] <= data_buff[out_pos];
						data_buff[out_pos-8] <= data_buff[out_pos];
						data_buff[out_pos-1] <= data_buff[out_pos];
					end
					else if (data_buff[out_pos-1]<=data_buff[out_pos] && data_buff[out_pos-1]<=data_buff[out_pos-8] && data_buff[out_pos-1]<=data_buff[out_pos-9]) begin
						data_buff[out_pos-9] <= data_buff[out_pos-1];
						data_buff[out_pos-8] <= data_buff[out_pos-1];
						data_buff[out_pos] <= data_buff[out_pos-1];
					end
					else if (data_buff[out_pos-8]<=data_buff[out_pos] && data_buff[out_pos-8]<=data_buff[out_pos-1] && data_buff[out_pos-8]<=data_buff[out_pos-9]) begin
						data_buff[out_pos-9] <= data_buff[out_pos-8];
						data_buff[out_pos-1] <= data_buff[out_pos-8];
						data_buff[out_pos] <= data_buff[out_pos-8];
					end
					else if (data_buff[out_pos-9]<=data_buff[out_pos] && data_buff[out_pos-9]<=data_buff[out_pos-1] && data_buff[out_pos-9]<=data_buff[out_pos-8]) begin
						data_buff[out_pos-1] <= data_buff[out_pos-9];
						data_buff[out_pos-8] <= data_buff[out_pos-9];
						data_buff[out_pos] <= data_buff[out_pos-9];
					end
					busy <= 0;
				end
				AVERAGE : begin
					if (step == 0)begin
						avg <= data_buff[out_pos-9]+data_buff[out_pos-8]+data_buff[out_pos-1]+data_buff[out_pos];
						step <= 1;
					end
					else begin
						data_buff[out_pos-1] <= avg [9:2];
						data_buff[out_pos-8] <= avg [9:2];
						data_buff[out_pos-9] <= avg [9:2];
						data_buff[out_pos] <= avg [9:2];
						step <= 0;
						busy <= 0;
					end
				end
				C_ROTATE : begin
					data_buff[out_pos-1]<=data_buff[out_pos-9];
					data_buff[out_pos]<=data_buff[out_pos-1];
					data_buff[out_pos-8]<=data_buff[out_pos];
					data_buff[out_pos-9]<=data_buff[out_pos-8];
					busy <= 0;
				end
				ROTATE : begin
					data_buff[out_pos-8]<=data_buff[out_pos-9];
					data_buff[out_pos]<=data_buff[out_pos-8];
					data_buff[out_pos-1]<=data_buff[out_pos];
					data_buff[out_pos-9]<=data_buff[out_pos-1];
					busy <= 0;
				end
				MIRROR_X : begin
					data_buff[out_pos-1]<=data_buff[out_pos-9];
					data_buff[out_pos-9]<=data_buff[out_pos-1];
					data_buff[out_pos-8]<=data_buff[out_pos];
					data_buff[out_pos]<=data_buff[out_pos-8];
					busy <= 0;
				end
				MIRROR_Y : begin
					data_buff[out_pos-8]<=data_buff[out_pos-9];
					data_buff[out_pos-9]<=data_buff[out_pos-8];
					data_buff[out_pos-1]<=data_buff[out_pos];
					data_buff[out_pos]<=data_buff[out_pos-1];
					busy <= 0;
				end
			endcase
		end
	end
end





endmodule



