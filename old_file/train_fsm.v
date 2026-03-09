module train_fsm(
    input clk,
    input rstn,

    output [31:0]mem_addr,

    input [31:0]mem_rdata,
    output mem_rstrb,
    input mem_rbusy,

    output [31:0]mem_wdata,
    output [3:0]mem_wmask,
    input mem_wbusy
);

assign mem_rstrb = 1;

endmodule