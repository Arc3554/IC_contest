module LCD_CTRL(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output reg [7:0]   dataout;
output reg         output_valid;
output reg         busy;

reg cur_state,next_state; // define cur_state and next_state
reg [7:0] img_counter;    // use to count load data number and use to count the output data number
reg [3:0] row,col;        // record the position
reg [7:0] out_pos;         // output position
reg [2:0] cmd_reg;        // cmd temp
reg [7:0] data_buff[107:0]; // buf all data
reg now_zoom;


localparam LOAD_DATA   = 3'd0;
localparam ZOOM_IN     = 3'd1;
localparam ZOOM_FIT    = 3'd2;
localparam SHIFT_RIGHT = 3'd3;
localparam SHIFT_LEFT  = 3'd4;
localparam SHIFT_UP    = 3'd5;
localparam SHIFT_DOWN  = 3'd6;
localparam REFLASH     = 3'd7;
localparam WAIT_CMD = 1'b0;
localparam PROCESS  = 1'b1;                                


always @ ( posedge clk or posedge reset ) begin   // State Control
    if (reset) // active high asynchronous
        cur_state <= WAIT_CMD;
    else
        cur_state <= next_state;
end 

always @ ( * ) begin    // State Control ( next state condition )
    case ( cur_state )
        WAIT_CMD : begin
            if ( cmd_valid )
                next_state = PROCESS;
            else
                next_state = WAIT_CMD;
        end
		PROCESS : begin
            if ( ( cmd_reg == REFLASH ) && img_counter[7:4] == 4'd3 && img_counter[3:0] == 4'd3 )
                next_state = WAIT_CMD;
            else
                next_state = PROCESS;
        end
		
		
    endcase
end
always @ (*) begin
	if (now_zoom == 1)begin
		out_pos = 12*(row+img_counter[7:4]-2)+img_counter[3:0]+col-2;
	end
	else if (now_zoom == 0) begin
		out_pos = 24*(img_counter[7:4])+3*(img_counter[3:0])+13;
	end
end
always @ ( posedge clk or posedge reset ) begin  // Data process and control signal
    if (reset) begin
        row <= 4'd5;
        col <= 4'd6;
        dataout <= 8'd0;
        output_valid <= 1'd0;
        busy <= 1'd0;
        cmd_reg <= REFLASH;
        img_counter <= 8'd0;
    end
    else begin
        if ( cur_state == WAIT_CMD ) begin
            if ( cmd_valid ) begin
                cmd_reg <= cmd;
                busy <= 1'd1;
            end
            img_counter <= 6'd0;
            output_valid <= 1'd0;
        end
        else begin
            case ( cmd_reg )
                REFLASH : begin
					dataout <= data_buff[out_pos];
						
					if ( img_counter[3:0] == 4'd3 ) begin
						img_counter[7:4] <= img_counter[7:4] + 1;
						img_counter[3:0] <= 0;
					end
					
					else begin
						img_counter <= img_counter + 1;
					end
					
					if ( img_counter[7:4] == 4'd3 && img_counter[3:0] == 4'd3 ) begin
						busy <= 0;
					end
					
                    output_valid <= 1'd1;
                
                end
				ZOOM_IN : begin
					if (now_zoom == 0) begin
						now_zoom <= 1;
						row <= 4'd5;
						col <= 4'd6;
					end
					cmd_reg <= REFLASH;
				end
				ZOOM_FIT : begin
					now_zoom <= 0;
					cmd_reg <= REFLASH;
				end			
                LOAD_DATA : begin
                    if (img_counter == 8'd107) begin
                        img_counter <= 8'd0;
						now_zoom <= 1'b0;
                        cmd_reg <= REFLASH;
                    end
                    else begin
                        img_counter <= img_counter + 8'd1;
					end
					data_buff[img_counter] <= datain;
                end
                SHIFT_RIGHT : begin
					if (col != 4'd10) begin
						col <= col+4'd1;
					end
					cmd_reg <= REFLASH;
                end
                SHIFT_LEFT : begin
					if (col != 4'd2) begin
						col <= col-4'd1;
					end
					cmd_reg <= REFLASH;
                end
                SHIFT_UP : begin
					if (row != 4'd2) begin
						row <= row-4'd1;
					end
					cmd_reg <= REFLASH;
                end
                default : begin // SHIFT_DOWN
					if (row != 4'd7) begin
						row <= row+4'd1;
					end
					cmd_reg <= REFLASH;
                end
            endcase
        end
    end
end

endmodule