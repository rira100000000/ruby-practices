#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'file_detail'
require_relative 'long_list_formatter'
require_relative 'short_list_formatter'

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

def fetch_file_details(file_names, directory)
  file_names.map do |name|
    FileDetail.new(name, directory)
  end
end

def main
  options = parse_option

  flag = options[:a] ? File::FNM_DOTMATCH : 0
  directory = Dir.pwd
  names = Dir.glob('*', base: directory, flags: flag).sort
  sorted_file_names = options[:r] ? names.reverse : names

  formatter = if options[:l]
                LongListFormatter.new
              else
                ShortListFormatter.new
              end
  puts formatter.format(fetch_file_details(sorted_file_names, directory))
end

main
