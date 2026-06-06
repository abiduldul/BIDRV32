`timescale 1ns/1ps

module tb_top;

    logic clk, rstn;
    logic [31:0] pc, instr;

    // Clock generator — 10ns period (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset sequence
    initial begin
        rstn = 0;
        #20;
        rstn = 1;
    end

    // Instantiate CPU
    bidrv32 cpu (
        .clk(clk),
        .rstn(rstn),
        .pc(pc),
        .instr(instr)
    );

    // Instantiate ROM
    irom rom (
        .addr(pc),
        .instr(instr)
    );

    // Simulation control
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
        #200;
        $finish;
    end

    // Print regs after every clock edge for visibility
    always @(posedge clk) begin
        $display("t=%0t  pc=%h  instr=%h  x5=%0d  x6=%0d  x7=%0d  x8=%0d",
        $time, pc, instr, cpu.regs[5], cpu.regs[6], cpu.regs[7], cpu.regs[8]);
    end

endmodule