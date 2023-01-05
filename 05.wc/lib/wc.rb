#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'
require 'optparse'

def parse_option
  opt = OptionParser.new
  opt.on('-l', '行数を表示します')
  opt.on('-w', '単語数を表示します')
  opt.on('-c', 'バイト数を表示します')
  opt.banner = 'Usage: ls [-l][-w][-c]'
  options = {}
  opt.parse!(ARGV, into: options)
  [ARGV, options]
end

def count_lines(path)
  str = File.read(path)
  str.lines.count
end

def count_words(path)
  str = File.read(path)
  number_of_words = str.scan(/[\n\t 　]+/).length
  number_of_words
end

def count_bytes(path)
  stat = File::Stat.new(path)
  stat.size
end

def reset_max_length_hash
  { lines_max_number_of_digits: 0,
    words_max_number_of_digits: 0,
    bytes_max_number_of_digits: 0 }
end

def make_display_line(count_list, max_length_hash, total_hash)
  result = count_list.map do |counts|
    if counts[:file_not_exists]
      counts[:file_not_exists]
    else
      display_str = +''
      if counts[:directory]
        counts[:number_of_lines] = 0
        counts[:number_of_words] = 0
        counts[:number_of_bytes] = 0
        display_str = +"#{counts[:directory]}\n"
      elsif counts[:not_file]
        next display_str = +"#{counts[:not_file]}\n"
      end
      display_str << "  #{counts[:number_of_lines].to_s.rjust(max_length_hash[:lines_max_number_of_digits])}"\
      " #{counts[:number_of_words].to_s.rjust(max_length_hash[:words_max_number_of_digits])}"\
      " #{counts[:number_of_bytes].to_s.rjust(max_length_hash[:bytes_max_number_of_digits])}"\
      " #{counts[:path]}"
    end  
  end
  result << "  #{total_hash[:lines_total]} #{total_hash[:words_total]} #{total_hash[:bytes_total]} total" if result.length > 1 
  result
end

def print_all_count(paths)
  max_length_hash = reset_max_length_hash
  count_list = []
  total_hash = { lines_total: 0, words_total: 0, bytes_total: 0 }
  paths.each_with_index do |path, index|
    count_list[index] = {}
    count_list[index][:path] = path
    if File.directory?(path)
      count_list[index][:directory] = "wc: #{path}: Is a directory"
    elsif File.exist?(path)
      count_list[index][:number_of_lines] = count_lines(path)
      count_list[index][:number_of_words] = count_words(path)
      count_list[index][:number_of_bytes] = count_bytes(path)
      total_hash[:lines_total] += count_list[index][:number_of_lines]
      total_hash[:words_total] += count_list[index][:number_of_words]
      total_hash[:bytes_total] += count_list[index][:number_of_bytes]
    else
      count_list[index][:not_file] = "wc: #{path}: No such file or directory"
    end
    max_length_hash[:lines_max_number_of_digits] = total_hash[:lines_total].to_s.length
    max_length_hash[:words_max_number_of_digits] = total_hash[:words_total].to_s.length
    max_length_hash[:bytes_max_number_of_digits] = total_hash[:bytes_total].to_s.length
  end
  puts make_display_line(count_list, max_length_hash, total_hash)
end

def print_selected_count(paths, options)
end

def main
  paths, options = parse_option
  if options == {}
    print_all_count(paths)
  else
    print_selected_count(paths, options)
  end
end

main
