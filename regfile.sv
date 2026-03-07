module regfile (
    input  logic        clk,
    input  logic        we,           // write enable
    input  logic [4:0]  rs1, rs2, rd, // register index
    input  logic [31:0] wd,           // write data
    output logic [31:0] rd1, rd2      // read data
);

    // 32 register x 32-bit (x0-x31)
    logic [31:0] regs [31:0];

    // baca data (kombinasional)
    assign rd1 = (rs1 == 0) ? 32'b0 : regs[rs1]; // x0 selalu 0
    assign rd2 = (rs2 == 0) ? 32'b0 : regs[rs2];

    // tulis data (sinkron)
    always_ff @(posedge clk) begin
        if (we && (rd != 0)) begin
            regs[rd] <= wd;
        end
    end

endmodule
