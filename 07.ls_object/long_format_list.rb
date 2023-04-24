# frozen_string_literal: true

require_relative 'file_detail'
require_relative 'list'

class LongFormatList < List
  def self.make_long_format_list(paths, options)
    max_length_hash = reset_max_length_hash
    flag = options[:a] ? File::FNM_DOTMATCH : 0
    if paths.empty?
      file_list = Dir.glob('*', base: Dir.pwd, flags: flag).sort
      file_list.reverse! if options[:r]
      result = list_long_format_list_to_display(file_list.map { |file| FileDetail.fetch_file_details(file, max_length_hash) }, max_length_hash)
      result.unshift("total #{max_length_hash[:total_blocks]}")
      result
    else
      result = +''
      parsed_file_list = list_file_paths(paths, options[:r])
      file_details = parsed_file_list.map { |file| FileDetail.fetch_file_details(file, max_length_hash) }
      long_format_file_list = list_long_format_list_to_display(file_details, max_length_hash)
      long_format_file_list.each { |file| result << file }
      result << "\n"
      result << FileDetail.fetch_directory_details(paths, options[:r], options[:a])
      # 最終行の空行は削除してリターン
      result[..-2]
    end
  end

  def self.reset_max_length_hash
    { total_blocks: 0,
      link_max_char_length: 0,
      user_name_max_char_length: 0,
      group_name_max_char_length: 0,
      file_size_max_char_length: 0,
      file_name_max_char_length: 0 }
  end

  def self.list_long_format_list_to_display(file_details, max_length_hash)
    file_details.map do |file_detail|
      "#{file_detail[0]}#{file_detail[1]} "\
      "#{file_detail[2].to_s.rjust(max_length_hash[:link_max_char_length])} "\
      "#{file_detail[3].rjust(max_length_hash[:user_name_max_char_length])} "\
      "#{file_detail[4].rjust(max_length_hash[:group_name_max_char_length])} "\
      "#{file_detail[5].to_s.rjust(max_length_hash[:file_size_max_char_length])} "\
      "#{file_detail[6].strftime('%b %e %R')} "\
      "#{file_detail[7]}\n"
    end
  end
end
