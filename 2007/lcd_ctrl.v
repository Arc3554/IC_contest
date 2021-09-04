module lcd_ctrl(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output reg [7:0]   dataout;
output reg         output_valid;
output reg         busy;

reg cur_state,next_state; // define cur_state and next_state
reg [5:0] img_counter;    // use to count load data number and use to count the output data number
reg [2:0] row,col;        // record the position
reg [2:0] row_t,col_t;        // position for output 
reg [5:0] out_pos;         // output position
reg [2:0] cmd_reg;        // cmd temp
reg [7:0] data_buff[35:0]; // buf all data

localparam REFLASH     = 3'd0;
localparam LOAD_DATA   = 3'd1;
localparam SHIFT_RIGHT = 3'd2;
localparam SHIFT_LEFT  = 3'd3;
localparam SHIFT_UP    = 3'd4;
localparam SHIFT_DOWN  = 3'd5;
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
            if ( ( cmd_reg == REFLASH ) && img_counter[5:3] == 3'd2 && img_counter[2:0] == 3'd2 )
                next_state = WAIT_CMD;
            else
                next_state = PROCESS;
        end
    endcase
end
always @ (*) begin  // Calculate output position
                    // img_counter[5:3] --> row control
                    // img_counter[2:0] --> col control
                    // out_pos --> store output position
	out_pos = 6*(row+img_counter[5:3])+img_counter[2:0]+col;
end
always @ ( posedge clk or posedge reset ) begin  // Data process and control signal
    if (reset) begin
        row <= 3'd2;
        col <= 3'd2;
        dataout <= 8'd0;
        output_valid <= 1'd0;
        busy <= 1'd0;
        cmd_reg <= REFLASH;
        img_counter <= 6'd0;
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
                    if ( img_counter[2:0] == 3'd2 ) begin
                        img_counter[5:3] <= img_counter[5:3] + 1'd1;
                        img_counter[2:0] <= 3'd0;
                    end
                    else begin
                        img_counter <= img_counter + 6'd1;
                    end
                    if ( img_counter[5:3] == 3'd2 && img_counter[2:0] == 3'd2 ) begin
                        busy <= 1'd0;
                    end
                    output_valid <= 1'd1;
                
                end
                LOAD_DATA : begin
                    if (img_counter == 6'd35) begin
                        img_counter <= 6'd0;
                        cmd_reg <= REFLASH;
                    end
                    else
                        img_counter <= img_counter + 6'd1;
                    data_buff[img_counter] <= datain;
                    row <= 3'd2;
                    col <= 3'd2;
                end
                SHIFT_RIGHT : begin
		    if (col != 3'd3) begin
		    	col <= col+3'd1;
		    end
		    cmd_reg <= REFLASH;
                end
                SHIFT_LEFT : begin
		    if (col != 3'd0) begin
		    	col <= col-3'd1;
		    end
		    cmd_reg <= REFLASH;

                end
                SHIFT_UP : begin
		    if (row != 3'd0) begin
		    	row <= row-3'd1;
		    end
		    cmd_reg <= REFLASH;

                end
                default : begin // SHIFT_DOWN
		    if (row != 3'd3) begin
		    	row <= row+3'd1;
		    end
		    cmd_reg <= REFLASH;

                end
            endcase
        end
    end
end

endmodule
