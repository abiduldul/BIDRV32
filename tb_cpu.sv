module tb_cpu;

  // Clock & rstn
  logic clk, rstn;

  // PC
  logic [31:0] pc_curr;

  // Instruction memory
  logic [31:0] instr;

  // Decoder signals
  logic [4:0] rs1, rs2, rd;
  logic [31:0] imm;
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;

  // Register file
  logic [31:0] rdata1, rdata2;
  logic [31:0] wdata;
  logic we;

  // === Generate clock ===
  always #5 clk = ~clk;

  // === DUT ===
  pc u_pc (
    .clk(clk),
    .rstn(rstn),
    .pc_next(),
    .pc_curr(pc_curr)
  );

  rom u_rom (
    .addr(pc_curr), 
    .instr(instr)
  );

  decoder u_decoder (
    .instr(instr),
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .imm(imm),
    .shamt()
  );

  regfile u_regfile (
    .clk(clk),
    .we(we),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wd(wdata),
    .rd1(rdata1),
    .rd2(rdata2)
  );

  // === Simulasi ===
  initial begin
    clk   = 0;
    rstn = 0;
    we    = 1;
    wdata = 0;

    #10 rstn = 1;

    #100 $finish;
  end

  // === Monitor aktivitas ===
  always @(posedge clk) begin
    $display("PC=%h Instr=%h | rs1=%0d rs2=%0d rd=%0d imm=%h", 
              pc_curr, instr, rs1, rs2, rd, imm);
    $display("Reg[rs1]=%0d Reg[rs2]=%0d", rdata1, rdata2);
  end

endmodule
