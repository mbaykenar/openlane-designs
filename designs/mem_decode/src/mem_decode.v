module mem_decode (
`ifdef USE_POWER_PINS	
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif	  
	input clk,

    input               mem_valid,
    input               mem_instr,
    output              mem_ready,
    input       [31:0]  mem_addr,
    input       [31:0]  mem_wdata,
    input       [ 3:0]  mem_wstrb,
    output      [31:0]  mem_rdata,    

    input               spimem_ready,
    input       [31:0]  spimem_rdata,
    input       [31:0]  spimemio_cfgreg_do,
    output              spimemio_cfgreg_sel,

    input       [31:0]  ram_rdata,

	output              iomem_valid,
	input               iomem_ready,
	output      [ 3:0]  iomem_wstrb,
	output      [31:0]  iomem_addr,
	output      [31:0]  iomem_wdata,
	input       [31:0]  iomem_rdata,

    output              simpleuart_reg_div_sel,
    input       [31:0]  simpleuart_reg_div_do,
    input       [31:0]  simpleuart_reg_dat_do,
    output              simpleuart_reg_dat_sel,
    input               simpleuart_reg_dat_wait,

    output              extra_spimemio_valid,
    output      [ 3:0]  extra_spimemio_cfgreg_we,
    output      [ 3:0]  extra_simpleuart_reg_div_we,
    output              extra_simpleuart_reg_dat_we,
    output              extra_simpleuart_reg_dat_re,
    output      [ 3:0]  extra_picosoc_mem_wen,
    input               extra_irq_5,
    input               extra_irq_6,
    input               extra_irq_7,
    output      [31:0]  extra_irq_out
);

assign extra_irq_out = {24'h000000, extra_irq_7, extra_irq_6, extra_irq_5, 5'b00000};

parameter integer MEM_WORDS = 256;
reg ram_ready;

assign extra_spimemio_valid = mem_valid && mem_addr >= 4*MEM_WORDS && mem_addr < 32'h 0200_0000;
assign extra_spimemio_cfgreg_we = spimemio_cfgreg_sel ? mem_wstrb : 4'b 0000;
assign extra_simpleuart_reg_div_we = simpleuart_reg_div_sel_int ? mem_wstrb : 4'b 0000;
assign extra_simpleuart_reg_dat_we = simpleuart_reg_dat_sel_int ? mem_wstrb[0] : 1'b0;
assign extra_simpleuart_reg_dat_re = simpleuart_reg_dat_sel_int && !mem_wstrb;
assign extra_picosoc_mem_wen = mem_valid && !mem_ready_int && mem_addr < 4*MEM_WORDS;

assign iomem_valid = mem_valid && (mem_addr[31:24] > 8'h 01);
assign iomem_wstrb = mem_wstrb;
assign iomem_addr = mem_addr;
assign iomem_wdata = mem_wdata;

assign spimemio_cfgreg_sel = mem_valid && (mem_addr == 32'h 0200_0000);
//wire [31:0] spimemio_cfgreg_do;

wire simpleuart_reg_div_sel_int;
assign simpleuart_reg_div_sel_int = mem_valid && (mem_addr == 32'h 0200_0004);
assign simpleuart_reg_div_sel = simpleuart_reg_div_sel_int;
//wire [31:0] simpleuart_reg_div_do;

wire simpleuart_reg_dat_sel_int;
assign simpleuart_reg_dat_sel_int = mem_valid && (mem_addr == 32'h 0200_0008);
assign        simpleuart_reg_dat_sel = simpleuart_reg_dat_sel_int;
//wire [31:0] simpleuart_reg_dat_do;
//wire        simpleuart_reg_dat_wait;

wire mem_ready_int;
assign mem_ready_int = (iomem_valid && iomem_ready) || spimem_ready || ram_ready || spimemio_cfgreg_sel ||
simpleuart_reg_div_sel || (simpleuart_reg_dat_sel && !simpleuart_reg_dat_wait);
assign mem_ready = mem_ready_int;

assign mem_rdata = (iomem_valid && iomem_ready) ? iomem_rdata : spimem_ready ? spimem_rdata : ram_ready ? ram_rdata :
        spimemio_cfgreg_sel ? spimemio_cfgreg_do : simpleuart_reg_div_sel ? simpleuart_reg_div_do :
        simpleuart_reg_dat_sel ? simpleuart_reg_dat_do : 32'h 0000_0000;

always @(posedge clk)
    ram_ready <= mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS;

endmodule