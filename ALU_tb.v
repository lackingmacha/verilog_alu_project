`timescale 1ns/1ps
module alu_tb;
parameter W=16;
parameter OPW=4;

reg [W-1:0]x_tb;
reg [W-1:0]y_tb;
reg [OPW-1:0]opcode_tb;

wire [W-1:0]result_tb;
wire sign_tb;
wire zero_tb;
wire carry_tb;
wire parity_tb;
wire overflow_tb;

reg [W-1:0] exp_result;
reg exp_sign;
reg exp_zero;
reg exp_carry;
reg exp_parity;
reg exp_overflow;

alu #(.W(W),.OPW(OPW)) dut(.x(x_tb), .y(y_tb), .opcode(opcode_tb),
 .result(result_tb), .sign(sign_tb), .zero(zero_tb), .carry(carry_tb),
 .parity(parity_tb), .overflow(overflow_tb));
localparam [OPW-1:0]
    ADD = 4'b0000,
    SUB = 4'b0001,
    AND = 4'b0010,
    OR  = 4'b0011,
    XOR = 4'b0100,
    NOT = 4'b0101,
    LSL = 4'b0110,
    LSR = 4'b0111,
    ASR = 4'b1000,
    ROL = 4'b1001,
    ROR = 4'b1010,
    CMP = 4'b1011;

task automatic reference_model;
input [W-1:0]x_ref;
input [W-1:0]y_ref;
input [OPW-1:0]opcode_ref;

output reg [W-1:0]exp_result;
output reg exp_sign;
output reg exp_zero;
output reg exp_carry;
output reg exp_parity;
output reg exp_overflow;
//local variables
reg [W:0]full;
integer k;
begin
$display("REF time=%0t x=%h y=%h opcode=%b",
$time, x_ref, y_ref, opcode_ref);
exp_result=0;
exp_carry=0;
exp_overflow=0;

k = y_ref & (W - 1);
case(opcode_ref)
ADD: begin
full=x_ref+y_ref;
exp_result=full[W-1:0];
exp_carry=full[W];
exp_overflow=(($signed(x_ref) >= 0 && $signed(y_ref) >= 0 && $signed(exp_result) < 0) ||
($signed(x_ref) <  0 && $signed(y_ref) <  0 && $signed(exp_result) >= 0));
end

SUB:begin
full=x_ref-y_ref;
exp_result=full[W-1:0];
exp_carry=(x_ref>=y_ref); 
exp_overflow= (($signed(x_ref) >= 0 && $signed(y_ref) < 0 && $signed(exp_result) < 0) ||
($signed(x_ref) <  0 && $signed(y_ref) >= 0 && $signed(exp_result) >= 0));
end

AND: exp_result=x_ref&y_ref;
OR: exp_result=x_ref|y_ref;
XOR: exp_result=x_ref^y_ref;
NOT: exp_result=~x_ref;

LSL: begin
exp_result=(x_ref<<k);
if (k!=0)
exp_carry=x_ref[W-k];
end

LSR: begin
exp_result=(x_ref>>k);
if (k!=0)
exp_carry=x_ref[k-1];
end

ASR: begin
exp_result=$signed(x_ref)>>>k;
if (k!=0)
exp_carry=x_ref[k-1];
end

ROL: begin
exp_result= (x_ref<<k) | (x_ref>>(W-k));
if (k!=0)
exp_carry=x_ref[W-k];
end

ROR: begin
exp_result= (x_ref>>k) | (x_ref<<(W-k));
if (k!=0)
exp_carry=x_ref[k-1];
end

CMP: begin
full = x_ref - y_ref;
exp_result = full[W-1:0];
exp_carry  = (x_ref >= y_ref);
exp_overflow =(($signed(x_ref) >= 0 && $signed(y_ref) < 0 && $signed(exp_result) < 0) ||
($signed(x_ref) <  0 && $signed(y_ref) >= 0 && $signed(exp_result) >= 0));
end

endcase

exp_zero   = (exp_result == 0);
exp_sign   = exp_result[W-1];
exp_parity = ~^exp_result;

end
endtask

task automatic check_results;
begin
if (result_tb !== exp_result || sign_tb !== exp_sign || 
zero_tb !== exp_zero || carry_tb !== exp_carry || parity_tb !== exp_parity || overflow_tb !== exp_overflow)
begin
$display("ERROR:");
$display("x=%h y=%h opcode=%b", x_tb, y_tb, opcode_tb);
$display("DUT : r=%h s=%b z=%b c=%b p=%b o=%b", result_tb, sign_tb, zero_tb, carry_tb, parity_tb, overflow_tb);
$display("EXP : r=%h s=%b z=%b c=%b p=%b o=%b", exp_result, exp_sign, exp_zero, exp_carry, exp_parity, exp_overflow);
$fatal;
end
end
endtask

task apply_check;
input [W-1:0]i_x,i_y;
input [OPW-1:0]i_op;
begin
x_tb=i_x;
y_tb=i_y;
opcode_tb=i_op;

#1;
reference_model(x_tb, y_tb, opcode_tb, exp_result, exp_sign, exp_zero, exp_carry, exp_parity, exp_overflow);
check_results();
end
endtask




initial begin
$display("Starting Directing Tests...");
//ADD CASES
apply_check(16'hffff,16'h0001, ADD);
apply_check(16'h7fff,16'h0001, ADD);
apply_check(16'hffff,16'hffff, ADD);
apply_check(16'h8000,16'h8000, ADD);

//SUB CASES
apply_check(16'h1010,16'h1010, SUB);
apply_check(16'h0101,16'h1010, SUB);
apply_check(16'h7fff,16'hffff, SUB);
apply_check(16'h8000,16'h0001, SUB);

//AND CASES
apply_check(16'hFFFF,16'h0000, AND);
apply_check(16'h8000,16'hFFFF, AND);
apply_check(16'hAAAA,16'h5555, AND);

//OR CASES
apply_check(16'hAAAA,16'h5555, OR);
apply_check(16'h0000,16'h0000, OR);
apply_check(16'h0001,16'h8000, OR);

//XOR CASES
apply_check(16'h1234,16'h1234, XOR);
apply_check(16'hAAAA,16'h5555, XOR);
apply_check(16'h8000,16'h0001, XOR);

//NOT CASES
apply_check(16'h0000,16'h0000, NOT);
apply_check(16'hFFFF,16'h0000, NOT);
apply_check(16'h8000,16'h0000, NOT);

//LSL CASES
apply_check(16'h1234,0, LSL);
apply_check(16'h8001,1, LSL);
apply_check(16'h0001,15, LSL);
apply_check(16'h8000,1, LSL);

//LSR CASES
apply_check(16'h1234,0, LSR);
apply_check(16'h0001,1, LSR);
apply_check(16'h8000,1, LSR);

//ASR CASES
apply_check(16'h7FFF,1, ASR);
apply_check(16'h8000,1, ASR);
apply_check(16'hF000,4, ASR);

//ROL CASES
apply_check(16'h1234,0, ROL);
apply_check(16'h8001,1, ROL);
apply_check(16'h0001,15, ROL);

//ROR CASES
apply_check(16'h1234,0, ROL);
apply_check(16'h8001,1, ROL);
apply_check(16'h8000,15, ROL);

//CMP CASES
apply_check(16'h1234,16'h1234, CMP);
apply_check(16'h8000,16'h0001, CMP);
apply_check(16'h7FFF,16'hFFFF, CMP);
apply_check(16'h0003,16'h0005, CMP);


$display("DIRECTED TESTS PASSED");

$display("Running Randomized Tests...");

begin: random_loop
integer i;
for(i=0;i<500;i=i+1) begin
apply_check($random,$random,$urandom%12);
end
end
$display("RANDOMIZED TESTS PASSED");


$display("ALL TESTS PASSED");
$finish;
end
endmodule