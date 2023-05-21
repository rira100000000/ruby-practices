#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'file_list'

def parse_option
  opt = OptionParser.new
  opt.on('-a', '.で始まる要素も表示します')
  opt.on('-r', '逆順でソートして表示します')
  opt.on('-l', 'ファイルやディレクトリの詳細なリストを表示します')
  opt.banner = 'Usage: ls [-a][-r][-l]'
  options = {}
  opt.parse!(ARGV, into: options)
  options
end

def main
  options = parse_option

  file_list = FileList.new(options[:r], options[:a])
  if options[:l]
    puts file_list.long_format
  else
    puts file_list.short_format
  end
end

main
