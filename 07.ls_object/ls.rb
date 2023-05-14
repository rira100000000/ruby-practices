#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'short_format_list'
require_relative 'long_format_list'
require_relative 'file_detail_fetcher'

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
  file_details = fetch(paths, options)

  if options[:l]
    puts LongFormatList.new.format(file_details)
  else
    puts ShortFormatList.new.format(file_details)
  end
end

def fetch(paths, options)
  return fetch_file_details(paths[0], options[:r], options[:a]) unless paths.empty?

  fetch_file_details(Dir.pwd, options[:r], options[:a])
end

private

def fetch_file_details(path, reverse_required, hidden_file_required)
  FileList.new(path, reverse_required, hidden_file_required).list_detail
end

main
