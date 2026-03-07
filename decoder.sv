module decoder (
    //input dari rom
    input  logic [31:0] instr,

    //output decoder untuk register file dan alu
    output logic [6:0]  opcode,
    output logic [4:0]  rd,
    output logic [2:0]  funct3,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [6:0]  funct7,
    output logic [31:0] imm,
    output logic [4:0] shamt
);
    // --- definisi konstanta opcode ---
    localparam OPCODE_LUI    = 7'b0110111;
    localparam OPCODE_AUIPC  = 7'b0010111;
    localparam OPCODE_JAL    = 7'b1101111;
    localparam OPCODE_JALR   = 7'b1100111;
    localparam OPCODE_LOAD   = 7'b0000011;
    localparam OPCODE_OPIMM  = 7'b0010011;
    localparam OPCODE_BRANCH = 7'b1100011;
    localparam OPCODE_STORE  = 7'b0100011;
    
    // localparam OPCODE_OP     = 7'b0110011;
    // localparam OPCODE_MISC   = 7'b0001111;
    // localparam OPCODE_SYSTEM = 7'b1110011;

    // Pecah jadi field umum
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    // imm encoder
    always_comb begin
        case (opcode)
            OPCODE_LUI, OPCODE_AUIPC: begin                           // LUI, AUIPC
                imm = {instr[31:12], 12'b0};
            end
            OPCODE_JAL: begin                                       // JAL
                imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            end
            OPCODE_JALR, OPCODE_LOAD: begin               // JALR, LB, LH, LW, LBU, LHU 
                imm = {{20{instr[31]}}, instr[31:20]};
            end
            OPCODE_OPIMM: begin                           //ADDI, SLTI, SLTIU, XORI, ORI, ANDI
                if(funct3 == 3'b001 && funct7 == 7'b0000000) begin
                    shamt = instr[24:20];       //SLLI
                    imm = 32'b0;
                end 
                else if(funct3 == 3'b101) begin
                    if(funct7 == 7'b0000000) begin
                        shamt = instr[24:20];   //SRLI
                    end
                    else if(funct7 == 7'b0100000) begin
                        shamt = instr[24:20];   //SRAI
                    end
                    imm = 32'b0;   
                end 
                else begin
                    imm = {{20{instr[31]}}, instr[31:20]};   
                    shamt = 5'b0;
                end
            end
            OPCODE_BRANCH: begin                            // BEQ, BNE, BLT, BGE, BLTU, BGEU                             
                imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};   
            end
            OPCODE_STORE: begin                            // SB, SH, SW
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}; 
            end
            default: begin
                imm = 32'b0; //0110011, 0001111, 1110011
            end
        endcase
    end
endmodule
