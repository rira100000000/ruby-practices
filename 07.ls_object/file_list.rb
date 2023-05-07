# frozen_string_literal: true

class FileList
  attr_reader :name_list, :directory, :max_length_hash

  def initialize(path, reverse_required, hidden_file_required)
    @path = path
    @reverse_required = reverse_required
    @hidden_file_required = hidden_file_required
    @name_list, @directory = parse_path
    @max_length_hash = {
      nlink: 0,
      uid: 0,
      gid: 0,
      size: 0,
      file_name: 0
    }
  end

  def list_detail
    @name_list.map do |file|
      file_detail = FileDetail.new(file, @directory)
      update_max_length(file_detail)
      file_detail
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

  def update_max_length(file)
    @max_length_hash[:nlink] = [file.nlink.to_s.length, @max_length_hash[:nlink]].max
    @max_length_hash[:uid] = [Etc.getpwuid(file.uid.to_i).name.to_s.length, @max_length_hash[:uid]].max
    @max_length_hash[:gid] = [Etc.getgrgid(file.gid.to_i).name.to_s.length, @max_length_hash[:gid]].max
    @max_length_hash[:size] = [file.size.to_s.length, @max_length_hash[:size]].max
    @max_length_hash[:file_name] = [file.name.length, @max_length_hash[:file_name]].max
  end
end
