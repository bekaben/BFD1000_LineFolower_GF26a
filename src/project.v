/*
 * Copyright (c) 2026 Belkacem BENADDA
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_BFD100_Logic (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    assign s1 = ui_in[0];
    assign s2 = ui_in[1];
    assign s3 = ui_in[2];
    assign s4 = ui_in[3];
    assign s5 = ui_in[4];
    assign Clip = ui_in[5];
    assign Near = ui_in[6];
    assign PWM = ui_in[7];
    
    reg REnL=0, DirL=0, REnR=0, DirR=0;
    wire EnL = REnL & PWM;
    assign uo_out[0] = EnL;
    assign uo_out[1] = DirL;
    wire EnR = REnR & PWM;
    assign uo_out[4] = EnR;
    assign uo_out[5] = DirR;
    
    wire Out1L, Out2L, Out1R, Out2R;
    assign uo_out[2] = Out1L;
    assign uo_out[3] = Out2L;
    assign uo_out[6] = Out1R;
    assign uo_out[7] = Out2R;
    
    assign Out1L = EnL & ~DirL;
    assign Out2L = EnL & DirL;
    assign Out1R = EnR & ~DirR;
    assign Out2R = EnR & DirR;
    
    always @(posedge clk or posedge Clip or posedge Near or negedge rst_n) begin
       if(!rst_n || Clip || Near)begin
            REnL<= 0;
            REnR<= 0;
            DirL <= 0;
            DirR <= 0;
       end
       else begin
            REnL <= (s1&s2&s3&~s4)|(s1&s2&s3&~s5)|(s1&s2&~s3&s5)|(s1&s2&~s4&s5)|(~s1&~s2&~s3&~s4&~s5)|(~s1&s3&s4&s5);
            DirL <= (s1&s2&s3&~s4)|(s1&s2&s3&~s5)|(s1&s2&~s3&s5)|(s1&s2&~s4&s5)|(~s1&~s2&~s3&~s4&~s5);
            REnR <= (s1&s2&s3&~s5)|(s1&~s2&s4&s5)|(s1&~s3&s4&s5)|(~s1&~s2&~s3&~s4&~s5)|(~s1&s3&s4&s5)|(~s2&s3&s4&s5);
            DirR <= (s1&~s2&s4&s5)|(s1&~s3&s4&s5)|(~s1&~s2&~s3&~s4&~s5)|(~s1&s3&s4&s5)|(~s2&s3&s4&s5);
        end
    end
 
  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule
