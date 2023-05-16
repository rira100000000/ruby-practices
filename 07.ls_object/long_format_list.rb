# frozen_string_literal: true

require_relative 'file_detail'
require_relative 'file_list'

class LongFormatList
  def initialize
    max_length = Struct.new(:nlink, :uid, :gid, :file_size, :file_name)
    @max_length = max_length.new(0, 0, 0, 0, 0)
  end

  def format(file_details)
    file_details.each { |file_detail| update_max_length(file_detail) }

    result = []
    result << "total #{calc_total_block(file_details)}"
    result << adjust_list_for_display(file_details)

    result.join("\n")
  end

  private

  def adjust_list_for_display(file_details)
    file_details.map do |file_detail|
      cols = []
      cols << "#{file_detail.type}#{file_detail.mode}"
      cols << file_detail.nlink.to_s.rjust(@max_length.nlink)
      cols << file_detail.uid.rjust(@max_length.uid)
      cols << file_detail.gid.rjust(@max_length.gid)
      cols << file_detail.size.to_s.rjust(@max_length.file_size)
      cols << file_detail.mtime.strftime('%b %e %R')
      cols << file_detail.name

      cols.join(' ')
    end
  end

  def calc_total_block(file_details)
    # statの1ブロック単位は512byte
    # lsコマンドでの1ブロック単位1024byteに合わせるため2で割る
    file_details.sum { |file_detail| file_detail.blocks / 2 }
  end

  def update_max_length(file_detail)
    @max_length.nlink = [file_detail.nlink.to_s.length, @max_length.nlink].max
    @max_length.uid = [file_detail.uid.to_s.length, @max_length.uid].max
    @max_length.gid = [file_detail.gid.to_s.length, @max_length.gid].max
    @max_length.file_size = [file_detail.size.to_s.length, @max_length.file_size].max
    @max_length.file_name = [file_detail.name.length, @max_length.file_name].max
  end
end
