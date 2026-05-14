`timescale 1ns/1ps


module dna_reader (


   input  logic        CLK,
   input  logic        RST_n,
   input  logic        start,


   output logic [56:0] dna,
   output logic        done,
   output logic        busy


);


   // ----------------------------------------------------------------
   // DNA_PORT signals
   // ----------------------------------------------------------------
   logic dout;
   logic din;
   logic read;
   logic shift;


   // ----------------------------------------------------------------
   // FSM
   // ----------------------------------------------------------------
   typedef enum logic [1:0] {
       IDLE,
       READ_PULSE,
       SHIFT_DNA,
       DONE_ST
   } state_t;


   state_t state, next_state;


   logic [5:0] bit_cnt;


   // ----------------------------------------------------------------
   // DNA primitive
   // ----------------------------------------------------------------
   DNA_PORT #(
       .SIM_DNA_VALUE(57'h123456789ABCDE)
   ) DNA_PORT_inst (
       .DOUT  (dout),
       .CLK   (CLK),
       .DIN   (din),
       .READ  (read),
       .SHIFT (shift)
   );


   // ----------------------------------------------------------------
   // Constant DIN
   // ----------------------------------------------------------------
   assign din = 1'b0;
   // Coonect this to DOUT of primitive to loop device dna.
   // If serial bits are given on this line they will append with
   // the output DNA line. 


   // ----------------------------------------------------------------
   // State register
   // ----------------------------------------------------------------
   always_ff @(posedge CLK or negedge RST_n) begin
       if (!RST_n)
           state <= IDLE;
       else
           state <= next_state;
   end


   // ----------------------------------------------------------------
   // next_state signal logic
   // ----------------------------------------------------------------
   always_comb begin


       next_state = state;


       case (state)


           IDLE: begin
               if (start)
                   next_state = READ_PULSE;
           end


           READ_PULSE: begin
               next_state = SHIFT_DNA;
           end


           SHIFT_DNA: begin
               if (bit_cnt == 6'd56)
                   next_state = DONE_ST;
           end


           DONE_ST: begin
               next_state = IDLE;
           end


       endcase
   end


   // ----------------------------------------------------------------
   // Output/control logic
   // ----------------------------------------------------------------
   always_comb begin


       read  = 1'b0;
       shift = 1'b0;


       busy  = 1'b1;
       done  = 1'b0;


       case (state)


           IDLE: begin
               busy = 1'b0;
           end


           READ_PULSE: begin
               read = 1'b1;
           end


           SHIFT_DNA: begin
               shift = 1'b1;
           end


           DONE_ST: begin
               done = 1'b1;
               busy = 1'b0;
           end


       endcase
   end


   // ----------------------------------------------------------------
   // Shift DNA into register
   // ----------------------------------------------------------------
   always_ff @(posedge CLK or negedge RST_n) begin


       if (!RST_n) begin
           dna     <= 57'd0;
           bit_cnt <= 6'd0;
       end
       else begin


           case (state)


               IDLE: begin
                   dna     <= 57'd0;
                   bit_cnt <= 6'd0;
               end


               SHIFT_DNA: begin
                   dna <= {dna[55:0], dout};
                   bit_cnt <= bit_cnt + 1'b1;
               end


           endcase
       end
   end


endmodule
