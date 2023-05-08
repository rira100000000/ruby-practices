# frozen_string_literal: true

class FileList
  attr_reader :name_list, :directory

  def initialize(path, reverse_required, hidden_file_required)
    @path = path
    @reverse_required = reverse_required
    @hidden_file_required = hidden_file_required
    @names, @directory = parse_path
  end

  def list_detail
    @names.map do |file|
      FileDetail.new(file, @directory)
    end
  end

  private

  def parse_path
    flag = @hidden_file_required ? File::FNM_DOTMATCH : 0
    files = if File::Stat.new(@path).directory?
              directory = @path
              Dir.glob('*', base: @path, flags: flag).sort
            else
              directory = ''
              [@path]
            end
    file_list = @reverse_required ? files.reverse : files
    [file_list, directory]
  end
end
