module reg_mux(data,clk,rst,ce,out);
parameter N = 18;
parameter RSTTYPE = "SYNC";
parameter SEL = 0;

input [N-1:0] data;
input clk,rst,ce;
output [N-1:0] out;

wire [N-1:0] reg_out;

generate
	if(RSTTYPE == "SYNC")
		reg_sync_rst #(.N(N)) sync_reg(.data(data),.clk(clk),.ce(ce),.s_rst(rst),.q(reg_out));
	else if(RSTTYPE == "ASYNC")
		reg_async_rst #(.N(N)) async_reg(.data(data),.clk(clk),.ce(ce),.a_rst(rst),.q(reg_out));
endgenerate

assign out = SEL ? reg_out : data;

endmodule 