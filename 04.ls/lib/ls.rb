#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'
require 'optparse'

COLUMNS = 3
SPACE_FOR_COLUMNS = 2
def glob_file_list(path)
  Dir.glob('*', base: path)
end

def adjust_list_to_disp(files)
  rows = (files.size.to_f / COLUMNS).ceil
  lines = []
  max_file_names = []
  files.each_with_index do |file_name, i|
    now_row = i % rows
    now_column = i / rows
    lines[now_row] = [] if now_column.zero?
    max_file_names[now_column] ||= 0

    lines[now_row] << file_name
    file_name_size = calc_file_name_size(file_name)
    max_file_names[now_column] = file_name_size if max_file_names[now_column] < file_name_size
  end
  add_space_for_line(lines, max_file_names)
end

def add_space_for_line(lines, max_file_names)
  result = []
  lines.each do |file_names|
    disp_line = ''
    file_names.each_with_index do |file_name, i|
      disp_line += file_name + ' ' * (max_file_names[i] - calc_file_name_size(file_name) + SPACE_FOR_COLUMNS)
    end
    result << disp_line
  end
  result
end

def calc_file_name_size(file_name)
  count = 0
  file_name.each_char do |char|
    count += char.ascii_only? ? 1 : 2
  end
  count
end

def split_option_or_path(argv)
  options = {}
  paths = []
  argv.each do |str|
    if ['-a', '-r', '-l'].include?(str)
      options[str] = true
    else
      paths << str
    end
  end
  [options, paths]
end

def parse_option
  opt = OptionParser.new
  # TODO: オプションの説明追加
  opt.on('-a', '今後対応予定')
  opt.on('-r', '今後対応予定')
  opt.on('-l', '今後対応予定')
  opt.banner = 'Usage: ls [-a][-r][-l]'
  opt.parse(ARGV)
  ARGV
end

def make_disp_list(argv)
  result = []
  if argv == []
    file_list = glob_file_list(Dir.pwd).sort
    adjust_list_to_disp(file_list).each { |line| result << line }
  else
    _options, paths = split_option_or_path(argv)
    file_list = analys_file_paths(paths)
    disp_lines = adjust_list_to_disp(file_list.sort)
    disp_lines.each { |line| result << line }
    result << "\n" unless file_list == []
    directorys = analys_directory_paths(paths)
    result.push(*directorys)
    result
  end
end

def analys_directory_paths(paths)
  result = []
  paths.each do |path|
    next unless File::Stat.new(path).directory?

    result << "\n" unless result == []
    result << "#{path}:" if paths.size > 1
    file_list = glob_file_list(path).sort
    disp_lines = adjust_list_to_disp(file_list)
    disp_lines.each { |line| result << line }
  end
  result
end

def analys_file_paths(paths)
  file_list = []
  paths.each { |path| file_list << path if File::Stat.new(path).file? }
  file_list
end

puts make_disp_list(parse_option)
