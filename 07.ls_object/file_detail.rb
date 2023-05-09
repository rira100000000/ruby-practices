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

  attr_reader :name, :stat

  def initialize(name, directory = '')
    @name = name
    path = if directory == ''
             name
           else
             "#{directory}/#{name}"
           end

    @stat = File::Stat.new(path)
    @mode = get_file_mode(@stat)
  end

  def type
    TYPE_LIST[@stat.ftype.to_sym]
  end

  def mode
    get_file_mode(@stat)
  end

  private

  def get_file_mode(stat)
    result = []
    # ファイルモードを8進数に変換して末尾3桁（パーミッション）を取得する
    stat.mode.to_s(8)[-3..].each_char do |char|
      result << MODE_LIST[char.to_i]
    end
    result.join
  end
end
