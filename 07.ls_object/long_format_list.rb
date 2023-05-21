# frozen_string_literal: true

class LongFormatList
  attr_reader :list

  def initialize(file_details)
    @max_length = Data.define(:nlink, :uid, :gid, :file_size, :file_name).new(* calc_max_length(file_details))
    @list = format(file_details)
  end

  private

  def format(file_details)
    result = []
    result << "total #{calc_total_block(file_details)}"
    result.push(* adjust_list_for_display(file_details))
    result.join("\n")
  end

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

  def calc_max_length(file_details)
    nlink = 0
    uid = 0
    gid = 0
    file_size = 0
    file_name = 0

    file_details.each do |file_detail|
      nlink = [file_detail.nlink.to_s.length, nlink].max
      uid = [file_detail.uid.to_s.length, uid].max
      gid = [file_detail.gid.to_s.length, gid].max
      file_size = [file_detail.size.to_s.length, file_size].max
      file_name = [file_detail.name.length, file_name].max
    end

    [nlink, uid, gid, file_size, file_name]
  end
end
