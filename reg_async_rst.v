module reg_async_rst(data,clk,ce,a_rst,q);
parameter N = 18;
input [N-1:0] data;
input clk,ce,a_rst;
output reg [N-1:0] q;

always @(posedge clk or posedge a_rst) begin
	if (a_rst) begin
		q <= 0;
	end
	else if (ce) begin
		q <= data;
	end
end
endmodule