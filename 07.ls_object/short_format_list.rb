# frozen_string_literal: true

require_relative 'file_list'
require_relative 'file_detail_fetchable'

COLUMNS = 3
SPACE_FOR_COLUMNS = 2

class ShortFormatList
  include FileDetailfetchable

  private

  def fetch_file_details(path, reverse_required, hidden_file_required)
    file_list = FileList.new(path, reverse_required, hidden_file_required)
    adjust_list_for_display(file_list.name_list)
  end

  def adjust_list_for_display(files)
    rows = (files.size.to_f / COLUMNS).ceil
    lines = []
    max_file_names = []
    files.each_with_index do |file_name, i|
      current_row = i % rows
      current_column = i / rows
      lines[current_row] = [] if current_column.zero?
      max_file_names[current_column] ||= 0

      lines[current_row] << file_name
      max_file_names[current_column] = calc_file_name_size(file_name) if max_file_names[current_column] < file_name.size
    end
    add_space_for_line(lines, max_file_names)
  end

  def calc_file_name_size(file_name)
    file_name.each_char.sum do |char|
      char.ascii_only? ? 1 : 2
    end
  end

  def add_space_for_line(lines, max_file_names)
    lines.map do |file_names|
      display_line = []
      file_names.each_with_index do |file_name, i|
        space_count = max_file_names[i] + SPACE_FOR_COLUMNS
        display_line << file_name.ljust(space_count)
      end
      display_line.join
    end
  end
end
