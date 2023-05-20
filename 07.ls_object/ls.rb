#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'short_format_list'
require_relative 'long_format_list'
require_relative 'file_detail'

def parse_option
  opt = OptionParser.new
  opt.on('-a', '.で始まる要素も表示します')
  opt.on('-r', '逆順でソートして表示します')
  opt.on('-l', 'ファイルやディレクトリの詳細なリストを表示します')
  opt.banner = 'Usage: ls [-a][-r][-l]'
  options = {}
  opt.parse!(ARGV, into: options)
  [ARGV, options]
end

def main
  _paths, options = parse_option
  file_details = fetch_file_details(options[:r], options[:a])

  if options[:l]
    puts LongFormatList.new(file_details).list
  else
    puts ShortFormatList.new(file_details).list
  end
end

private

def fetch_file_details(reverse_required, hidden_file_required)
  flag = hidden_file_required ? File::FNM_DOTMATCH : 0
  directory = Dir.pwd
  names = Dir.glob('*', base: directory, flags: flag).sort
  sorted_file_names = reverse_required ? names.reverse : names
  sorted_file_names.map do |name|
    FileDetail.new(name, directory)
  end
end

main
