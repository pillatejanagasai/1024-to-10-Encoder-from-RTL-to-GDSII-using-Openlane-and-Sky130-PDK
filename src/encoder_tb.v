`timescale 1ns/1ps

module tb_encoder_1024_10;

    // Inputs to DUT
    reg [1023:0] in_data;

    // Outputs from DUT
    wire [9:0] out_code;
    wire valid;

    integer i;
    integer errors = 0;

    // Instantiate the Device Under Test (DUT)
    encoder_1024_10 dut (
        .in_data(in_data),
        .out_code(out_code),
        .valid(valid)
    );

    initial begin
        // 1. Setup waveform dumping for GTKWave
        $dumpfile("tb_encoder.vcd");
        $dumpvars(0, tb_encoder_1024_10);

        // 2. Initialize Inputs
        in_data = 1024'b0;
        #10;

        // --- TEST 1: All zeros ---
        if (valid !== 1'b0) begin
            $display("ERROR: Valid flag is high for an all-zero input.");
            errors = errors + 1;
        end else begin
            $display("PASS: All-zero input handled correctly.");
        end
        #10;

        // --- TEST 2: Walking '1' (One-hot mapping) ---
        $display("Starting walking-one tests (0 to 1023)...");
        for (i = 0; i < 1024; i = i + 1) begin
            in_data = (1024'b1 << i);
            #1; // Wait a timestep for combinational logic to resolve
            
            if (out_code !== i || valid !== 1'b1) begin
                $display("ERROR: Failed at bit %0d. Expected out: %0d, Got: %0d, Valid: %b", i, i, out_code, valid);
                errors = errors + 1;
            end
        end
        $display("Walking-one tests complete.");
        #10;

        // --- TEST 3: Priority Check (Multiple bits set) ---
        // Set bit 850 and bit 12
        in_data = 1024'b0;
        in_data[850] = 1'b1;
        in_data[12]  = 1'b1;
        #10;
        if (out_code !== 850 || valid !== 1'b1) begin
            $display("ERROR: Priority failed. Expected 850, Got %0d", out_code);
            errors = errors + 1;
        end else begin
            $display("PASS: Priority logic correctly selected bit 850 over bit 12.");
        end
        #10;

        // --- TEST 4: All ones ---
        // The highest index (1023) must win
        in_data = {1024{1'b1}};
        #10;
        if (out_code !== 1023 || valid !== 1'b1) begin
            $display("ERROR: All-ones test failed. Expected 1023, Got %0d", out_code);
            errors = errors + 1;
        end else begin
            $display("PASS: All-ones test handled correctly.");
        end
        #10;

        // --- FINAL RESULTS ---
        if (errors == 0) begin
            $display("======================================");
            $display("          ALL TESTS PASSED!           ");
            $display("======================================");
        end else begin
            $display("======================================");
            $display("      TESTS FAILED with %0d errors.   ", errors);
            $display("======================================");
        end

        $finish;
    end

endmodule
