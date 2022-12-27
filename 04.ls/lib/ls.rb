#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'
require 'optparse'
require 'etc'

COLUMNS = 3
SPACE_FOR_COLUMNS = 2
TYPE_LIST = {
  file: '-',
  directory: 'd',
  characterSpecial: 'c',
  blockSpecial: 'b',
  fifo: 'p',
  link: 'l',
  socket: 's'
}.freeze

MODE_LIST = {
  7 => 'rwx',
  6 => 'rw-',
  5 => 'r-x',
  4 => 'r--',
  3 => '-wx',
  2 => '-w-',
  1 => '--x',
  0 => '---'
}.freeze

def adjust_list_to_display(files)
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
  lines.map do |file_names|
    display_line = +''
    file_names.each_with_index do |file_name, i|
      display_line << "#{file_name}#{' ' * (max_file_names[i] - calc_file_name_size(file_name) + SPACE_FOR_COLUMNS)}"
    end
    display_line
  end
end

def calc_file_name_size(file_name)
  file_name.each_char.sum do |char|
    char.ascii_only? ? 1 : 2
  end
end

def parse_option
  opt = OptionParser.new
  # TODO: オプションの説明追加
  opt.on('-a', '.で始まる要素も表示します')
  opt.on('-r', '逆順でソートして表示します')
  opt.on('-l', 'ファイルやディレクトリの詳細なリストを表示します')
  opt.banner = 'Usage: ls [-a][-r][-l]'
  options = {}
  opt.parse!(ARGV, into: options)
  [ARGV, options]
end

def make_display_list(parse_result)
  result = []
  paths, options = parse_result
  return make_long_format_list(options, paths) if options[:l]

  flag = options[:a] ? File::FNM_DOTMATCH : 0
  if paths == []
    file_list = Dir.glob('*', base: Dir.pwd, flags: flag).sort
    file_list.reverse! if options[:r]
    adjust_list_to_display(file_list).each { |line| result << line }
  else
    file_list = list_file_paths(paths, options[:r])
    display_lines = adjust_list_to_display(file_list)
    display_lines.each { |line| result << line }
    result << "\n" unless file_list == []
    directorys = list_directory_paths(paths, flag, options[:r])
    result.push(*directorys)
    result
  end
end

def list_directory_paths(paths, flag, need_reverse_order)
  result = []
  paths.reverse! if need_reverse_order
  paths.each do |path|
    next unless File::Stat.new(path).directory?

    result << "\n" unless result == []
    result << "#{path}:" if paths.size > 1
    file_list = Dir.glob('*', base: path, flags: flag).sort
    file_list.reverse! if need_reverse_order
    display_lines = adjust_list_to_display(file_list)
    display_lines.each { |line| result << line }
  end
  result
end

def list_file_paths(paths, need_reverse_order)
  result = paths.select { |path| File::Stat.new(path).file? }.sort
  need_reverse_order ? result.reverse! : result
end

def make_long_format_list(_options, paths)
  file_list = Dir.glob('*', base: Dir.pwd).sort
  total_blocks = 0
  link_max_char_length = 0
  user_name_max_char_length = 0
  group_name_max_char_length = 0
  file_size_max_char_length = 0
  file_name_max_char_length = 0

  file_details = file_list.map do |file|
    stat = File::Stat.new(file)
    # statの1ブロック単位は512byte
    # lsコマンドでの1ブロック単位1024byteに合わせるため2で割る
    total_blocks += stat.blocks / 2

    link_max_char_length = return_larger(stat.nlink.to_s.length, link_max_char_length)
    user_name_max_char_length = return_larger(Etc.getpwuid(stat.uid).name.to_s.length, user_name_max_char_length)
    group_name_max_char_length = return_larger(Etc.getgrgid(stat.gid).name.to_s.length, group_name_max_char_length)
    file_size_max_char_length = return_larger(stat.size.to_s.length, file_size_max_char_length)
    file_name_max_char_length = return_larger(file.length, file_name_max_char_length)

    [TYPE_LIST[stat.ftype.to_s],
     get_file_mode(stat),
     stat.nlink,
     Etc.getpwuid(stat.uid).name,
     Etc.getgrgid(stat.gid).name,
     stat.size,
     stat.mtime,
     file]
  end

  result = +"total #{total_blocks}\n"
  file_details.each do |file_detail|
    result << "#{file_detail[0]}#{file_detail[1]} "\
      "#{file_detail[2].to_s.rjust(link_max_char_length)} "\
      "#{file_detail[3].rjust(user_name_max_char_length)} "\
      "#{file_detail[4].rjust(group_name_max_char_length)} "\
      "#{file_detail[5].to_s.rjust(file_size_max_char_length)} "\
      "#{file_detail[6].strftime('%b %e %R')} "\
      "#{file_detail[7]}\n"
  end
  result
end

def return_larger(num1, num2)
  num1 >= num2 ? num1 : num2
end

def get_file_mode(stat)
  result = +''
  mode = stat.mode.to_s(8)[2..4]
  mode.each_char do |char|
    result << MODE_LIST[char.to_i]
  end
  result
end

puts make_display_list(parse_option)
