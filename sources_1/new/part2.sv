module part2( input logic clk, en_1, en_2, reset, [1:0] select, store,
              input logic [3:0] in,
              output logic a,b,c,d,e,f,g,dp, [3:0] an, [15:0] LED, [63:0]stored );

    logic [3:0] in3, in2, in1, in0;
    
    part1 part1_module(clk,en_1,reset,select,in,in3,in2,in1,in0);
    
    SevSeg_4digit sev_seg(clk, 1, in0, in1, in2, in3, a, b, c, d, e, f, g, dp, an);       
    
    always_ff @(posedge clk) begin
        if (reset) begin
            stored = 0;
        end
        else if (en_2) begin
            case (store)
                2'b00:  stored[15:0]  = {in3,in2,in1,in0};
                2'b01:  stored[31:16] = {in3,in2,in1,in0};
                2'b10:  stored[47:32] = {in3,in2,in1,in0};
                2'b11:  stored[63:48] = {in3,in2,in1,in0};
            endcase
        end
    end     
             
    always_comb begin
        case (store)
            2'b00:  LED <= stored[15:0];
            2'b01:  LED <= stored[31:16];
            2'b10:  LED <= stored[47:32];
            2'b11:  LED <= stored[63:48];
        endcase
    end
    
endmodule