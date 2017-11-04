`timescale 1ns / 1ps

module hamming_weight(inp,out,rst,clk,start,count);
  
  input  [7:0] inp;
  reg    [7:0] f_inp;
  output reg [4:0] out;
  input  start;
  input  clk,rst;
  output reg  [7:0]  count;
  reg    [7:0]ham_count;
  reg    [39:0]toFifo;
  reg    hmg_wgt;
  
  /// Fifo Signals
  reg    [39:0]data_in;
  reg    [39:0]f_d_out;
  reg    [39:0]dataOut;
  reg    push;
  reg    full;
  reg    empty;
  reg    pull;

  always@(posedge clk or posedge rst)begin

    if(rst) begin
      count <= 0;
      ham_count <= 0;
      push <= 0;
                
    end
        else if(start) begin
          count <= count + 1;
          push <= 0;
          //$display("-----Im in the start 1------");
        end
          else if(count == 1) begin
            toFifo[7:0] <= f_inp;
            count <= count + 1;
            ham_count <= ham_count + 1;
            push <= 0;
             //$display("-----Im in the loop count 1------");
          end 
            else if(count == 2) begin
              toFifo[15:8] = f_inp;
              count <= count + 1;
              ham_count <= ham_count + 1;
              //$display("-----Im in the loop count 2------");
              push <= 0;
            end
              else if(count == 3) begin
                toFifo[23:16] = f_inp;
                count <= count + 1;
                ham_count <= ham_count + 1;
                push <= 0;
              end
                else if(count == 4) begin
                  toFifo[31:24] = f_inp;
                  count <= count + 1;
                  ham_count <= ham_count + 1;
                  //$display("-----Im in the loop count 4------");
                  push <= 0;
                end
                  else if(count == 5) begin
                    toFifo[39:32] = f_inp;
                    count <= 1;
                    ham_count <= ham_count + 1;
                    push <= 0;
                  end
                    else if(ham_count == 128) begin
                      ham_count <= 0;
                      push <= 0;
                    end
                      else if(ham_count == 127)begin
                        data_in <= toFifo;
                        push <= 1;
                        hmg_wgt <= 0;
                        //$display("-----Im in the loop 127------");
                      end
end

// taking the data and cointing the number of ones
always @(posedge clk or posedge rst) begin 

  if(!empty) begin
     pull <= 1;
    end
      else if(pull == 1) begin
        dataOut <= f_d_out;
          for(int i = 0; i < 40; i=i+1 ) begin
            if (dataOut[i] == 1)begin
              hmg_wgt = hmg_wgt + 1;
              //$display("-----Im in the loop------");
            end
          end 
      end
  else begin

    out <= hmg_wgt;
    pull <= 0;    
  end  
end



fifo F1(.wr_en(push),.reset(rst),.full(full),.empty(empty),.clk(clk),.rd_en(pull),.data_in(data_in),.data_out(f_d_out));


         
endmodule


//////////////
module fifo (wr_en, reset,full,empty,clk,rd_en,data_in,data_out);
parameter width=40;
parameter depth=26; 


input wr_en,rd_en,reset,clk;
output full,empty;
input [width-1:0] data_in;
output reg [width-1:0] data_out;
reg  [width-1 :0 ] data_mem [depth-1 : 0 ];
reg [4 :0 ] wr_ptr,rd_ptr;

assign full = ((wr_ptr ==26)&&(rd_ptr==0))?1:((rd_ptr == wr_ptr +1)?1:0); 
assign empty = (rd_ptr == wr_ptr)?1:0;

always @ (posedge clk,posedge reset)
begin
  if (reset)
  begin
    wr_ptr <= 0;
    rd_ptr <= 0;
  end
  else
  begin
    if (rd_en && !empty)
    begin
      data_out <= data_mem[rd_ptr];
      rd_ptr <= rd_ptr +1;
    end
    else
    begin
      data_out <= data_out;
      rd_ptr <= rd_ptr;
    end
    if (wr_en && !full)
    begin
      //$display("%0t data written = %0h",$time,data_in);
      data_mem[wr_ptr] <= data_in;
      wr_ptr <= wr_ptr +1;
    end
    else
    begin
      data_mem[wr_ptr] <= data_mem[wr_ptr];
      wr_ptr <= wr_ptr;
    end
  end
end

endmodule

//////////////





TestBench
////////
 
   `timescale 1ns / 1ps
  module hw_test;
    reg [7:0]inp;
  reg start;
  reg clk,rst;
    wire [4:0]out;
    wire [7:0]count;
    hamming_weight hm(.inp(inp),.out(out),.rst(rst),.clk(clk),.start(start),.count(count));
  
    initial begin 
    $dumpfile("hamming_weight.vcd");
    $dumpvars(1);  
    end 
    
    always begin clk = 1; #10;
    clk = 0; #10;
    end
    
    initial begin
    rst=1;
     #20; 
    rst=0;
     #20; 
    start=1;
     #20;  
   start=0; inp=10000000; #20;inp=10000000; #20;
   inp=10000000; #20;  inp=10000000;    #20;
    inp=10000000; #20; inp=10000000; #20;
    inp=10000000;#20;  inp=10000000;#20;
    inp=10000000;#20;  inp=10000000;#20;
    inp=10000000;#20;  inp=10000000;#20;
    inp=10000000; #20; inp=10000000;#20;
    inp=10000000; #20; inp=10000000;#20;
    inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
	inp=10000000; #20; inp=10000000;#20;
    
	#10000000000;
 	$finish;
      
  end
  endmodule
  
  
  
  C++ code
  #include <iostream>

using namespace std;

int main()
{
   int a[512]={1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
  };
   int count=0;
  cout << "Enter the elements" << endl;
   for(int i=0;i<512;i++){
   if(a[i]==1)
   count=count+1;}
   cout<<count;
   
   return 0;
}
