module tb_train_fsm;

wire clk, rstn;

initial begin
    clk = 1'b0;
    rstn = 1'b1;
    #10;
    rstn = 1'b0;
    #10
    rstn = 1'b1
    #10
end

always #5 clk = ~clk;

always @(posedge clk) begin
        
end

train_fsm fsm_uut(.clk(clk),
                  .rstn(rstn),
                  .mem_addr(),
                  .mem_rdata(),
                  .mem_rstrb(),
                  .mem_rbusy(),
                  .mem_wdata(),
                  .mem_wmask(),
                  .mem_wbusy());

endmodule