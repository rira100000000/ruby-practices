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
  str.lines.count.to_s
end

def count_words(path)
  str = File.read(path)
  words_number = str.scan(/[\n\t 　]+/).length
  words_number.to_s
end

def count_bytes(path)
  stat = File::Stat.new(path)
  stat.size.to_s
end

def reset_max_length_hash
  { lines_max_number_of_digits: 0,
    words_max_number_of_digits: 0,
    bytes_max_number_of_digits: 0 }
end

def make_display_line(count_list, max_length_hash)
  count_list.map do |counts|
    if counts[:file_not_exists]
      counts[:file_not_exists]
    else
      if counts[:directory]
        counts[:lines_number] = '0'
        counts[:words_number] = '0'
        counts[:bytes_number] = '0'
        result = +"#{counts[:directory]}\n"
      else
        result = +''
      end
      result << "  #{counts[:lines_number].rjust(max_length_hash[:lines_max_number_of_digits])}"\
      " #{counts[:words_number].rjust(max_length_hash[:words_max_number_of_digits])}"\
      " #{counts[:bytes_number].rjust(max_length_hash[:bytes_max_number_of_digits])}"\
      " #{counts[:path]}"
    end
  end
end

def print_all_count(paths)
  max_length_hash = reset_max_length_hash
  count_list = []
  paths.each_with_index do |path, index|
    count_list[index] = {}
    count_list[index][:path] = path
    if File.directory?(path)
      count_list[index][:directory] = "wc: #{path}: Is a directory"
    elsif File.exist?(path)
      count_list[index][:lines_number] = count_lines(path)
      count_list[index][:words_number] = count_words(path)
      count_list[index][:bytes_number] = count_bytes(path)
      max_length_hash[:lines_max_number_of_digits] = [count_list[index][:lines_number].length, max_length_hash[:lines_max_number_of_digits]].max
      max_length_hash[:words_max_number_of_digits] = [count_list[index][:words_number].length, max_length_hash[:words_max_number_of_digits]].max
      max_length_hash[:bytes_max_number_of_digits] = [count_list[index][:bytes_number].length, max_length_hash[:bytes_max_number_of_digits]].max
    else
      count_list[index][:not_file] = "wc: #{path}: No such file or directory"
    end
  end
  puts make_display_line(count_list, max_length_hash)
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
