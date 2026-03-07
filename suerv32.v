module suerv32(
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

always_ff @(posedge clk or negedge rstn) begin
    if (rstn == 0'b0) begin 
        mem_addr <= 0;
    end 
    else begin
        mem_rstrb <= 1;
        mem_addr <= mem_addr + 4;
    end
end


endmodule