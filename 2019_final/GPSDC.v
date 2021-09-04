`timescale 1ns/10ps
module GPSDC(clk, reset_n, DEN, LON_IN, LAT_IN, COS_ADDR, COS_DATA, ASIN_ADDR, ASIN_DATA, Valid, a, D);
input              clk;
input              reset_n;
input              DEN;
input      [23:0]  LON_IN;//經度
input      [23:0]  LAT_IN;//緯度  (緯度,經度)
input      [95:0]  COS_DATA;
output reg [6:0]   COS_ADDR;
input      [127:0] ASIN_DATA;
output reg [5:0]   ASIN_ADDR;
output reg Valid;
output     [39:0]  D;
output     [63:0]  a;

reg [2:0] step;
reg [23:0] LON_buffer[0:1];
reg [23:0] LAT_buffer[0:1];
reg [127:0] temp;
reg [65:0] LAT_COS[0:1];//32+64
reg first;

wire [23:0] LAT_DIFF, LON_DIFF;
wire [39:0] LAT_SIN, LON_SIN;
wire [79:0] LAT_SIN_2, LON_SIN_2;


assign LAT_DIFF = (LAT_buffer[1] > LAT_buffer[0]) ? LAT_buffer[1] - LAT_buffer[0] : LAT_buffer[0] - LAT_buffer[1];
assign LON_DIFF = (LON_buffer[1] > LON_buffer[0]) ? LON_buffer[1] - LON_buffer[0] : LON_buffer[0] - LON_buffer[1];	// 8-16
assign LAT_SIN = (LAT_DIFF * 16'h477) >> 1;
assign LON_SIN = (LON_DIFF * 16'h477) >> 1;	// 8-32
assign LAT_SIN_2 = LAT_SIN*LAT_SIN;
assign LON_SIN_2 = LON_SIN*LON_SIN;		// 16-64		




reg [63:0] x, x0, x1, y0, y1;
wire [95:0] y;//32+64

assign y = ((y0*(x1-x0))+((x-x0)*(y1-y0)))/(x1-x0);
assign a = ({LAT_SIN_2, 128'd0} + LAT_COS[0]*LAT_COS[1]*LON_SIN_2) >> 128;		// 80-192
assign D = (12756274 *y) >> 32;

always@(*)begin
	if(step == 3'd1) begin //lat cos
		x0 = temp[95:48];
		x1 = COS_DATA[95:48];
		y0 = temp[47:0]<<32;
		y1 = COS_DATA[47:0]<<32;
		x = (first)?{LAT_buffer[1], 16'h0000} : {LAT_buffer[0], 16'h0000};
	end
	else begin				// ASIN
		x0 = temp[127:64];
		x1 = ASIN_DATA[127:64];
		y0 = temp[63:0];
		y1 = ASIN_DATA[63:0];
		x = a;
	end
end

always@(posedge clk or negedge reset_n ) begin
	if (!reset_n) begin

		step <= 0;
		first <= 0;
		
	end
	else begin
		if (DEN) begin
			LON_buffer[first] <= LON_IN;
			LAT_buffer[first] <= LAT_IN;
			step <= 3'd1;
			COS_ADDR <= 0;
			ASIN_ADDR <= 0;
		end
		
		case (step)
			3'd1:begin//查cos表
				if({LAT_buffer[first],16'h0000}<COS_DATA[87:48]) begin
					LAT_COS[first] <= y;
					step <= 3'd2;
				end
				else begin
					temp[95:0] <= COS_DATA;
					COS_ADDR <= COS_ADDR + 7'd1;
				end
			end
			3'd2:begin //reset
				if(first==0) begin
					step <= 0;
					first <= 1'b1;
				end
				else begin
					step <= 3'd3;
					ASIN_ADDR <= 0;
				end	
			end
			3'd3:begin
				if(ASIN_DATA[127:64] > a) begin
					step <= 3'd4;
					Valid <= 1;
				end
				else begin
					temp <= ASIN_DATA;
					ASIN_ADDR <= ASIN_ADDR+1;
				end
			end
			3'd4:begin
				Valid <= 0;
				LAT_COS[0] <= LAT_COS[1];
				LON_buffer[0] <= LON_buffer[1];
				LAT_buffer[0] <= LAT_buffer[1];
				step <= 0;
			end
		endcase
	end
end

endmodule
