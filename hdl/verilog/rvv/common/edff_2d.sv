module edff_2d (/*AUTOARG*/
   // Outputs
   q,
   // Inputs
   clk, rst_n, en, d
   );
   
    parameter REGISTER_WIDTH = 32;
    parameter NUM_OF_REGISTERS = 8;
    parameter RESET_STATE = 0;     
    
    input    clk;
    // synopsys sync_set_reset "rst_n"
    input    rst_n;
    input [NUM_OF_REGISTERS-1:0]   en;
    input [NUM_OF_REGISTERS*REGISTER_WIDTH-1 : 0 ] d ;

    output [NUM_OF_REGISTERS*REGISTER_WIDTH-1 : 0 ] q;
                                                             
    integer i;            
    reg [NUM_OF_REGISTERS*REGISTER_WIDTH-1 : 0 ] q;

    always @(posedge clk or negedge rst_n) begin  
        if ( !rst_n ) begin
          for (i = 0; i <= NUM_OF_REGISTERS-1; i = i + 1)
            q[REGISTER_WIDTH*(i+1)-1 -: REGISTER_WIDTH] <= RESET_STATE;
        end else begin
          for (i = 0; i <= NUM_OF_REGISTERS-1; i = i + 1)
            if (en[i]) begin
                q[REGISTER_WIDTH*(i+1)-1 -: REGISTER_WIDTH] <= d[REGISTER_WIDTH*(i+1)-1 -: REGISTER_WIDTH];
            end //else hold old value
        end 
    end
 
endmodule
