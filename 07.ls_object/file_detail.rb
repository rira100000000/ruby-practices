# frozen_string_literal: true

require 'pathname'

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

  attr_reader :name

  def initialize(name, directory)
    @name = name

    path = Pathname.new(directory).join(name).to_s
    @stat = File::Stat.new(path)
  end

  def type
    TYPE_LIST[@stat.ftype.to_sym]
  end

  def mode
    # 8進数に変換したファイルモードの末尾3桁はパーミッションを表している
    @stat.mode.to_s(8)[-3..].each_char.map do |char|
      MODE_LIST[char.to_i]
    end.join
  end

  def nlink
    @stat.nlink
  end

  def uid
    Etc.getpwuid(@stat.uid).name
  end

  def gid
    Etc.getgrgid(@stat.gid).name
  end

  def size
    @stat.size
  end

  def mtime
    @stat.mtime
  end

  def blocks
    @stat.blocks
  end
end
