# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

# Monkey patches an issue in Grit::GitRuby::Repository which will cause commits
# to appear in the wrong order
class Grit::GitRuby::Repository

  # Returns a list of revisions for the given reference ID and the given
  # options
  #
  # @returns [String] A list of commits and additional information, just like
  #          git-rev-list.
  def rev_list(sha, options)
    (end_sha, sha) = sha if sha.is_a? Array

    log = log(sha, options)
    log = truncate_arr(log, end_sha) if end_sha

    if options[:max_count]
      if (opt_len = options[:max_count].to_i) < log.size
        log = log[0, opt_len]
      end
    end

    if options[:pretty] == 'raw'
      log.map {|k, v| v }.join('')
    else
      log.map {|k, v| k }.join("\n")
    end
  end

end
