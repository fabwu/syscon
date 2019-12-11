`timescale 1ns / 1ps

// A 2K x 32 dual-ported block ram.  This is a wrapper around RAMB36

module DM(clk, wrDat, wrAdr, wrEnb, rdDat, rdAdr);
input clk;
input [31:0] wrDat;
input [31:0] wrAdr, rdAdr;
input wrEnb;
output [31:0] rdDat;

parameter BN = 2; //BRAM numbers
localparam AW = (BN == 1)? 9:
                (BN == 2)? 10:
					 (BN == 3)? 11:
					 (BN == 4)? 11:
					 (BN == 5)? 12:
					 (BN == 6)? 12:
					 (BN == 7)? 12:
					 (BN == 8)? 12:
					 13;
					 
//port A
wire [31:0] wda;  //write data, port A
wire [AW:0] aa; //address, port A
wire [BN-1:0] wea; //write enable, port A

//port B
wire [AW:0] ab;  //address, port B

//temp signals
wire[31:0] rdb[BN-1:0];
reg[AW-9:0] Adr_sel; 

assign wda = wrDat;
assign aa = {1'b0, wrAdr[AW-1:0]};
assign ab = {1'b0, rdAdr[AW-1:0]};

genvar i;

generate
for (i = 0; i< BN; i = i+1)
begin: genWea
  assign wea[i] = (wrEnb & (aa[AW: 9] == i));
end // genwea
endgenerate

always @(posedge clk)
    Adr_sel <= ab[AW: 9];

assign rdDat = rdb[Adr_sel];	

generate
  for (i = 0; i< BN; i = i+1)
  begin: RAMB_insts
	// RAMB16_S36_S36: Spartan-3/3E 512 x 32 + 4 Parity bits Dual-Port RAM
	// Xilinx HDL Libraries Guide, version 11.2
	RAMB16_S36_S36 #(
	.INIT_A(36'h000000000), // Value of output RAM registers on Port A at startup
	.INIT_B(36'h000000000), // Value of output RAM registers on Port B at startup
	.SRVAL_A(36'h000000000), // Port A output value upon SSR assertion
	.SRVAL_B(36'h000000000), // Port B output value upon SSR assertion
	.WRITE_MODE_A("WRITE_FIRST"), // WRITE_FIRST, READ_FIRST or NO_CHANGE
	.WRITE_MODE_B("WRITE_FIRST"), // WRITE_FIRST, READ_FIRST or NO_CHANGE
	.SIM_COLLISION_CHECK("ALL"), // "NONE", "WARNING_ONLY", "GENERATE_X_ONLY", "ALL"
	// The following INIT_xx declarations specify the initial contents of the RAM
	// Address 0 to 127
	.INIT_00(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_01(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_02(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_03(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_04(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_05(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_06(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_07(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_08(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_09(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_0A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_0B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_0C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_0D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_0E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_0F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	// Address 128 to 255
	.INIT_10(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_11(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_12(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_13(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_14(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_15(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_16(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_17(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_18(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_19(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_1A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_1B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_1C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_1D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_1E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_1F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	// Address 256 to 383
	.INIT_20(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_21(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_22(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_23(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_24(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_25(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_26(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_27(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_28(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_29(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_2A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_2B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_2C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_2D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_2E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_2F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	// Address 384 to 511
	.INIT_30(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_31(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_32(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_33(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_34(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_35(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_36(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_37(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_38(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_39(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_3A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_3B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_3C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_3D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_3E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	.INIT_3F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
	// The next set of INITP_xx are for the parity bits
	// Address 0 to 127
	.INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
	.INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
	// Address 128 to 255
	.INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
	.INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
	// Address 256 to 383
	.INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
	.INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
	// Address 384 to 511
	.INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
	.INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000)
	) RAMB16_S36_S36_inst (
	.DOA(), // Port A 32-bit Data Output
	.DOB(rdb[i]), // Port B 32-bit Data Output
	.DOPA(), // Port A 4-bit Parity Output
	.DOPB(), // Port B 4-bit Parity Output
	.ADDRA(aa[8:0]), // Port A 9-bit Address Input
	.ADDRB(ab[8:0]), // Port B 9-bit Address Input
	.CLKA(clk), // Port A Clock
	.CLKB(clk), // Port B Clock
	.DIA(wda[31:0]), // Port A 32-bit Data Input
	.DIB(32'b0), // Port B 32-bit Data Input
	.DIPA(4'b0000), // Port A 4-bit parity Input
	.DIPB(4'b0000), // Port-B 4-bit parity Input
	.ENA(1'b1), // Port A RAM Enable Input
	.ENB(1'b1), // Port B RAM Enable Input
	.SSRA(1'b0), // Port A Synchronous Set/Reset Input
	.SSRB(1'b0), // Port B Synchronous Set/Reset Input
	.WEA(wea[i]), // Port A Write Enable Input
	.WEB(1'b0) // Port B Write Enable Input
	);
	// End of RAMB16_S36_S36_inst instantiation
  end
endgenerate

//`include "dat1.v"
//`include "dat2.v"
//`include "dat3.v"
//`include "dat4.v"
				 
endmodule