/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Claire Xenia Wolf <claire@yosyshq.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

//`ifndef PICORV32_REGS
//`ifdef PICORV32_V
//`error "picosoc.v must be read before picorv32.v!"
//`endif
//
//`define PICORV32_REGS picosoc_regs
//`endif

`ifndef PICOSOC_MEM
`define PICOSOC_MEM picosoc_mem
`endif

// this macro can be used to check if the verilog files in your
// design are read in the correct order.
`define PICOSOC_V

module picosoc (
`ifdef USE_POWER_PINS	
	inout vccd1,	// User area 1 1.8V supply
	inout vssd1,	// User area 1 digital ground
`endif	
	input clk,
	input resetn,

	output        iomem_valid,
	input         iomem_ready,
	output [ 3:0] iomem_wstrb,
	output [31:0] iomem_addr,
	output [31:0] iomem_wdata,
	input  [31:0] iomem_rdata,

	input  irq_5,
	input  irq_6,
	input  irq_7,

	output ser_tx,
	input  ser_rx,

	output flash_csb,
	output flash_clk,

	output flash_io0_oe,
	output flash_io1_oe,
	output flash_io2_oe,
	output flash_io3_oe,

	output flash_io0_do,
	output flash_io1_do,
	output flash_io2_do,
	output flash_io3_do,

	input  flash_io0_di,
	input  flash_io1_di,
	input  flash_io2_di,
	input  flash_io3_di
);
	parameter [0:0] BARREL_SHIFTER = 1;
	parameter [0:0] ENABLE_MUL = 1;
	parameter [0:0] ENABLE_DIV = 1;
	parameter [0:0] ENABLE_FAST_MUL = 0;
	parameter [0:0] ENABLE_COMPRESSED = 1;
	parameter [0:0] ENABLE_COUNTERS = 1;
	parameter [0:0] ENABLE_IRQ_QREGS = 0;

	parameter integer MEM_WORDS = 256;
	parameter [31:0] STACKADDR = (4*MEM_WORDS);       // end of memory
	parameter [31:0] PROGADDR_RESET = 32'h 0010_0000; // 1 MB into flash
	parameter [31:0] PROGADDR_IRQ = 32'h 0000_0000;

	//reg [31:0] irq;
	//wire irq_stall = 0;
	//wire irq_uart = 0;

	//always @* begin
	//	irq = 0;
	//	irq[3] = irq_stall;
	//	irq[4] = irq_uart;
	//	irq[5] = irq_5;
	//	irq[6] = irq_6;
	//	irq[7] = irq_7;
	//end

	wire mem_valid;
	wire mem_instr;
	wire mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	wire [31:0] mem_rdata;

	wire spimem_ready;
	wire [31:0] spimem_rdata;
//
	//reg ram_ready;
	wire [31:0] ram_rdata;
//
	//assign iomem_valid = mem_valid && (mem_addr[31:24] > 8'h 01);
	//assign iomem_wstrb = mem_wstrb;
	//assign iomem_addr = mem_addr;
	//assign iomem_wdata = mem_wdata;
//
	//wire spimemio_cfgreg_sel = mem_valid && (mem_addr == 32'h 0200_0000);
	wire [31:0] spimemio_cfgreg_do;
	wire spimemio_cfgreg_sel;
//
	//wire        simpleuart_reg_div_sel = mem_valid && (mem_addr == 32'h 0200_0004);
	wire [31:0] simpleuart_reg_div_do;
	wire        simpleuart_reg_div_sel;
//
	//wire        simpleuart_reg_dat_sel = mem_valid && (mem_addr == 32'h 0200_0008);
	wire [31:0] simpleuart_reg_dat_do;
	wire        simpleuart_reg_dat_wait;
	wire        simpleuart_reg_dat_sel;
//
	//assign mem_ready = (iomem_valid && iomem_ready) || spimem_ready || ram_ready || spimemio_cfgreg_sel ||
	//		simpleuart_reg_div_sel || (simpleuart_reg_dat_sel && !simpleuart_reg_dat_wait);
//
	//assign mem_rdata = (iomem_valid && iomem_ready) ? iomem_rdata : spimem_ready ? spimem_rdata : ram_ready ? ram_rdata :
	//		spimemio_cfgreg_sel ? spimemio_cfgreg_do : simpleuart_reg_div_sel ? simpleuart_reg_div_do :
	//		simpleuart_reg_dat_sel ? simpleuart_reg_dat_do : 32'h 0000_0000;

	picorv32 cpu (
`ifdef USE_POWER_PINS	
	.vccd1 (vccd1),	// User area 1 1.8V supply
	.vssd1 (vssd1),	// User area 1 digital ground
`endif			
		.clk         (clk        ),
		.resetn      (resetn     ),
		.mem_valid   (mem_valid  ),
		.mem_instr   (mem_instr  ),
		.mem_ready   (mem_ready  ),
		.mem_addr    (mem_addr   ),
		.mem_wdata   (mem_wdata  ),
		.mem_wstrb   (mem_wstrb  ),
		.mem_rdata   (mem_rdata  ),
		.irq         (extra_irq)
	);

	//wire [31:0] irqinput;
	//assign irqinput =  {24'h000000, irq_7, irq_6, irq_5, 5'b00000};

	spimemio spimemio (
`ifdef USE_POWER_PINS	
	.vccd1 (vccd1),	// User area 1 1.8V supply
	.vssd1 (vssd1),	// User area 1 digital ground
`endif				
		.clk    (clk),
		.resetn (resetn),
		.valid  (extra_spimemio_valid),
		.ready  (spimem_ready),
		.addr   (mem_addr[23:0]),
		.rdata  (spimem_rdata),

		.flash_csb    (flash_csb   ),
		.flash_clk    (flash_clk   ),

		.flash_io0_oe (flash_io0_oe),
		.flash_io1_oe (flash_io1_oe),
		.flash_io2_oe (flash_io2_oe),
		.flash_io3_oe (flash_io3_oe),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		.flash_io2_do (flash_io2_do),
		.flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (flash_io2_di),
		.flash_io3_di (flash_io3_di),

		.cfgreg_we(extra_spimemio_cfgreg_we),
		.cfgreg_di(mem_wdata),
		.cfgreg_do(spimemio_cfgreg_do)
	);

	simpleuart simpleuart (
`ifdef USE_POWER_PINS	
	.vccd1 (vccd1),	// User area 1 1.8V supply
	.vssd1 (vssd1),	// User area 1 digital ground
`endif				
		.clk         (clk         ),
		.resetn      (resetn      ),

		.ser_tx      (ser_tx      ),
		.ser_rx      (ser_rx      ),

		.reg_div_we  (extra_simpleuart_reg_div_we),
		.reg_div_di  (mem_wdata),
		.reg_div_do  (simpleuart_reg_div_do),

		.reg_dat_we  (extra_simpleuart_reg_dat_we),
		.reg_dat_re  (extra_simpleuart_reg_dat_re),
		.reg_dat_di  (mem_wdata),
		.reg_dat_do  (simpleuart_reg_dat_do),
		.reg_dat_wait(simpleuart_reg_dat_wait)
	);

	mem_decode mem_decode (
`ifdef USE_POWER_PINS	
	.vccd1 (vccd1),	// User area 1 1.8V supply
	.vssd1 (vssd1),	// User area 1 digital ground
`endif				
		.clk						(clk),
		.mem_valid					(mem_valid),
		.mem_instr					(mem_instr),
		.mem_ready					(mem_ready),
		.mem_addr					(mem_addr),
		.mem_wdata					(mem_wdata),
		.mem_wstrb					(mem_wstrb),
		.mem_rdata					(mem_rdata),    
		.spimem_ready				(spimem_ready),
		.spimem_rdata				(spimem_rdata),
		.spimemio_cfgreg_do			(spimemio_cfgreg_do),
		.spimemio_cfgreg_sel		(spimemio_cfgreg_sel),
		.ram_rdata					(ram_rdata),
		.iomem_valid				(iomem_valid),
		.iomem_ready				(iomem_ready),
		.iomem_wstrb				(iomem_wstrb),
		.iomem_addr					(iomem_addr),
		.iomem_wdata				(iomem_wdata),
		.iomem_rdata				(iomem_rdata),
		.simpleuart_reg_div_sel		(simpleuart_reg_div_sel),
		.simpleuart_reg_div_do		(simpleuart_reg_div_do),
		.simpleuart_reg_dat_do		(simpleuart_reg_dat_do),
		.simpleuart_reg_dat_sel	 	(simpleuart_reg_dat_sel),
		.simpleuart_reg_dat_wait 	(simpleuart_reg_dat_wait),
		.extra_spimemio_valid			(extra_spimemio_valid),
		.extra_spimemio_cfgreg_we		(extra_spimemio_cfgreg_we),
		.extra_simpleuart_reg_div_we	(extra_simpleuart_reg_div_we),
		.extra_simpleuart_reg_dat_we	(extra_simpleuart_reg_dat_we),
		.extra_simpleuart_reg_dat_re	(extra_simpleuart_reg_dat_re),
		.extra_picosoc_mem_wen			(extra_picosoc_mem_wen),
		.extra_irq_5					(irq_5),
		.extra_irq_6					(irq_6),
		.extra_irq_7					(irq_7),
		.extra_irq_out					(extra_irq)
	);	

	wire 	  [31:0]  extra_irq;
    wire              extra_spimemio_valid;
    wire      [ 3:0]  extra_spimemio_cfgreg_we;
    wire      [ 3:0]  extra_simpleuart_reg_div_we;
    wire              extra_simpleuart_reg_dat_we;
    wire              extra_simpleuart_reg_dat_re;
    wire      [ 3:0]  extra_picosoc_mem_wen;

//	always @(posedge clk)
//		ram_ready <= mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS;

	`PICOSOC_MEM  memory (
`ifdef USE_POWER_PINS	
	.vccd1 (vccd1),	// User area 1 1.8V supply
	.vssd1 (vssd1),	// User area 1 digital ground
`endif				
		.clk(clk),
		.wen(extra_picosoc_mem_wen),
		.addr(mem_addr[23:2]),
		.wdata(mem_wdata),
		.rdata(ram_rdata)
	);

endmodule

// Implementation note:
// Replace the following two modules with wrappers for your SRAM cells.

//module picosoc_regs (
//	input clk, wen,
//	input [5:0] waddr,
//	input [5:0] raddr1,
//	input [5:0] raddr2,
//	input [31:0] wdata,
//	output [31:0] rdata1,
//	output [31:0] rdata2
//);
//	reg [31:0] regs [0:31];
//
//	always @(posedge clk)
//		if (wen) regs[waddr[4:0]] <= wdata;
//
//	assign rdata1 = regs[raddr1[4:0]];
//	assign rdata2 = regs[raddr2[4:0]];
//endmodule

//module picosoc_mem #(
//	parameter integer WORDS = 256
//) (
//	input clk,
//	input [3:0] wen,
//	input [21:0] addr,
//	input [31:0] wdata,
//	output reg [31:0] rdata
//);
//	reg [31:0] mem [0:WORDS-1];
//
//	always @(posedge clk) begin
//		rdata <= mem[addr];
//		if (wen[0]) mem[addr][ 7: 0] <= wdata[ 7: 0];
//		if (wen[1]) mem[addr][15: 8] <= wdata[15: 8];
//		if (wen[2]) mem[addr][23:16] <= wdata[23:16];
//		if (wen[3]) mem[addr][31:24] <= wdata[31:24];
//	end
//endmodule

