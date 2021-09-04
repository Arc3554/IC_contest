module triangle (clk, reset, nt, xi, yi, busy, po, xo, yo);
input clk, reset, nt;
input [2:0] xi, yi;
output reg busy, po;
output reg [2:0] xo, yo;

reg [1:0] step;
reg [3:0] x1,x2,x3,y1,y2,y3;

integer i;
reg [3:0] now_x,now_y;




always @(posedge clk or posedge reset) begin
	if (reset) begin
		xo <= 0;
		yo <= 0;
		busy <= 0;
		po <= 0;
		step <= 0;
	end
	else begin
		if (nt == 1) begin
			step <= step + 1;
			x1 <= xi ;
			y1 <= yi ;
		end
		else if (step == 1) begin
			step <= step + 1;
			x2 <= xi ;
			y2 <= yi ;
		end
		else if (step == 2'd2) begin
			step <= step + 1;
			busy <= 1;
			x3 <= xi ;
			y3 <= yi ;
			now_x <= x1;
			now_y <= y1;
		end
		else if (step == 2'd3) begin
 			if(now_y == y1&&now_x<x2) begin
				po <= 1;
				xo <= now_x;
				yo <= now_y;
				now_x <= now_x +1;
			end
			else if(now_x == x3&&now_y<y3) begin
				po <= 1;
				xo <= now_x;
				yo <= now_y;
				now_x <= now_x +1;
			end
			else if((((x2-now_x)*(y3 - y2)) >= ((now_y-y2)*(x2-x3)))&&now_x<=x2&&now_y<=y3) begin
				po <= 1;
				xo <= now_x;
				yo <= now_y;
				now_x <= now_x +1;
			end
			else begin
				po <= 0;
				now_y <= now_y +1;
				now_x <= x1;
			end
			
			if (now_x == x3+1 && now_y == y3) begin
				busy <= 0;
				step <= 0;
				po <= 0;
			end
			
		end
	end
end
endmodule
