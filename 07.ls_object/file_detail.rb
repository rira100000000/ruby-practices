# frozen_string_literal: true

class FileDetail
  TYPE_LIST =
    {
      file: '-',
      directory: 'd',
      characterSpecial: 'c',
      blockSpecial: 'b',
      fifo: 'p',
      link: 'l',
      socket: 's'
    }.freeze

  MODE_LIST =
    {
      7 => 'rwx',
      6 => 'rw-',
      5 => 'r-x',
      4 => 'r--',
      3 => '-wx',
      2 => '-w-',
      1 => '--x',
      0 => '---'
    }.freeze

  attr_reader :name, :detail

  def initialize(name, directory = '')
    @name = name
    @detail = fetch_detail

    @name = if directory == ''
              name
            else
              "#{directory}/#{name}"
            end
  end

  def fetch_detail
    stat = File::Stat.new(@name)
    {
      type: TYPE_LIST[stat.ftype.to_sym],
      mode: fetch_file_mode(stat),
      nlink: stat.nlink,
      uid: Etc.getpwuid(stat.uid).name,
      gid: Etc.getgrgid(stat.gid).name,
      size: stat.size,
      mtime: stat.mtime,
      blocks: stat.blocks
    }
  end

  def fetch_file_mode(stat)
    result = []
    mode = stat.mode.to_s(8)[-3..]
    mode.each_char do |char|
      result << MODE_LIST[char.to_i]
    end
    result.join
  end
end
