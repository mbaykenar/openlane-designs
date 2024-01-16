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

## IO Placement

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| Some pins weren't matched by the config file | Forgetting to add all ports in the module definition in pin order file which is defined in config file as parameter "FP_PIN_ORDER_CFG" | Add all port signals in pin order file.|

## Detailed Routing

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| There are violations in the design after detailed routing | Routing resources are not enough to route all nets in the design | Check "DRT_OPT_ITERS" parameter in config file and incrase it if it is a small number such as smaller than 10. Other possible solution is increasing the "DIE_AREA" config parameter if "FP_SIZING" config parameter is "absolute", or decreasing "FP_CORE_UTIL" config parameter if "FP_SIZING" is "relative".|

## IR Drop Report

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| IR drop setup failed | "RT_MAX_LAYER" config parameter is not set| Add "RT_MAX_LAYER" config parameter and set it to "met4". This is for SKY130 PDK. For GF180 it should be set "Metal4". Another solution can be disabling IR Drop with setting '0' to config parameter "RUN_IRDROP_REPORT".
| WARNING   | VSRC_LOC_FILES is not defined. The IR drop analysis will run, but the values may be inaccurate| ??? | ???|

## GDS Klayout

|<div style="width:55">Severity</div>|Error Message|Reason|Solution| 
| ----------- | -----------   | ------- | --------|
|ERROR| Not a floating-point value: PIN (line=94891, cell=, file=i2c_master_top.def) in Layout.read child process exited abnormally | Using 8 power nets: vccd1, vccd2, vdda1, vdda2, vssd1, vssd2, vssa1, vssa2 | I only used 2 power nets: vccd1 and vssd1 and the error has gone.|
