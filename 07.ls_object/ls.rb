#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'short_format_list'
require_relative 'long_format_list'

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
  paths, options = parse_option
  if options[:l]
    if paths.empty?
      puts LongFormatList.new.make_long_format_list(options)
    else
      puts LongFormatList.new.make_long_format_list_with_paths(paths, options)
    end
  else
    puts ShortFormatList.new.make_short_format_list(paths, options)
  end
end

main
