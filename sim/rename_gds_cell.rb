# SPDX-FileCopyrightText: 2024 AgriDrone Team
# SPDX-License-Identifier: Apache-2.0
#
# KLayout Ruby script: rename top cell in GDS from 'top' to 'user_project_wrapper'
# Usage: klayout -b -r rename_gds_cell.rb

input_gds  = "/project/gds/user_project_wrapper.gds"
output_gds = "/project/gds/user_project_wrapper.gds"

lv = RBA::Layout.new
lv.read(input_gds)

top_cell = lv.top_cell
puts "Current top cell: #{top_cell.name}"

if top_cell.name != "user_project_wrapper"
  top_cell.name = "user_project_wrapper"
  puts "Renamed to: user_project_wrapper"
else
  puts "Already named correctly, no change needed."
end

lv.write(output_gds)
puts "Written to #{output_gds}"
