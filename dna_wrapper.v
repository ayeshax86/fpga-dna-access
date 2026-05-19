`timescale 1ns/1ps

module dna_wrapper (

    input  wire        CLK,
    input  wire        RST_n,
    input  wire        start,

    output wire [56:0] dna,
    output wire        done,
    output wire        busy

);

    // ------------------------------------------------------------
    // Instantiate DNA Reader
    // ------------------------------------------------------------
    dna_reader u_dna_reader (

        .CLK   (CLK),
        .RST_n (RST_n),
        .start (start),

        .dna   (dna),
        .done  (done),
        .busy  (busy)

    );

endmodule