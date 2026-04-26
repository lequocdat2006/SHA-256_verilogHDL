# Định nghĩa Clock 200MHz (Chu kỳ 5.000ns), Duty cycle 50%
# Giả sử port clock trong file Verilog của bạn tên là 'clk'
create_clock -period 5.000 -name sys_clk -waveform {0.000 2.500} [get_ports clk]