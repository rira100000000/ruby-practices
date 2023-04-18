# frozen_string_literal: true

class List
  def self.adjust_list_to_display(files)
    rows = (files.size.to_f / COLUMNS).ceil
    lines = []
    max_file_names = []
    files.each_with_index do |file_name, i|
      now_row = i % rows
      now_column = i / rows
      lines[now_row] = [] if now_column.zero?
      max_file_names[now_column] ||= 0

      lines[now_row] << file_name
      file_name_size = calc_file_name_size(file_name)
      max_file_names[now_column] = file_name_size if max_file_names[now_column] < file_name_size
    end
    add_space_for_line(lines, max_file_names)
  end

  def self.calc_file_name_size(file_name)
    file_name.each_char.sum do |char|
      char.ascii_only? ? 1 : 2
    end
  end

  def self.add_space_for_line(lines, max_file_names)
    lines.map do |file_names|
      display_line = +''
      file_names.each_with_index do |file_name, i|
        display_line << "#{file_name}#{' ' * (max_file_names[i] - calc_file_name_size(file_name) + SPACE_FOR_COLUMNS)}"
      end
      display_line
    end
  end
end
