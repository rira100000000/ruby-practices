# frozen_string_literal: true

module ShortListFormatter
  COLUMNS = 3
  SPACE_FOR_COLUMNS = 2

  def short_format
    last_row = (@file_details.size.to_f / COLUMNS).ceil
    file_names_list = []
    max_file_names = []
    @file_details.each_slice(last_row) do |sliced_file_details|
      file_names = sliced_file_details.map(&:name)
      max_file_names << file_names.map { |file_name| calc_file_name_size(file_name) }.max
      # transposeするためにfillで要素数を揃える
      file_names.fill('', file_names.length...last_row)
      file_names_list << file_names
    end

    add_space_for_line(file_names_list.transpose, max_file_names)
  end

  private

  def add_space_for_line(file_names_list, max_file_names)
    file_names_list.map do |file_names|
      line_for_display = file_names.map.with_index do |file_name, i|
        space_count = max_file_names[i] + SPACE_FOR_COLUMNS - count_not_ascii(file_name)
        file_name.ljust(space_count)
      end
      line_for_display.join
    end
  end

  def calc_file_name_size(file_name)
    calc_ascii(file_name, 1)
  end

  def count_not_ascii(file_name)
    calc_ascii(file_name, 0)
  end

  def calc_ascii(file_name, ascii_size)
    file_name.each_char.sum do |char|
      char.ascii_only? ? ascii_size : ascii_size + 1
    end
  end
end
