# frozen_string_literal: true

require_relative 'file_detail'
require_relative 'separator'

class LongFormatList
  def initialize
    @max_length_hash = reset_max_length_hash
  end

  def make_long_format_list(options)
    flag = options[:a] ? File::FNM_DOTMATCH : 0
    file_name_list = Dir.glob('*', base: Dir.pwd, flags: flag).sort
    file_name_list.reverse! if options[:r]

    file_details = file_name_list.map do |file_name|
      file_detail = FileDetail.new(file_name)
      compare_max_length(file_detail)
      file_detail
    end
    result = list_long_format_for_display(file_details)

    result.unshift("total #{calc_total_block(file_details)}")
    result
  end

  def make_long_format_list_with_paths(paths, options)
    result = +''
    separator = Separator.new(paths)
    file_list = separator.fetch_file(options[:r])
    file_details = file_list.map do |file|
      file_detail = FileDetail.new(file)
      compare_max_length(file_detail)
      file_detail
    end
    long_format_file_list = list_long_format_for_display(file_details)
    long_format_file_list.each { |file| result << file }
    directory_list = separator.fetch_directory(options[:r])
    result << fetch_directory_details(directory_list, options[:r], options[:a])
    # 最終行の空行は削除してリターン
    result[..-2]
  end

  def reset_max_length_hash
    {
      link_max_char_length: 0,
      user_name_max_char_length: 0,
      group_name_max_char_length: 0,
      file_size_max_char_length: 0,
      file_name_max_char_length: 0
    }
  end

  def compare_max_length(file)
    @max_length_hash[:link_max_char_length] = [file.detail[:nlink].to_s.length, @max_length_hash[:link_max_char_length]].max
    @max_length_hash[:user_name_max_char_length] = [Etc.getpwuid(file.detail[:uid].to_i).name.to_s.length, @max_length_hash[:user_name_max_char_length]].max
    @max_length_hash[:group_name_max_char_length] = [Etc.getgrgid(file.detail[:gid].to_i).name.to_s.length, @max_length_hash[:group_name_max_char_length]].max
    @max_length_hash[:file_size_max_char_length] = [file.detail[:size].to_s.length, @max_length_hash[:file_size_max_char_length]].max
    @max_length_hash[:file_name_max_char_length] = [file.name.length, @max_length_hash[:file_name_max_char_length]].max
  end

  def list_long_format_for_display(file_details)
    file_details.map do |file|
      "#{file.detail[:type]}#{file.detail[:mode]} "\
      "#{file.detail[:nlink].to_s.rjust(@max_length_hash[:link_max_char_length])} "\
      "#{file.detail[:uid].rjust(@max_length_hash[:user_name_max_char_length])} "\
      "#{file.detail[:gid].rjust(@max_length_hash[:group_name_max_char_length])} "\
      "#{file.detail[:size].to_s.rjust(@max_length_hash[:file_size_max_char_length])} "\
      "#{file.detail[:mtime].strftime('%b %e %R')} "\
      "#{file.name}\n"
    end
  end

  def calc_total_block(file_details)
    # statの1ブロック単位は512byte
    # lsコマンドでの1ブロック単位1024byteに合わせるため2で割る
    file_details.sum { |file| file.detail[:blocks] / 2 }
  end

  def fetch_directory_details(directory_list, need_reverse_order, need_hidden_file)
    flag = need_hidden_file ? File::FNM_DOTMATCH : 0
    result = []
    directory_list.each do |directory|
      file_list = Dir.glob('*', base: directory, flags: flag).sort
      file_list.reverse! if need_reverse_order
      file_details = file_list.map do |file|
        file_detail = FileDetail.new("#{directory}/#{file}")
        compare_max_length(file_detail)
        file_detail
      end
      long_format_list = list_long_format_for_display(file_details)
      total_block = calc_total_block(file_details)
      long_format_list.unshift("total #{total_block} \n")
      long_format_list.unshift("#{directory}:\n") if directory_list.size > 1
      long_format_list.each { |file| result << file }
      result << "\n"
    end
    result.join
  end
end
