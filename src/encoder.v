// ========================================================
// Sub-module: 256-to-8 Priority Encoder
// ========================================================
module encoder_256_8 (
    input  wire [255:0] in_data,
    output reg  [7:0]   out_code,
    output reg          valid
);
    reg [8:0] i; // 9 bits prevents infinite loop overflow

    always @(*) begin
        out_code = 8'd0;
        valid    = 1'b0;
        
        for (i = 0; i < 256; i = i + 1) begin
            if (in_data[i] == 1'b1) begin
                out_code = i[7:0];
                valid    = 1'b1;
            end
        end
    end
endmodule

// ========================================================
// Top-module: 1024-to-10 Priority Encoder (Wrapper)
// ========================================================
module encoder_1024_10 (
    input  wire [1023:0] in_data,
    output reg  [9:0]    out_code,
    output reg           valid
);
    // Flat wires to connect the sub-modules
    wire [7:0] code_0, code_1, code_2, code_3;
    wire       valid_0, valid_1, valid_2, valid_3;

    // Instantiate the four 256-input encoders
    encoder_256_8 enc0 (
        .in_data(in_data[255:0]),   
        .out_code(code_0), 
        .valid(valid_0)
    );
    
    encoder_256_8 enc1 (
        .in_data(in_data[511:256]), 
        .out_code(code_1), 
        .valid(valid_1)
    );
    
    encoder_256_8 enc2 (
        .in_data(in_data[767:512]), 
        .out_code(code_2), 
        .valid(valid_2)
    );
    
    encoder_256_8 enc3 (
        .in_data(in_data[1023:768]),
        .out_code(code_3), 
        .valid(valid_3)
    );

    // Top-level priority logic
    always @(*) begin
        valid = 1'b1;
        if      (valid_3) out_code = {2'b11, code_3};
        else if (valid_2) out_code = {2'b10, code_2};
        else if (valid_1) out_code = {2'b01, code_1};
        else if (valid_0) out_code = {2'b00, code_0};
        else begin
            out_code = 10'd0;
            valid    = 1'b0;
        end
    end
endmodule
