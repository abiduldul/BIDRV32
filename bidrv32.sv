module bidrv32 (
    input logic clk,
    input logic rstn,

    output logic [31:0] pc,
    input logic [31:0] instr
);

// PC register
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) pc <= 32'd0;
    else pc <= pc + 32'd4;
end

// Decoder
logic [6:0] opcode, funct7;
logic [4:0] rd, rs1, rs2;
logic [2:0] funct3;

assign opcode = instr[6:0];
assign rd = instr[11:7];
assign funct3 = instr[14:12];
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign funct7 = instr[31:25];

logic [31:0] imm;

always_comb begin
    case (opcode)
        7'b0010011: imm = {{20{instr[31]}}, instr[31:20]};  // I-type
        7'b0000011: imm = {{20{instr[31]}}, instr[31:20]};  // Load
        7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};  // S-type
        7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
        7'b0110111: imm = {instr[31:12], 12'b0};  // U-type
        7'b1101111: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
        default:    imm = 32'b0;  // R-type has no immediate
    endcase
end

// Control Unit
logic we;
logic alu_src, mem_read, mem_write, mem_to_reg;
logic [3:0] alu_op;

always_comb begin
    we = 0;
    alu_src = 0;
    mem_read = 0;
    mem_write = 0;
    alu_op = 4'b0;
    mem_to_reg = 0;

    case (opcode) 
        7'b0110011: begin  // R-type
            we      = 1;
            alu_src = 0;
            case ({funct7[5], funct3}) 
                4'b0000: alu_op = 4'b0000; // ADD
                4'b1000: alu_op = 4'b0001; // SUB
                4'b0111: alu_op = 4'b0010; // AND
                4'b0110: alu_op = 4'b0011; // OR
                4'b0100: alu_op = 4'b0100; // XOR
                4'b0001: alu_op = 4'b0101; // SLL
                4'b0101: alu_op = 4'b0110; // SRL
                4'b1101: alu_op = 4'b0111; // SRA
                4'b0010: alu_op = 4'b1000; // SLT
                default: alu_op = 4'b0000;
            endcase
        end
        7'b0010011: begin  // I-type (Immediate-type)
            we      = 1;
            alu_src = 1;
            alu_op  = 4'b0000;
        end
        7'b0000011: begin  // Load
            we       = 1;
            alu_src  = 1;
            mem_read = 1;
            alu_op  = 4'b0000;
            mem_to_reg = 1;
        end
        7'b0100011: begin  // S-type (Store) 
            alu_src   = 1;
            mem_write = 1;
            alu_op  = 4'b0000;
        end
        7'b1100011: begin  // B-type (Branch)
            alu_op  = 4'b0001;
        end
        //later will add U (Upper-immediate) and J (Jump) type
    endcase
end

// Register file
logic [31:0] wd, rdata1, rdata2;

logic [31:0] regs [0:31];
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for (int i =0; i<32; i++)
            regs[i] <= 32'b0;
    end 
    else if (we && (rd != 0)) begin
        regs[rd] <= wd;
    end
end

assign rdata1 = (rs1 == 0) ? 32'b0 : regs[rs1];
assign rdata2 = (rs2 == 0) ? 32'b0 : regs[rs2];

// ALU
logic [31:0] alu_input_b, alu_result;
logic alu_out_zero;

assign alu_input_b = (alu_src == 0) ? rdata2 : imm;

always_comb begin
    case (alu_op)
        4'b0000: alu_result = rdata1 + alu_input_b;           // ADD
        4'b0001: alu_result = rdata1 - alu_input_b;           // SUB
        4'b0010: alu_result = rdata1 & alu_input_b;           // AND
        4'b0011: alu_result = rdata1 | alu_input_b;           // OR
        4'b0100: alu_result = rdata1 ^ alu_input_b;           // XOR
        4'b0101: alu_result = rdata1 << alu_input_b[4:0];     // SLL
        4'b0110: alu_result = rdata1 >> alu_input_b[4:0];     // SRL
        4'b0111: alu_result = $signed(rdata1) >>> alu_input_b[4:0]; // SRA
        4'b1000: alu_result = ($signed(rdata1) < $signed(alu_input_b)) ? 32'd1 : 32'd0; // SLT
        default: alu_result = 32'b0;
    endcase
end

assign alu_out_zero = (alu_result == 32'b0);

logic [31:0] mem_rdata;
assign wd = (mem_to_reg == 0) ? alu_result : mem_rdata;

//DMEM
logic [31:0] dmem [0:1023];   // 1024 words = 4 KB

always_ff @(posedge clk) begin
    if (mem_write)
        dmem[alu_result[11:2]] <= rdata2;
end

assign mem_rdata = (mem_read) ? dmem[alu_result[11:2]] : 32'b0;
endmodule