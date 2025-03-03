module AddressComparator(
    input [22:0] AddressBus,
    input [22:0] TagData,
    output reg Hit_H
);

  always @(AddressBus or TagData) begin
      if (AddressBus == TagData) begin
          Hit_H = 1;
      end else begin
          Hit_H = 0;
      end
  end

endmodule