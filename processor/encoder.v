
module encoder(
  in,
  out
  );
 
  input wire [7:0] in; 
  output reg [2:0] out;
        
  always @ (*) begin
    case (in)
      8'h01 : out = 0;
      8'h02 : out = 1; 
      8'h04 : out = 2; 
      8'h08 : out = 3; 
      8'h10 : out = 4;
      8'h20 : out = 5; 
      8'h40 : out = 6; 
      8'h80 : out = 7;
   endcase
  end

endmodule
