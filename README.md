<h1 align="center">OpenLane Designs</h1>

You can download and install Openlane open-source IC Design EDA tool from it's github page:

[Openlane Github Repo](https://github.com/The-OpenROAD-Project/OpenLane)

## Tutorials in My Webpage

Here are tutorial links to my webpage:

[Open-Source IC Design Flow for an Open-Source RISC-V Core](https://www.mehmetburakaykenar.com/open-source-ic-design-flow-for-an-open-source-risc-v-core/444/)

[RISC-V Based SoC Design with Open-Source Openlane IC Design Tool](https://www.mehmetburakaykenar.com/risc-v-based-soc-design-with-open-source-openlane-ic-design-tool/458/)

[Open-Source IC Design Flow for an Open-Source RISC-V SoC – Part2](https://www.mehmetburakaykenar.com/open-source-ic-design-flow-for-an-open-source-risc-v-soc-part2/521/)

## Common Openlane Errors, Causes, Solutions

Here I will list errors that I got during Openlane flows and how I solved them. I divided this sections, where each section is a step in Openlane flow.

## Linter

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| [N] errors found by linter. In linter.log: Specified --top-module 'simple_uart' not found in design.| DESIGN_NAME config parameter must be the same with the top module name. | Write top module name into DESIGN_NAME parameter in config file. Ex: set ::env(DESIGN_NAME) "simpleuart" |
|ERROR| [N] errors found by linter. In linter.log: syntax error, unexpected '=', expecting IDENTIFIER or randomize spimemio_cfgreg_sel = mem_valid && (mem_addr == 32'h0200_0000); | Forgetting 'assign' keyword in concurrent signal assignment in Verilog | Add 'assign' for concurrent signal assignments in Verilog. |
|ERROR| [N] errors found by linter. In linter.log: Duplicate declaration of signal: 'mysignal' | Same signal is declared in both as port in module and as a wire/reg in the body part of the module. | Remove one of the declarations of the signal. |
|ERROR| [N] errors found by linter. In linter.log: syntax error, unexpected ',' .irq (24'h000000, irq_7, irq_6, irq_5, 5'b00000) | Concat operation {} in Verilog is forgotten. | Add {} to concatenate. Ex: .irq ({24'h000000, irq_7, irq_6, irq_5, 5'b00000}) |
|ERROR| [N] errors found by linter. In linter.log: Parameter not found: 'MYPARAM' .MYPARAM(MYPARAM) | There is no parameter definition in the Verilog file | Remove the parameter passing in module instantiation |

## Synthesis

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|WARNING| Wire picosoc.\spimemio_cfgreg_sel is used but has no driver. | There is a signal declaration but this signal is never assigned to a value. | Remove the unused signal or assign it if necessary. This warning happens usually when the coder forgets something. |
|ERROR| There are unmapped cells after synthesis. | SYNTH_ELABORATE_ONLY config parameter is set to '1' but there are logic cell inferences in the Verilog code. | Check if there is any logic inference code. Ex: .valid (mem_valid && mem_addr >= 4*MEM_WORDS && mem_addr < 32'h 0200_0000), . Change the code part which infers standard cells. |

## STA

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| syntax error, unexpected ';', expecting ',' or '=' or ')'| In Verilog module definition at the end of a port signal declaretion ';' is put instead of ',' | Add ',' for port signal declaretion in Verilog module definition. |
|ERROR| Error while reading myfile.v Make sure that this a gate-level netlist not an RTL file| A behavioral RTL file is included in VERILOG_FILES_BLACKBOX parameter instead of a gate-level netlist Verilog file. | Use a gate-level netlist (which is the result of synthesis step for a macro) Verilog file for VERILOG_FILES_BLACKBOX config parameter. |

## Floorplan

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|WARNING| Current core area is too small for the power grid settings chosen. The power grid was scaled down to an offset of 1/8 the core width and height and a pitch of 1/4 the core width and height| Power grid pitch parameters are FP_PDN_VPITCH and FP_PDN_HPITCH. Their default value is 180. The height and width of the core is smaller than 180 180. | Harden the macro with at least 200 200 um DIE_AREA value. You can also decrease PITCH values, but the best practice is use at least 200 200 value. |

## IO Placement

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| Some pins weren't matched by the config file | Forgetting to add all ports in the module definition in pin order file which is defined in config file as parameter "FP_PIN_ORDER_CFG" | Add all port signals in pin order file.|
|ERROR| Unterminated character set at position 3 | Forgetting '\' in pin_order.cfg file for vector type port signals | Add '\' for each bit in signal. Ex: wen[0\] wen[1\]|

## Manual Macro Placement

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| Macros not found:' {picosoc_mem: 200000 200000} | Wrong instantiation name is used in MACRO_PLACEMENT_CFG file | Use instantiation name for macro positioning.|

## PDN

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| No regex match found for picosoc_mem defined in FP_PDN_MACRO_HOOKS | Wrong instantiation name is used in FP_PDN_MACRO_HOOKS config parameter | Use instantiation name for macro power connections.|

## Global Placement

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| Utilization exceeds 100% | DIE_AREA is not enough to place all the standard cells in the macro. | Increase DIE_AREA in config file|
|ERROR| Found pin spimem_rdata[0] outside die area in instance mem_decode | There is an error in manual macro positioning in MACRO_PLACEMENT_CFG file. | Check and correct macro positioning in MACRO_PLACEMENT_CFG file. Use openroad -gui command to analyze macro positions.|

## Global Routing

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| child killed: segmentation violation | The design is too complex to be routed. | Try first harden the module and then instantiate it in the top module instead of direct synthesis flow.|

## Detailed Routing

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| There are violations in the design after detailed routing | Routing resources are not enough to route all nets in the design | Check "DRT_OPT_ITERS" parameter in config file and incrase it if it is a small number such as smaller than 10. Other possible solution is increasing the "DIE_AREA" config parameter if "FP_SIZING" config parameter is "absolute", or decreasing "FP_CORE_UTIL" config parameter if "FP_SIZING" is "relative". Another possibility is there may be errors in manual macro positioning. Check macro positions with openroad -gui command.|

## IR Drop Report

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| IR drop setup failed | "RT_MAX_LAYER" config parameter is not set| Add "RT_MAX_LAYER" config parameter and set it to "met4". This is for SKY130 PDK. For GF180 it should be set "Metal4". Another solution can be disabling IR Drop with setting '0' to config parameter "RUN_IRDROP_REPORT".
| WARNING   | VSRC_LOC_FILES is not defined. The IR drop analysis will run, but the values may be inaccurate| ??? | ???|

## GDS Klayout

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| Not a floating-point value: PIN (line=94891, cell=, file=i2c_master_top.def) in Layout.read child process exited abnormally | Using 8 power nets: vccd1, vccd2, vdda1, vdda2, vssd1, vssd2, vssa1, vssa2 | I only used 2 power nets: vccd1 and vssd1 and the error has gone.|

## LVS

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| There are LVS errors in the design. See /31-lvs.lef.log for details. | Possibly a power connection is forgotten. It could be a macro or a standard cell. | Check FP_PDN_MACRO_HOOKS parameter for macro power connections if they are correct or not. Also check macro Verilog black-box files if they have power pins in module declaration. Check if FP_PDN_ENABLE_RAILS parameter is '1' if you are using standard logic cells. If you are only instantiating macros and FP_PDN_ENABLE_RAILS is '0', then check synthesized netlist file if there is any TIE_ZERO or TIE_ONE cell in the design. If there is, then you have standard cells in the design, find and remove them.|
