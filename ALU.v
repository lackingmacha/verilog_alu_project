module alu #(parameter integer W=16, parameter integer OPW=4)
(input [W-1:0]x,
 input [W-1:0]y,    
 input [OPW-1:0]opcode,
 
 output reg [W-1:0]result,
 output sign,
 output zero,
 output reg carry,
 output parity,
 output reg overflow);
 localparam ADD=4'b0000, SUB=4'b0001, AND=4'b0010, OR=4'b0011, XOR=4'b0100, NOT=4'b0101, LSL=4'b0110, LSR=4'b0111, ASR=4'b1000, ROL=4'b1001, ROR=4'b1010, CMP=4'b1011;
 

 always @(*) begin
 $display("ALU triggered at time %0t", $time);
 $display("Time=%0t opcode=%b ADD=%b", $time, opcode, ADD);

 result   = 0;
 carry    = 1'b0;
 overflow = 0;

 case(opcode)
 
 ADD: begin 
 {carry, result}=x+y;
 overflow=(x[W-1]&y[W-1]&~result[W-1])|(~x[W-1]&~y[W-1]&result[W-1]);
 end
 
 SUB: begin
 result=x-y;
 carry=(x>=y);
 overflow=(x[W-1]&~y[W-1]&~result[W-1])|(~x[W-1]&y[W-1]&result[W-1]);
 end
 
 AND: result=x&y;
 
 OR: result=x|y;
 
 XOR: result=x^y;
 
 NOT: result=~x;
 
 LSL: begin
 result=x<<y[$clog2(W)-1:0];
 if(y[$clog2(W)-1:0] !=0)
 carry= x[W-y[$clog2(W)-1:0]];
 end
 
 
 LSR: begin
 result=x>>y[$clog2(W)-1:0];
 if(y[$clog2(W)-1:0] !=0)
 carry= x[y[$clog2(W)-1:0]-1];
 end
 
 
 ASR: begin
 result=$signed(x)>>>y[$clog2(W)-1:0]; 
 if(y[$clog2(W)-1:0] !=0)
 carry = x[y[$clog2(W)-1:0] - 1];
 end 
 
 ROL: begin
 result=(x<<y[$clog2(W)-1:0]) | (x>>(W-y[$clog2(W)-1:0]));
 if(y[$clog2(W)-1:0] !=0)
 carry=x[W- y[$clog2(W)-1:0]];
 end
 
 
 ROR: begin
 result = (x>>y[$clog2(W)-1:0]) | (x<<(W - y[$clog2(W)-1:0]));
 if(y[$clog2(W)-1:0] !=0)
 carry= x[y[$clog2(W)-1:0]-1];
 end
 
 CMP: begin
 result=x-y;
 carry=x>=y;
 overflow = (x[W-1] & ~y[W-1] & ~result[W-1])|(~x[W-1] & y[W-1] & result[W-1]);
 end
  
 endcase
 end
 assign zero=~|result;
 assign sign= result[W-1];
 assign parity= ~^result;
endmodule