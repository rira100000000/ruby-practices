# frozen_string_literal: true

class FileList
  def initialize(path, reverse_required, hidden_file_required)
    @path = path
    @reverse_required = reverse_required
    @hidden_file_required = hidden_file_required
    @names, @directory = parse_path
  end

  def list_detail
    @names.map do |name|
      FileDetail.new(name, @directory)
    end
  end

  private

  def parse_path
    flag = @hidden_file_required ? File::FNM_DOTMATCH : 0
    if File::Stat.new(@path).directory?
      directory = @path
      names = Dir.glob('*', base: @path, flags: flag).sort
    else
      directory = ''
      names = [@path]
    end
    sorted_file_names = @reverse_required ? names.reverse : names
    [sorted_file_names, directory]
  end
end
