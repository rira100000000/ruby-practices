# frozen_string_literal: true

require_relative 'separator'

COLUMNS = 3
SPACE_FOR_COLUMNS = 2

class ShortFormatList
  def make_short_format_list(paths, options)
    result = []
    flag = options[:a] ? File::FNM_DOTMATCH : 0
    if paths == []
      file_list = Dir.glob('*', base: Dir.pwd, flags: flag).sort
      file_list.reverse! if options[:r]
      adjust_list_for_display(file_list).each { |line| result << line }
    else
      separator = Separator.new(paths)
      file_list = separator.fetch_file(options[:r])
      display_lines = adjust_list_for_display(file_list)
      display_lines.each { |line| result << line }
      result << "\n" unless file_list == []
      directorys = list_directory_files_for_display(separator.fetch_directory(options[:r]), flag, options[:r])
      result.push(*directorys)
      result
    end
  end

  def list_directory_files_for_display(directory_list, flag, need_reverse_order)
    result = []
    directory_list.each do |directory|
      result << "\n" unless result == []
      result << "#{directory}:" if directory_list.size > 1
      file_list = Dir.glob('*', base: directory, flags: flag).sort
      file_list.reverse! if need_reverse_order
      display_lines = adjust_list_for_display(file_list)
      display_lines.each { |line| result << line }
    end
    result
  end

  def adjust_list_for_display(files)
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

  def calc_file_name_size(file_name)
    file_name.each_char.sum do |char|
      char.ascii_only? ? 1 : 2
    end
  end

  def add_space_for_line(lines, max_file_names)
    lines.map do |file_names|
      display_line = +''
      file_names.each_with_index do |file_name, i|
        display_line << "#{file_name}#{' ' * (max_file_names[i] - calc_file_name_size(file_name) + SPACE_FOR_COLUMNS)}"
      end
      display_line
    end
  end
end
