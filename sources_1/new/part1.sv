module part1( input clk, en_1, reset, [1:0] select,
              input [3:0] in,
              output [3:0] in3, in2, in1, in0 );
              
    logic [3:0] in3, in2, in1, in0;
              
    always_ff @(posedge clk) begin
        if (reset) begin
            in3 <= 0;
            in2 <= 0;
            in1 <= 0;
            in0 <= 0;
        end
        else if (en_1) begin
            case (select)
                2'b00:  in0 <= in;
                2'b01:  in1 <= in;
                2'b10:  in2 <= in;
                2'b11:  in3 <= in;
            endcase
        end
    end
    
endmodule