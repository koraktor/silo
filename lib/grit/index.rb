# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

# Monkey patches an issue in Grit::Index which prevents directories from being
# cleanly removed from the index and the repository
class Grit::Index

  # Add (or remove) a file to the index
  #
  # @param [String] path The path to the file
  # @param [String] data The contents of the file
  def add(path, data)
    is_dir = path[-1].chr == '/'
    path = path.split('/')
    filename = path.pop
    filename += '/' if is_dir

    current = self.tree

    path.each do |dir|
      current[dir] ||= {}
      node = current[dir]
      current = node
    end

    current[filename] = data
  end

end
