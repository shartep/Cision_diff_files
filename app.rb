require 'diff/lcs'

puts 'Before using the program, make sure that you have installed gem diff-lcs'
puts 'For this run "gem install diff-lcs" in command line'
begin
  puts
  puts 'How many files you want to compare (min 2): '
  files_count = STDIN.gets.to_i
  raise Exception.new('Wrong number of files, minimum 2') if files_count < 2
rescue Exception => e
  puts "Error: #{e}"
  retry
end

compare_method = :separate
if files_count > 2
  puts
  puts 'Choose compare method: "additive" - compare first file with each next, "separate" - compare first with second, second with third etc.'
  puts 'type A for additive and S for separate: '
  compare_method = :additive if ['A', 'a', 'А', 'а'].include? STDIN.gets.strip!
end

file_names = []
file_number = 1
files_count.times do
  puts
  puts "Enter path to file number #{file_number}:"
  file_names << STDIN.gets.strip!
  file_number += 1
end

data_to_compare = []
file_names.each {|file_name| data_to_compare << File.readlines(file_name).each {|line| line.strip!} }

results = []
(1...data_to_compare.length).each do |file_number|
  compare_with_data = compare_method == :additive ? data_to_compare[0] : data_to_compare[file_number - 1]
  results << Diff::LCS.sdiff(compare_with_data, data_to_compare[file_number])
end

puts
puts
puts 'Result:'
puts

longest_line = data_to_compare.flatten.map {|l| l.length}.max
column_width = 2 * longest_line + 5

row_count = results.map {|result| result.count}.max
(0...row_count).each do |row_number|
  line = ''
  results.each_with_index do |result, index|
    r = result[row_number]
    if r
      if r.action == '!'
        res_data = "#{r.old_element}|#{r.new_element}"
        comp_sym = '*'
      elsif r.action == '-'
        res_data = "#{r.old_element}"
        comp_sym = '-'
      elsif r.action == '+'
        res_data = "#{r.new_element}"
        comp_sym = '+'
      elsif r.action == '='
        res_data = "#{r.new_element}"
        comp_sym = ' '
      end
      line += "#{row_number} #{comp_sym} #{res_data}"
      add_spaces = column_width * (index + 1)  - line.length
      line += ' ' * add_spaces
    end
  end
  puts line
end

