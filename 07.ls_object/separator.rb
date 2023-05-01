# frozen_string_literal: true

class Separator
  def initialize(paths)
    @paths = paths
  end

  def fetch_file(reverse_required: false)
    result = @paths.select { |path| File::Stat.new(path).file? }.sort
    reverse_required ? result.reverse! : result
  end

  def fetch_directory(reverse_required: false)
    result = @paths.select { |path| File::Stat.new(path).directory? }.sort
    reverse_required ? result.reverse! : result
  end
end
