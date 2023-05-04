# frozen_string_literal: true

require_relative 'file_detail'
require_relative 'file_list'
require_relative 'fetch_file_detail'

class LongFormatList
  include FetchFileDetail

  private

  def fetch_file_details(path, reverse_required, hidden_file_required)
    result = []
    file_list = FileList.new(path, reverse_required, hidden_file_required)

    file_details = file_list.list_detail
    result << "total #{calc_total_block(file_details)}"
    result << adjust_list_for_display(file_details, file_list.max_length_hash)

    result.join("\n")
  end

  def adjust_list_for_display(file_details, max_length_hash)
    file_details.map do |file|
      cols = []
      cols << "#{file.type}#{file.mode}"
      cols << file.nlink.to_s.rjust(max_length_hash[:nlink])
      cols << file.uid.rjust(max_length_hash[:uid])
      cols << file.gid.rjust(max_length_hash[:gid])
      cols << file.size.to_s.rjust(max_length_hash[:size])
      cols << file.mtime.strftime('%b %e %R')
      cols << file.name

      cols.join(' ')
    end
  end

  def calc_total_block(file_details)
    # statの1ブロック単位は512byte
    # lsコマンドでの1ブロック単位1024byteに合わせるため2で割る
    file_details.sum { |file| file.blocks / 2 }
  end
end
