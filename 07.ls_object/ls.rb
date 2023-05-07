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
    long_format = LongFormatList.new
    puts long_format.format_list(paths, options)
  else
    short_format = ShortFormatList.new
    puts short_format.format_list(paths, options)
  end
end

main
