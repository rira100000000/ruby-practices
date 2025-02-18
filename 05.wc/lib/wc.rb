#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def parse_option
  opt = OptionParser.new
  opt.on('-l', '行数を表示します')
  opt.on('-w', '単語数を表示します')
  opt.on('-c', 'バイト数を表示します')
  opt.banner = 'Usage: ls [-l][-w][-c]'
  options = {}
  opt.parse!(ARGV, into: options)
  if options.empty?
    options[:l] = true
    options[:w] = true
    options[:c] = true
  end

  [ARGV, options]
end

def count_lines(str)
  str.lines.count
end

def count_words(str)
  str.scan(/[\n\t 　]+/).length
end

def count_bytes(path)
  stat = File::Stat.new(path)
  stat.size
end

def make_display_line(counts, max_length_hash, options)
  display_str = +' '
  display_str << " #{counts[:number_of_lines].to_s.rjust(max_length_hash[:lines_max_number_of_digits])}" if options[:l]
  display_str << " #{counts[:number_of_words].to_s.rjust(max_length_hash[:words_max_number_of_digits])}" if options[:w]
  display_str << " #{counts[:number_of_bytes].to_s.rjust(max_length_hash[:bytes_max_number_of_digits])}" if options[:c]
  display_str << " #{counts[:path]}"
end

def make_display_total_line(total_hash, options)
  result = +' '
  result << " #{total_hash[:lines_total]}" if options[:l]
  result << " #{total_hash[:words_total]}" if options[:w]
  result << " #{total_hash[:bytes_total]}" if options[:c]
  result << ' total'
end

def make_display_str(counts_list, max_length_hash, total_hash, options)
  result = counts_list.map do |counts|
    display_str = +''
    if counts[:directory]
      display_str = +"#{counts[:directory]}\n"
    elsif counts[:not_file]
      next display_str = +"#{counts[:not_file]}\n"
    end
    display_str << make_display_line(counts, max_length_hash, options)
  end
  result << make_display_total_line(total_hash, options) if result.length > 1
  result
end

def list_counts(path)
  str = File.read(path)
  [count_lines(str), count_words(str), count_bytes(path)]
end

def analyse_paths(paths)
  count_list = []
  total_hash = { lines_total: 0, words_total: 0, bytes_total: 0 }
  paths.each_with_index do |path, index|
    count_list[index] = {}
    count_list[index][:path] = path
    if File.directory?(path)
      count_list[index][:directory] = "wc: #{path}: Is a directory"
      count_list[index][:number_of_lines] = 0
      count_list[index][:number_of_words] = 0
      count_list[index][:number_of_bytes] = 0
    elsif File.exist?(path)
      count_list[index][:number_of_lines], count_list[index][:number_of_words], count_list[index][:number_of_bytes] = *list_counts(path)
      total_hash[:lines_total] += count_list[index][:number_of_lines]
      total_hash[:words_total] += count_list[index][:number_of_words]
      total_hash[:bytes_total] += count_list[index][:number_of_bytes]
    else
      count_list[index][:not_file] = "wc: #{path}: No such file or directory"
    end
  end
  [count_list, total_hash]
end

def print_command_line_argument_count(paths, options)
  max_length_hash = { lines_max_number_of_digits: 0, words_max_number_of_digits: 0, bytes_max_number_of_digits: 0 }
  count_list, total_hash = analyse_paths(paths)
  max_length_hash[:lines_max_number_of_digits] = total_hash[:lines_total].to_s.length
  max_length_hash[:words_max_number_of_digits] = total_hash[:words_total].to_s.length
  max_length_hash[:bytes_max_number_of_digits] = total_hash[:bytes_total].to_s.length
  puts make_display_str(count_list, max_length_hash, total_hash, options)
end

def print_standard_input_count(standard_input, options)
  display_str = +' '
  display_str << " #{count_lines(standard_input)}" if options[:l]
  display_str << " #{count_words(standard_input)}" if options[:w]
  display_str << " #{standard_input.bytesize}" if options[:c]
  puts display_str
end

def main
  paths, options = parse_option
  if paths.empty?
    print_standard_input_count(readlines.join, options)
  else
    print_command_line_argument_count(paths, options)
  end
end

main if $PROGRAM_NAME == __FILE__
