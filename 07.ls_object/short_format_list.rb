# frozen_string_literal: true

require_relative 'list'

COLUMNS = 3
SPACE_FOR_COLUMNS = 2

class ShortFormatList < List
  def self.make_short_format_list(paths, options)
    result = []
    flag = options[:a] ? File::FNM_DOTMATCH : 0
    if paths == []
      file_list = Dir.glob('*', base: Dir.pwd, flags: flag).sort
      file_list.reverse! if options[:r]
      adjust_list_to_display(file_list).each { |line| result << line }
    else
      file_list = list_file_paths(paths, options[:r])
      display_lines = adjust_list_to_display(file_list)
      display_lines.each { |line| result << line }
      result << "\n" unless file_list == []
      directorys = list_directory_paths(paths, flag, options[:r])
      result.push(*directorys)
      result
    end
  end

  def list_directory_paths(paths, flag, need_reverse_order)
    result = []
    paths.reverse! if need_reverse_order
    paths.each do |path|
      next unless File::Stat.new(path).directory?

      result << "\n" unless result == []
      result << "#{path}:" if paths.size > 1
      file_list = Dir.glob('*', base: path, flags: flag).sort
      file_list.reverse! if need_reverse_order
      display_lines = adjust_list_to_display(file_list)
      display_lines.each { |line| result << line }
    end
    result
  end

  def list_file_paths(paths, need_reverse_order)
    result = paths.select { |path| File::Stat.new(path).file? }.sort
    need_reverse_order ? result.reverse! : result
  end
end
