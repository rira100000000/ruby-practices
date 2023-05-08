# frozen_string_literal: true

require_relative 'file_detail'
require_relative 'file_list'
require_relative 'file_detail_fetcher'

class LongFormatList
  attr_accessor :max_length_hash

  def initialize
    @max_length_hash = {
      nlink: 0,
      uid: 0,
      gid: 0,
      size: 0,
      file_name: 0
    }
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
    file_details.map do |file|
      cols = []
      cols << "#{file.type}#{file.mode}"
      cols << file.stat.nlink.to_s.rjust(@max_length_hash[:nlink])
      cols << Etc.getpwuid(file.stat.uid).name.rjust(@max_length_hash[:uid])
      cols << Etc.getgrgid(file.stat.gid).name.rjust(@max_length_hash[:gid])
      cols << file.stat.size.to_s.rjust(@max_length_hash[:size])
      cols << file.stat.mtime.strftime('%b %e %R')
      cols << file.name

      cols.join(' ')
    end
  end

  def calc_total_block(file_details)
    # statの1ブロック単位は512byte
    # lsコマンドでの1ブロック単位1024byteに合わせるため2で割る
    file_details.sum { |file| file.stat.blocks / 2 }
  end

  def update_max_length(file_detail)
    @max_length_hash[:nlink] = [file_detail.stat.nlink.to_s.length, @max_length_hash[:nlink]].max
    @max_length_hash[:uid] = [Etc.getpwuid(file_detail.stat.uid).name.to_s.length, @max_length_hash[:uid]].max
    @max_length_hash[:gid] = [Etc.getgrgid(file_detail.stat.gid).name.to_s.length, @max_length_hash[:gid]].max
    @max_length_hash[:size] = [file_detail.stat.size.to_s.length, @max_length_hash[:size]].max
    @max_length_hash[:file_name] = [file_detail.name.length, @max_length_hash[:file_name]].max
  end
end
