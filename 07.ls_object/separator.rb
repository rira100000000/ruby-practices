# frozen_string_literal: true

class Separator
  def initialize(paths)
    @paths = paths
  end

  def fetch_file(need_reverse_order = nil)
    result = @paths.select { |path| File::Stat.new(path).file? }.sort
    need_reverse_order ? result.reverse! : result
  end

  def fetch_directory(need_reverse_order = nil)
    result = @paths.select { |path| File::Stat.new(path).directory? }.sort
    need_reverse_order ? result.reverse! : result
  end
end
