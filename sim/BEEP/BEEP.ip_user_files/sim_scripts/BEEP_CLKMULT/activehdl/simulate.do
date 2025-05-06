transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+BEEP_CLKMULT  -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.BEEP_CLKMULT xil_defaultlib.glbl

do {BEEP_CLKMULT.udo}

run 1000ns

endsim

quit -force
