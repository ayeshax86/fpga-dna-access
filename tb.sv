`timescale 1ns/1ps

module tb;


    // Testbench signals
    logic        CLK;
    logic        RST_n;
    logic        start;
    logic [56:0] dna;
    logic        done;
    logic        busy;

    // Instantiate the Device Under Test (DUT)
    dna_reader dut (
        .CLK   (CLK),
        .RST_n (RST_n),
        .start (start),
        .dna   (dna),
        .done  (done),
        .busy  (busy)
    );

    // Clock generation (50MHz -> 20ns period)
    always begin
        CLK = 0;
        #10;
        CLK = 1;
        #10;
    end

    // Stimulus process
    initial begin
        // Initialize signals
        RST_n = 1'b0;
        start = 1'b0;

        // Hold reset for 2 clock cycles
        repeat (2) @(posedge CLK);
        #1 RST_n = 1'b1; // Release reset safely after the edge
        
        repeat (2) @(posedge CLK);

        // Assert start with a delay after the clock edge
        @(posedge CLK);
        #1;             // <--- This vital delay fixes your simulation issue!
        start = 1'b1;

        // Hold start high for one clock cycle
        @(posedge CLK);
        #1;
        start = 1'b0;

        // Wait for the FSM to finish reading the 57 bits
        // It takes 1 cycle for READ_PULSE, 57 cycles for SHIFT_DNA, and 1 for DONE
        @(posedge done);
        
        repeat (5) @(posedge CLK);
        
        // End simulation
        $display("Simulation finished. Captured DNA: %h", dna);
        $finish;
    end

endmodule

/*

    logic        CLK;
    logic        RST_n;
    logic        start;

    logic [56:0] dna;
    logic        done;
    logic        busy;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------
    dna_reader dut (
        .CLK   (CLK),
        .RST_n (RST_n),
        .start (start),
        .dna   (dna),
        .done  (done),
        .busy  (busy)
    );

    // ------------------------------------------------------------
    // Clock generation
    // ------------------------------------------------------------
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    // ------------------------------------------------------------
    // Stimulus
    // ------------------------------------------------------------
    initial begin

        // init
        RST_n = 0;
        start = 0;

        // reset
        #20;
        RST_n = 1;

        // wait few clocks
        #20;

        // start pulse
        @(posedge CLK);
        start = 1;

        //@(posedge CLK);
        //start = 0;

        // wait for done
        wait(done == 1);

        // display DNA
        $display("-----------------------------------");
        $display("DNA READ COMPLETE");
        $display("DNA = %h", dna);
        $display("-----------------------------------");

        // wait little more
        #50;

        $finish;
    end

    // ------------------------------------------------------------
    // Monitor
    // ------------------------------------------------------------
    initial begin
        $monitor(
            "TIME=%0t | state_busy=%0b | done=%0b | dna=%h",
            $time,
            busy,
            done,
            dna
        );
    end

endmodule

*/