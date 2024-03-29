module reg_sync_rst(data,clk,ce,s_rst,q);
parameter N = 18;
input [N-1:0] data;
input clk,ce,s_rst;
output reg [N-1:0] q;

always @(posedge clk) begin
	if (s_rst) begin
		q <= 0;
	end
	else if (ce) begin
		q <= data;
	end
end
endmodule