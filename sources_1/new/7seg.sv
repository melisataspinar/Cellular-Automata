module SevSeg_4digit( input clk, enable_sevseg,
                      input [3:0] in0, in1, in2, in3, 
                      output logic a, b, c, d, e, f, g, dp, 
                      output [3:0] an );
    logic [3:0] val; 
    logic [3:0] den; 
    logic [6:0] leds; 
    localparam number = 18;
    logic [ number-1:0 ] count = { number{1'b0} };
    
    // ********************************************
    
    always@ (posedge clk)
	   count <= count + 1;
 
    // ********************************************
    
    always_comb
    begin
        den = 4'b1111;  
        val = in0;
 
        case( count[ number-1:number-2 ] ) 
        
            2'b00 : begin
                den = 4'b1110;
                val = in0;
            end     
            2'b01: begin
                den = 4'b1101;
                val = in1;
            end 
            2'b10: begin
                den = 4'b1011;
                val = in2;
            end
            2'b11: begin
                den = 4'b0111;
                val = in3;
            end
            
        endcase
    end
 

   
    // ********************************************
    
    always_comb
    begin 
        leds = 7'b1111111; 
        case( val )
           4'b0000 : leds = 7'b1111110;  
           4'b0001 : leds = 7'b0110000;  
           4'b0010 : leds = 7'b1101101;  
           4'b0011 : leds = 7'b1111001;  
           4'b0100 : leds = 7'b0110011;  
           4'b0101 : leds = 7'b1011011; 
           4'b0110 : leds = 7'b1011111;  
           4'b0111 : leds = 7'b1110000;  
           4'b1000 : leds = 7'b1111111; 
           4'b1001 : leds = 7'b1111011;  
           4'b1010 : leds = 7'b1110111;  
           4'b1011 : leds = 7'b0011111; 
           4'b1100 : leds = 7'b1001110;  
           4'b1101 : leds = 7'b0111101; 
           4'b1110 : leds = 7'b1001111;  
           4'b1111 : leds = 7'b1000111;  
        
           default : leds = 7'b0111111; 
        endcase
    end
     
    assign an = den; 
    
    // ********************************************
    
    always_comb begin
        dp = 1'b1; 
        if ( enable_sevseg ) begin
            {a,b,c,d,e,f,g} = ~leds; 
        end
        else begin
            {a,b,c,d,e,f,g} = 7'b1111111; 
        end
    end
    
    
     
endmodule


