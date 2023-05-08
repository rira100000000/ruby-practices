# frozen_string_literal: true

class FileDetailfetcher
  def fetch(paths, options)
    return fetch_file_details(paths[0], options[:r], options[:a]) unless paths.empty?

    fetch_file_details(Dir.pwd, options[:r], options[:a])
  end

  private

  def fetch_file_details(path, reverse_required, hidden_file_required)
    FileList.new(path, reverse_required, hidden_file_required).list_detail
  end
end
