`timescale 1ns/1ps

module irom (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    logic [31:0] mem [0:255];   // 256 words = 1KB of program space

    // Hardcoded program for now
    initial begin
        // We'll fill this in below
        mem[0] = 32'h00A00293;  // addi x5, x0, 10
        mem[1] = 32'h01400313;  // addi x6, x0, 20
        mem[2] = 32'h006283B3;  // add  x7, x5, x6
        mem[3] = 32'h00702023;  // sw   x7, 0(x0)
        mem[4] = 32'h00002403;  // lw   x8, 0(x0)
    end

    assign instr = mem[addr[11:2]];   // same byte→word trick as DMEM!

endmodule