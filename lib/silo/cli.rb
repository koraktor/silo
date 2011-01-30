# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2011, Sebastian Staudt

require 'rubygems'
require 'rubikon'

module Silo

  # This class is a Rubikon application that implements the command-line
  # interface for Silo
  #
  # @author Sebastian Staudt
  # @since 0.1.0
  class CLI < Rubikon::Application::Base

    # Changes the current repository
    #
    # @see #repo
    attr_writer :repo

    set :config_file, '.silo'
    set :config_format, :ini
    set :help_banner, 'Usage: silo'

    global_option :repository, :repo_path do
      self.repo = Repository.new repo_path
    end

    pre_execute do
      if config.empty?
        puts "y{Warning:} Configuration file(s) could not be loaded.\n\n"
      else
        @prefix = config['repository']['prefix']
        self.repo = Repository.new config['repository']['path']
      end
    end

    default '<hidden>' do
      puts "This is Silo. A Git-based backup utility.\n\n"
      call :help
    end

    option :prefix, 'The prefix path inside the repository to store the files to', :path
    command :add, 'Store one or more files in the repository', :files => :remainder do
      files.uniq.each do |file|
        repo.add file, prefix.path || @prefix
      end
    end

    command :distribute, 'Push repository contents to remote repositories' do
      repo.distribute
    end

    command :info, 'Get information about repository contents', :files => :remainder do
      files.uniq.each do |path|
        info = repo.info path
        puts '' unless path == args.first
        puts "#{info[:type] == :blob ? 'File' : 'Directory'}: #{info[:path]}"
        if info[:type] == :blob
          puts "  Size:             #{info[:size].to_s.
            gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")} bytes"
          puts "  MIME-Type:        #{info[:mime]}"
        end
        puts "  Created at:       #{info[:created]}"
        puts "  Last modified at: #{info[:modified]}"

        if $VERBOSE
          puts "  Initial commit:   #{info[:history].last.id}"
          puts "  Last commit:      #{info[:history].first.id}"
          puts "  Mode:             #{info[:mode]}"
          puts "  #{info[:type].to_s.capitalize}-ID:          #{info[:sha]}"
        end
      end
    end

    command :init, 'Initialize a Silo repository', :path => :optional do
      path = File.expand_path(path || '.')
      puts "Initializing Silo repository in #{path}..."
      Repository.new path
    end

    flag :l
    flag :r
    command :list, 'List the contents of a repository', :paths => [ :remainder, :optional ] do
      paths = self.paths || [nil]
      contents = []
      paths.each do |path|
        new_contents = repo.contents path
        puts "y{Warning:} File '#{path}' does not exist in the repository." if new_contents.empty?
        contents |= new_contents
      end

      contents.reverse! if r.given?

      unless l.given?
        col_size = contents.max_by { |path| path.size }.size + 1
        contents.each { |path| put path.ljust(col_size) }
        puts ''
      else
        contents.each { |path| puts path }
      end
    end

    command :remote, 'Add or remove remote repositories', { :action => ['add', 'rm', :optional], :name => :optional, :url => :optional } do
      usage = lambda do
        puts 'usage: silo remote add <name> <url>'
        puts '   or: silo remote rm <name>'
      end
      case action
        when nil
          repo.remotes.each_value do |remote|
            info = remote.name
            info += "  #{remote.url}" if $VERBOSE
            puts info
          end
        when 'add'
          if url.nil?
            repo.add_remote name, url
          else
            usage.call
          end
        when 'rm'
          unless url.nil?
            repo.remove_remote name
          else
            usage.call
          end
        else
          usage.call
      end
    end

    option :prefix, 'The prefix path to store the files to', :path
    command :restore, 'Restore one or more files or directories from the repository', :files => :remainder do
      files.uniq.each do |file|
        repo.restore file, prefix.path || '.'
      end
    end

    flag :'no-clean', "Don't remove empty commits from the Git history"
    command :purge, 'Permanently remove one or more files or directories from the repository', :files => :remainder do
      files.uniq.each do |file|
        repo.purge file, !given?(:'no-clean')
      end
    end

    command :rm => :remove
    command :remove, 'Remove one or more files or directories from the repository', :files => :remainder do
      files.uniq.each do |file|
        repo.remove file
      end
    end

    # Returns the current repository
    #
    # @return [Repository] The currently configured Silo repository
    # @raise [RuntimeError] if no repository is configured
    def repo
      raise 'No repository configured.' if @repo.nil?
      @repo
    end

  end

end
