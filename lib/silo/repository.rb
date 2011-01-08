# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2011, Sebastian Staudt

require 'tmpdir'

require 'rubygems'
require 'grit'

module Silo

  # Represents a Silo repository
  #
  # This provides the core features of Silo to initialize a repository and work
  # with it.
  #
  # @author Sebastian Staudt
  # @since 0.1.0
  class Repository

    # @return [Grit::Repo] The Grit object to access the Git repository
    attr_reader :git

    # Creates a new repository instance on the given path
    #
    # @param [Hash] options A hash of options
    # @option options [Boolean] :create (true) Creates the backing Git
    #         repository if it does not already exist
    # @option options [Boolean] :prepare (true) Prepares the backing Git
    #         repository for use with Silo if not already done
    #
    # @raise [Grit::InvalidGitRepositoryError] if the path exists, but is not a
    #        valid Git repository
    # @raise [Grit::NoSuchPathError] if the path does not exist and option
    #        :create is +false+
    # @raise [InvalidRepositoryError] if the path contains another Git
    #        repository that does not contain data managed by Silo.
    def initialize(path, options = {})
      options = {
        :create  => true,
        :prepare => true
      }.merge options

      if File.exist?(path)
        if Dir.new(path).count > 2
          unless File.exist?(File.join(path, 'HEAD')) &&
                 File.stat(File.join(path, 'objects')).directory? &&
                 File.stat(File.join(path, 'refs')).directory?
            raise Grit::InvalidGitRepositoryError.new(path)
          end
        end
        @git = Grit::Repo.new(path, { :is_bare => true })
      else
        if options[:create]
          @git = Grit::Repo.init_bare(path, {}, { :is_bare => true })
        else
          raise Grit::NoSuchPathError.new(path)
        end
      end

      if !prepared? && @git.commit_count > 0
        raise InvalidRepositoryError.new(path)
      end

      @path    = File.expand_path path
      @remotes = {}

      load_git_remotes

      prepare if options[:prepare] && !prepared?
    end

    # Stores a file or full directory structure into the repository inside an
    # optional prefix path
    #
    # This adds one commit to the history of the repository including the file
    # or directory structure. If the file or directory already existed inside
    # the prefix, Git will only save the changes.
    #
    # @param [String] path The path of the file or directory to store into the
    #        repository
    # @param [String] prefix An optional prefix where the file is stored inside
    #        the repository
    def add(path, prefix = nil)
      prefix ||= '.'
      in_work_tree File.dirname(path) do
        index = @git.index
        index.read_tree 'HEAD'
        add = lambda do |f, p|
          file = File.basename f
          pre  = (p == '.') ? file : File.join(p, file)
          dir  = File.stat(f).directory?
          if dir
            Dir.entries(f)[2..-1].each do |child|
              add.call File.join(f, child), pre
            end
          else
            index.add pre, IO.read(f)
          end
          dir
        end
        dir = add.call path, prefix
        type = dir ? 'directory' : 'file'
        commit_msg = "Added #{type} #{path} into '#{prefix}'"
        index.commit commit_msg, @git.head.commit.sha
      end
    end

    # Adds a new remote to this Repository
    #
    # @param [String] name The name of the remote to add
    # @param [String] url The URL of the remote repository
    # @see Remote
    def add_remote(name, url)
      @remotes[name] = Remote::Git.new(self, name, url)
      @remotes[name].add
    end

    # Gets a list of files and directories in the specified path inside the
    # repository
    #
    # @param [String] path The path to search for inside the repository
    # @return [Array<String>] All files and directories found in the specidied
    #         path
    def contents(path = '.')
      contents = []

      object = (path == '.') ? @git.tree : @git.tree/path
      contents << path unless path == '.' || object.nil?
      if object.is_a? Grit::Tree
        (object.blobs + object.trees).each do |obj|
          contents += contents ((path == '.') ? obj.basename : File.join(path, obj.basename))
        end
      end

      contents
    end

    # Push the current state of the repository to each attached remote
    # repository
    #
    # @see Remote::Git#push
    def distribute
      @remotes.each_value { |remote| remote.push }
    end

    # Run a block of code with +$GIT_WORK_TREE+ set to a specified path
    #
    # This executes a block of code while the environment variable
    # +$GIT_WORK_TREE+ is set to a specified path or alternatively the path of
    # a temporary directory.
    #
    # @param [String, :tmp] path A path or +:tmp+ which will create a temporary
    #        directory that will be removed afterwards
    # @yield [path] The code inside this block will be executed with
    #        +$GIT_WORK_TREE+ set
    # @yieldparam [String] path The absolute path used for +$GIT_WORK_TREE+
    def in_work_tree(path = '.')
      tmp_dir = path == :tmp
      path = tmp_dir ? Dir.mktmpdir : File.expand_path(path)
      old_work_tree = ENV['GIT_WORK_TREE']
      ENV['GIT_WORK_TREE'] = path
      Dir.chdir(path) { yield path }
      ENV['GIT_WORK_TREE'] = old_work_tree
      FileUtils.rm_rf path, :secure => true if tmp_dir
    end

    # Get information about a file or directory in the repository
    #
    # @param [String] path The path of the file or directory to get information
    #        about
    # @return [Hash<Symbol, Object>] Information about the requested file or
    #         directory.
    def info(path)
      info = {}
      object = @git.tree/path
      raise FileNotFoundError.new(path) if object.nil?

      info[:history] = history path
      info[:mode]    = object.mode
      info[:name]    = object.name
      info[:path]    = path
      info[:sha]     = object.id

      info[:created]  = info[:history].last.committed_date
      info[:modified] = info[:history].first.committed_date

      if object.is_a? Grit::Blob
        info[:mime] = object.mime_type
        info[:size] = object.size
        info[:type] = :blob
      else
        info[:path] += '/'
        info[:type] = :tree
      end

      info
    end

    # Loads remotes from the backing Git repository's configuration
    #
    # @see Remote::Git
    def load_git_remotes
      @git.git.remote.split.each do |remote|
        url = @git.git.config({}, '--get', "remote.#{remote}.url").strip
        @remotes[remote] = Remote::Git.new(self, remote, url)
      end
    end

    # Prepares the Git repository backing this Silo repository for use with
    # Silo
    #
    # @raise [AlreadyPreparedError] if the repository has been already prepared
    def prepare
      raise AlreadyPreparedError.new(@path) if prepared?
      in_work_tree :tmp do
        FileUtils.touch '.silo'
        @git.add '.silo'
        @git.commit_index 'Enabled Silo for this repository'
      end
    end

    # Generate a history of Git commits for either the complete repository or
    # a specified file or directory
    #
    # @param [String] path The path of the file or directory to generate the
    #        history for. If +nil+, the history of the entire repository will
    #        be returned.
    # @return [Array<Grit::Commit>] The commit history for the repository or
    #         given path
    def history(path = nil)
      params = ['--format=raw']
      params += ['--', path] unless path.nil?
      output = @git.git.log({}, *params)
      Grit::Commit.list_from_string @git, output
    end

    # Return whether the Git repository backing this Silo repository has
    # already been prepared for use with Silo
    #
    # @return The preparation status of the backing Git repository
    def prepared?
      !(@git.tree/'.silo').nil?
    end

    # Purges a single file or the complete structure of a directory with the
    # given path from the repository
    #
    # *WARNING*: This will cause a complete rewrite of the repository history
    # and therefore deletes the data completely.
    #
    # @param [String] path The path of the file or directory to purge from the
    #        repository
    # @param [Boolean] prune Remove empty commits in the Git history
    def purge(path, prune = true)
      object = @git.tree/path
      raise FileNotFoundError.new(path) if object.nil?
      if object.is_a? Grit::Tree
        (object.blobs + object.trees).each do |blob|
          purge File.join(path, blob.basename), prune
        end
      else
        params = ['-f', '--index-filter',
                  "git rm --cached --ignore-unmatch #{path}"]
        params << '--prune-empty' if prune
        params << 'HEAD'
        @git.git.filter_branch({}, *params)
      end
    end

    # Removes the remote with the given name from this repository
    #
    # @param [String] name The name of the remote to remove
    # @see Remote
    def remove_remote(name)
      remote = @remotes[name]
      raise UndefinedRemoteError.new(name) if remote.nil?
      remote.remove
      @remotes[name] = nil
    end

    # Restores a single file or the complete structure of a directory with the
    # given path from the repository
    #
    # @param [String] path The path of the file or directory to restore from
    #        the repository
    # @param [String] prefix An optional prefix where the file is restored
    def restore(path, prefix = '.')
      object = @git.tree/path
      raise FileNotFoundError.new(path) if object.nil?
      if object.is_a? Grit::Tree
        FileUtils.mkdir File.join(prefix, path)
        (object.blobs + object.trees).each do |blob|
          restore File.join(path, blob.basename), prefix
        end
      else
        file = File.new File.join(prefix, path), 'w'
        file.write object.data
        file.close
      end
    end

  end

end
