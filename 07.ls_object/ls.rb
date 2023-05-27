#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative 'file_detail'
require_relative 'long_list_formatter'
require_relative 'short_list_formatter'

def parse_options
  opt = OptionParser.new
  opt.on('-a', '.で始まる要素も表示します')
  opt.on('-r', '逆順でソートして表示します')
  opt.on('-l', 'ファイルやディレクトリの詳細なリストを表示します')
  opt.banner = 'Usage: ls [-a][-r][-l]'
  options = {}
  opt.parse!(ARGV, into: options)
  options
end

def create_file_details(options)
  flag = options[:a] ? File::FNM_DOTMATCH : 0
  names = Dir.glob('*', flags: flag).sort
  sorted_file_names = options[:r] ? names.reverse : names

  sorted_file_names.map do |name|
    FileDetail.new(name)
  end
end

def main
  options = parse_options
  file_details = create_file_details(options)
  formatter = options[:l] ? LongListFormatter.new : ShortListFormatter.new
  puts formatter.format(file_details)
end

main
