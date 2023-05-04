# frozen_string_literal: true

module FetchFileDetail
  def make_formatted_list(paths, options)
    return fetch_file_details(paths[0], options[:r], options[:a]) unless paths.empty?

    fetch_file_details(Dir.pwd, options[:r], options[:a])
  end

  private

  def fetch_file_details(path, reverse_required, hidden_file_required)
    raise NotImplementedError, 'Method not implemented'
  end
end
