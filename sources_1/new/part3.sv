module dbncr( input logic in,clk, output logic out );
    
    logic on;
    int i = 0, limit = 20000000;
    
    always_ff @( posedge clk ) 
    begin
        if ( in & (~on) ) begin
            on <= 1; out <= 1;
        end
       
       // incrementing the counting
        else if ( (i < limit) & on  ) begin
            i <= i + 1; out <= 1;
        end
        
        else if ( (i >= limit) )
        begin
            if ( in ) begin
                out <= 1;
            end
            
            // going back to all zeros
            else begin
                on <= 0; out <= 0; i <= 0;
            end
        end
        
        // going back to the initial all zeros
        else begin
            on <= 0; out <= 0; i <= 0;
        end
    end
endmodule




module part3( input logic clk, reset, btnC, btnU, btnR, btnD, btnL,
              input logic [1:0] select, store, 
              input logic [3:0] in,
              output logic a,b,c,d,e,f,g,dp, [3:0]an, [15:0]LED,
              output logic shcp, stcp, mr, oe, ds, [7:0] rowsOut);
    
    int score;
    logic newClk;
    clock_divider div(clk,2'b10,newClk);
    logic dispEn;
    
    logic [7:0][7:0]state, nextState;
    logic [63:0] stored;
    logic gameOn;
    
    logic restart;
    assign restart = btnC;
    

    
    logic gp1,gp2,gp3,gp4;
    dbncr db1( btnU, clk, gp1);
    dbncr db2( btnR, clk, gp2);
    dbncr db3( btnD, clk, gp3);
    dbncr db4( btnL, clk, gp4);
    
    
    logic en_1, en_2;
    assign en_1 = btnL;
    assign en_2 = btnR;
    
    logic a1,b1,c1,d1,e1,f1,g1,dp1;
    logic [3:0]an1;
    logic a2,b2,c2,d2,e2,f2,g2,dp2;
    logic [3:0]an2;
    
    logic [15:0] LEDout;
    part2 p2( clk, (~gameOn)&en_1, (~gameOn)&en_2, reset, select, store,
              in,
              a1,b1,c1,d1,e1,f1,g1,dp1, an1, LEDout, stored );
    
    
    logic [3:0] in3, in2, in1, in0;
    SevSeg_4digit sevseg( clk, dispEn, in0, in1, in2, in3, a2, b2, c2, d2, e2, f2, g2, dp2, an2);

    always_comb begin
        in0 = score % 10;
        in1 = (score % 100)/10;
        in2 = (score % 1000)/100;
        in3 = (score % 10000)/1000;
        
        if ( gameOn ) begin
            a = a2; b = b2; c = c2; d = d2; e = e2; f = f2; g = g2; dp = dp2; an = an2;
            LED = 0;
        end
        else begin
            a = a1; b = b1; c = c1; d = d1; e = e1; f = f1; g = g1; dp = dp1; an = an1;
            LED = LEDout;
        end
    end
    
    always_ff @( posedge newClk ) begin
        if ( gameOn ) begin
            if ( state == 0 ) begin
                dispEn <= ~dispEn;
            end
            else begin
                dispEn <= 1;
            end
        end
        else begin
            dispEn <= 1;
        end
    end
    
    
    logic btnPressed;
    logic counting;
    int i;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            gameOn <= 0;
            btnPressed <= 0;
            counting <= 0;
            i <= 0;       
        end
        else if (restart) begin
            gameOn <= 1;
            btnPressed <= 0;
            counting <= 0;
            i <= 0;   
            state[0] <= stored[7:0];
            state[1] <= stored[15:8];
            state[2] <= stored[23:16];
            state[3] <= stored[31:24];
            state[4] <= stored[39:32];
            state[5] <= stored[47:40];
            state[6] <= stored[55:48];
            state[7] <= stored[63:56];
            score <= 0;
        end
        else if (gameOn) begin
            if ( (~btnPressed) & (gp1|gp2|gp3|gp4) ) begin
                counting <= 1;
                i <= 0;
                btnPressed <= 1;
                if ( state != 0 ) score <= score + 1;
            end
            else if ( btnPressed & (~(gp1|gp2|gp3|gp4)) ) begin
                btnPressed <= 0;
            end  
            else begin    
                btnPressed <= btnPressed;
                
                if ( counting ) begin
                    i <= i+1;
                end
                
                if ( i >= 1000 ) begin
                    counting <= 0;
                    i <= 0;
                    state <= nextState;
                end
                else begin
                    counting <= counting;
                end
            end
        end
    end
    
    nextStateModule next_state_module(clk,state,gp1,gp2,gp3,gp4,nextState);
    
    logic [7:0][7:0]dataIn;
    assign dataIn[0] = state[7];
    assign dataIn[1] = state[6];
    assign dataIn[2] = state[5];
    assign dataIn[3] = state[4];
    assign dataIn[4] = state[3];
    assign dataIn[5] = state[2];
    assign dataIn[6] = state[1];
    assign dataIn[7] = state[0];
    converter conv(clk, dataIn, rowsOut, shcp, stcp, mr, oe, ds );
endmodule

module nextStateModule( input logic clk, [7:0][7:0]state,
                        input logic gp1,gp2,gp3,gp4,
                        output logic [7:0][7:0]nextState);
    
    int i,j;
    int group;
    groups gr(i,j,group);
    
    int mygrp;
    
    always_comb begin
        if ( gp4 ) mygrp = 4;
        else if ( gp3 ) mygrp = 3;
        else if ( gp2 ) mygrp = 2;
        else if ( gp1 ) mygrp = 1;
        else mygrp = 0;
    end
    
    logic nextCellState;
    cellState cS( state[(i-1)%8][j], state[i][(j+1)%8],
                  state[(i+1)%8][j], state[i][(j-1)%8], nextCellState );
    
    always_ff @(posedge clk) begin
        if ( mygrp == group ) begin
            nextState[i][j] = nextCellState;
        end 
        else begin
            nextState[i][j] = state[i][j];
        end 
        j <= j+1;
        
        if ( j >= 8 ) begin
            i <= i+1;
            j <= 0;
        end
        
        if ( i >= 8 ) begin
            i <= 0;
        end
    end
    
                        
endmodule

module groups( input int row, col,
               output int group );

    int groups[7:0][7:0];
    
    assign groups[0] = '{3,4,3,4,2,3,2,3};
    assign groups[1] = '{2,1,2,1,1,4,1,4};
    assign groups[2] = '{3,4,3,4,2,3,2,3};
    assign groups[3] = '{2,1,2,1,1,4,1,4};
    assign groups[4] = '{2,3,2,3,4,3,4,3};
    assign groups[5] = '{1,4,1,4,1,2,1,2};
    assign groups[6] = '{2,3,2,3,4,3,4,3};
    assign groups[7] = '{1,4,1,4,1,2,1,2};
    
    int temp [7:0];
    assign temp = groups[row[2:0]];
    
    assign group = temp[7-col[2:0]];
endmodule               

module cellState( input logic N, E, S, W,
                  output logic nextState );

    always_comb begin
        case ( {N,E,W,S} )
            4'b0000: nextState = 0;
            4'b0001: nextState = 0;
            4'b0010: nextState = 0;
            4'b0011: nextState = 1;
            4'b0100: nextState = 0;
            4'b0101: nextState = 1;
            4'b0110: nextState = 0;
            4'b0111: nextState = 0;
            4'b1000: nextState = 1;
            4'b1001: nextState = 0;
            4'b1010: nextState = 1;
            4'b1011: nextState = 0;
            4'b1100: nextState = 0;
            4'b1101: nextState = 1;
            4'b1110: nextState = 1;
            4'b1111: nextState = 0;
        endcase
    end
    
endmodule

module clock_divider( input logic clk, [1:0]speed, output logic myclk );
    int counterLimit = 100000000;
    int counter = 0; 
    
    always @(posedge clk) begin
        counter <= counter + 1;
        if ( counter >= counterLimit ) begin
            counter <= 0;
            myclk <= ~myclk;
        end
        
        //sets the counterlimit according to speed
        case ( speed ) 
            2'b00:  begin counterLimit <= 12500000; end
            2'b01:  begin counterLimit <= 25000000; end
            2'b10:  begin counterLimit <= 50000000; end
            2'b11:  begin counter <= 0; counterLimit <= 5000000; end
            default: counterLimit <= 100000000;
        endcase
    end
endmodule