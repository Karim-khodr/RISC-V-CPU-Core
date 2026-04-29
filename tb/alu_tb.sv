module alu_tb;

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0]  alu_op;
    logic [31:0] result;
    logic        zero;

    int tests_run;
    int tests_failed;

    localparam logic [3:0] ALU_ADD = 4'b0000;
    localparam logic [3:0] ALU_SUB = 4'b0001;
    localparam logic [3:0] ALU_AND = 4'b0010;
    localparam logic [3:0] ALU_OR  = 4'b0011;
    localparam logic [3:0] ALU_XOR = 4'b0100;

    alu dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );

    task automatic check(
        input string       test_name,
        input logic [3:0]  test_op,
        input logic [31:0] test_a,
        input logic [31:0] test_b,
        input logic [31:0] expected_result
    );
        logic expected_zero;

        begin
            a      = test_a;
            b      = test_b;
            alu_op = test_op;

            #1;

            expected_zero = (expected_result == 32'd0);
            tests_run++;

            if (result !== expected_result || zero !== expected_zero) begin
                tests_failed++;

                $display("FAIL: %s", test_name);
                $display("  a        = 0x%08h", test_a);
                $display("  b        = 0x%08h", test_b);
                $display("  alu_op   = 0x%0h", test_op);
                $display("  result   = 0x%08h, expected 0x%08h", result, expected_result);
                $display("  zero     = %0b, expected %0b", zero, expected_zero);
            end else begin
                $display("PASS: %s", test_name);
            end
        end
    endtask

    initial begin
        $dumpfile("waves/alu_tb.vcd");
        $dumpvars(0, alu_tb);

        tests_run    = 0;
        tests_failed = 0;

        check("ADD simple",        ALU_ADD, 32'd2,         32'd3,         32'd5);
        check("ADD wraparound",    ALU_ADD, 32'hFFFF_FFFF, 32'd1,         32'd0);
        check("SUB simple",        ALU_SUB, 32'd10,        32'd4,         32'd6);
        check("SUB zero result",   ALU_SUB, 32'd7,         32'd7,         32'd0);
        check("AND pattern",       ALU_AND, 32'hF0F0_1234, 32'h0FF0_FFFF, 32'h00F0_1234);
        check("OR pattern",        ALU_OR,  32'hF000_0000, 32'h0000_00FF, 32'hF000_00FF);
        check("XOR pattern",       ALU_XOR, 32'hAAAA_5555, 32'hFFFF_0000, 32'h5555_5555);

        $display("");
        $display("ALU tests run:    %0d", tests_run);
        $display("ALU tests failed: %0d", tests_failed);

        if (tests_failed == 0) begin
            $display("ALU TESTS PASSED");
            $finish;
        end else begin
            $fatal(1, "ALU TESTS FAILED");
        end
    end

endmodule