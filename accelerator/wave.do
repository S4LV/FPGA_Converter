onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /accelerator_tb/dut_clk
add wave -noupdate /accelerator_tb/dut_reset_n
add wave -noupdate /accelerator_tb/dut_AS_address
add wave -noupdate /accelerator_tb/dut_AS_write
add wave -noupdate /accelerator_tb/dut_AS_read
add wave -noupdate /accelerator_tb/dut_AS_writedata
add wave -noupdate /accelerator_tb/dut_AS_readdata
add wave -noupdate /accelerator_tb/dut_drivers
add wave -noupdate /accelerator_tb/sim_finished
add wave -noupdate /accelerator_tb/all_done
add wave -noupdate /accelerator_tb/checker_done
add wave -noupdate /accelerator_tb/stimulus_done
add wave -noupdate /accelerator_tb/dut_0/clk
add wave -noupdate /accelerator_tb/dut_0/reset_n
add wave -noupdate /accelerator_tb/dut_0/AS_address
add wave -noupdate /accelerator_tb/dut_0/AS_write
add wave -noupdate /accelerator_tb/dut_0/AS_read
add wave -noupdate /accelerator_tb/dut_0/AS_writedata
add wave -noupdate /accelerator_tb/dut_0/AS_readdata
add wave -noupdate /accelerator_tb/dut_0/drivers
add wave -noupdate /accelerator_tb/dut_0/FSMState
add wave -noupdate /accelerator_tb/dut_0/mem_seq
add wave -noupdate /accelerator_tb/dut_0/seq_data
add wave -noupdate /accelerator_tb/dut_0/seq_readdata_a
add wave -noupdate /accelerator_tb/dut_0/seq_readdata_b
add wave -noupdate /accelerator_tb/dut_0/seq_we
add wave -noupdate /accelerator_tb/dut_0/seq_read
add wave -noupdate /accelerator_tb/dut_0/free_running_counter
add wave -noupdate /accelerator_tb/dut_0/free_running_counter_latched
add wave -noupdate /accelerator_tb/dut_0/clk_en
add wave -noupdate /accelerator_tb/dut_0/status_reg
add wave -noupdate /accelerator_tb/dut_0/ctrl_reg
add wave -noupdate /accelerator_tb/dut_0/seq_addr_a_reg
add wave -noupdate /accelerator_tb/dut_0/seq_addr_b_reg
add wave -noupdate /accelerator_tb/dut_0/seq_size_reg
add wave -noupdate /accelerator_tb/dut_0/clk_div_cnt_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1532 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1797 ps}
