module TailLight(input rst, input clk, input l, input r, 
output reg lc, output reg lb, output reg la, 
output reg ra, output reg rb, output reg rc);
    
    reg [3:0] state, nextState;
    
    // various states
    parameter INIT = 4'b0000;
    parameter RA = 4'b0001;
    parameter RAB = 4'b0011;
    parameter RABC = 4'b0111;
    parameter LA = 4'b1000;
    parameter LAB = 4'b1100;
    parameter LABC = 4'b1110;

    // handle state register update on clock cycle
    always @ (posedge clk) begin
        if(rst)
            state <= INIT;
        else
            state <= nextState;
    end

    // next state logic
    always @(*) begin
        case(state)
            INIT:   nextState = l ? LA : r ? RA : INIT;
            RA:     nextState = RAB;
            RAB:    nextState = RABC;
            RABC:   nextState = l ? LA : r ? RA : INIT;
            LA:     nextState = LAB;
            LAB:    nextState = LABC;
            LABC:   nextState = l ? LA : r ? RA : INIT;
            default:nextState = INIT;
        endcase
    end

    // Output logic
    always @(*) begin
        case(state)
            INIT: begin
                lc <= 0;
                lb <= 0;
                la <= 0;
                ra <= 0;
                rb <= 0;
                rc <= 0;
            end
            RA: begin
                lc <= 0;
                lb <= 0;
                la <= 0;
                ra <= 1;
                rb <= 0;
                rc <= 0;
            end
            RAB: begin
                lc <= 0;
                lb <= 0;
                la <= 0;
                ra <= 1;
                rb <= 1;
                rc <= 0;
            end
            RABC: begin
                lc <= 0;
                lb <= 0;
                la <= 0;
                ra <= 1;
                rb <= 1;
                rc <= 1;
            end
            LA: begin
                lc <= 0;
                lb <= 0;
                la <= 1;
                ra <= 0;
                rb <= 0;
                rc <= 0;
            end
            LAB: begin
                lc <= 0;
                lb <= 1;
                la <= 1;
                ra <= 0;
                rb <= 0;
                rc <= 0;
            end
            LABC: begin
                lc <= 1;
                lb <= 1;
                la <= 1;
                ra <= 0;
                rb <= 0;
                rc <= 0;
            end
            default: begin
                lc <= 0;
                lb <= 0;
                la <= 0;
                ra <= 0;
                rb <= 0;
                rc <= 0;
            end
        endcase
    end

endmodule