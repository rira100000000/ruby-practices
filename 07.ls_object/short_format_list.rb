# frozen_string_literal: true

require_relative 'file_list'
require_relative 'file_detail_fetcher'

class ShortFormatList
  COLUMNS = 3
  SPACE_FOR_COLUMNS = 2

  def format(file_details)
    adjust_list_for_display(file_details)
  end

  private

  def adjust_list_for_display(file_details)
    # 行数
    rows = (file_details.size.to_f / COLUMNS).ceil
    lines = []
    line = []
    max_file_names = []
    file_details.each_with_index do |file_detail, i|
      line << file_detail.name
      next unless ((i + 1) % rows).zero? || i + 1 == file_details.length

      # 最終行または最終ファイルの場合
      max_file_names << line.map { |file_name| calc_file_name_size(file_name) }.max
      line.fill('', line.length...rows)
      lines << line
      line = []
    end

    add_space_for_line(lines.transpose, max_file_names)
  end

  def calc_file_name_size(file_name)
    file_name.each_char.sum do |char|
      char.ascii_only? ? 1 : 2
    end
  end

  def add_space_for_line(lines, max_file_names)
    lines.map do |file_names|
      display_line = file_names.map.with_index do |file_name, i|
        space_count = max_file_names[i] + SPACE_FOR_COLUMNS - count_not_ascii(file_name)
        file_name.ljust(space_count)
      end
      display_line.join
    end
  end

  def count_not_ascii(file_name)
    file_name.each_char.sum do |char|
      char.ascii_only? ? 0 : 1
    end
  end
end
