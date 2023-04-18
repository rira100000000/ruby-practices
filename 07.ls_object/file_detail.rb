# frozen_string_literal: true

TYPE_LIST = {
  file: '-',
  directory: 'd',
  characterSpecial: 'c',
  blockSpecial: 'b',
  fifo: 'p',
  link: 'l',
  socket: 's'
}.freeze

MODE_LIST = {
  7 => 'rwx',
  6 => 'rw-',
  5 => 'r-x',
  4 => 'r--',
  3 => '-wx',
  2 => '-w-',
  1 => '--x',
  0 => '---'
}.freeze

class FileDetail
  def self.fetch_file_details(file, max_length_hash, directory = '')
    stat = if directory == ''
             File::Stat.new(file)
           else
             File::Stat.new("#{directory}/#{file}")
           end
    # statの1ブロック単位は512byte
    # lsコマンドでの1ブロック単位1024byteに合わせるため2で割る
    max_length_hash[:total_blocks] += stat.blocks / 2
    max_length_hash[:link_max_char_length] = [stat.nlink.to_s.length, max_length_hash[:link_max_char_length]].max
    max_length_hash[:user_name_max_char_length] = [Etc.getpwuid(stat.uid).name.to_s.length, max_length_hash[:user_name_max_char_length]].max
    max_length_hash[:group_name_max_char_length] = [Etc.getgrgid(stat.gid).name.to_s.length, max_length_hash[:group_name_max_char_length]].max
    max_length_hash[:file_size_max_char_length] = [stat.size.to_s.length, max_length_hash[:file_size_max_char_length]].max
    max_length_hash[:file_name_max_char_length] = [file.length, max_length_hash[:file_name_max_char_length]].max

    [TYPE_LIST[stat.ftype.to_sym],
     get_file_mode(stat),
     stat.nlink,
     Etc.getpwuid(stat.uid).name,
     Etc.getgrgid(stat.gid).name,
     stat.size,
     stat.mtime,
     file,
     max_length_hash]
  end

  def self.fetch_directory_details(paths, need_reverse_order, need_hidden_file)
    parsed_directory_list = list_parsed_directory_paths(paths)
    parsed_directory_list.reverse! if need_reverse_order
    flag = need_hidden_file ? File::FNM_DOTMATCH : 0
    result = +''
    parsed_directory_list.each do |directory|
      max_length_hash = reset_max_length_hash
      file_list = Dir.glob('*', base: directory, flags: flag).sort
      file_list.reverse! if need_reverse_order
      long_format_list = list_long_format_list_to_display(file_list.map { |file| fetch_file_details(file.to_s, max_length_hash, directory) }, max_length_hash)
      total_block = max_length_hash[:total_blocks].to_i
      long_format_list.unshift("#{directory}:\ntotal #{total_block} \n")
      long_format_list.each { |file| result << file }
      result << "\n"
    end
    result
  end

  def self.get_file_mode(stat)
    result = +''
    mode = stat.mode.to_s(8)[-3..]
    mode.each_char do |char|
      result << MODE_LIST[char.to_i]
    end
    result
  end

  def self.list_parsed_directory_paths(paths)
    paths.select { |path| File::Stat.new(path).directory? }.sort
  end
end
