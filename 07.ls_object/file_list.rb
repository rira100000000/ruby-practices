# frozen_string_literal: true

class FileList
  require_relative 'file_detail'
  require_relative 'long_list_formatter'
  require_relative 'short_list_formatter'

  include LongListFormatter
  include ShortListFormatter

  def initialize(reverse_required, hidden_file_required)
    flag = hidden_file_required ? File::FNM_DOTMATCH : 0
    directory = Dir.pwd
    names = Dir.glob('*', base: directory, flags: flag).sort
    sorted_file_names = reverse_required ? names.reverse : names

    @file_details = sorted_file_names.map do |name|
      FileDetail.new(name, directory)
    end
  end
end
