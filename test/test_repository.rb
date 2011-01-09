# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2011, Sebastian Staudt

require 'pathname'
require 'tmpdir'

require 'helper'

class TestRepository < Test::Unit::TestCase

  context 'A new backup repository' do

    setup do
      @dir = Dir.mktmpdir
      Dir.rmdir @dir
    end

    should 'contain a bare Git repository prepared for Silo by default' do
      repo = Repository.new @dir
      assert repo.git.is_a? Grit::Repo
      assert repo.prepared?
      assert_equal 1, repo.git.commits.size
      assert_equal 'Enabled Silo for this repository', repo.git.commits.first.message
    end

    should 'contain a plain Git repository when option :prepare is false' do
      repo = Repository.new @dir, :prepare => false
      assert repo.git.is_a? Grit::Repo
      assert !repo.prepared?
      assert_equal 0, repo.git.commits.size
    end

    should 'fail when option :create is false and the target directory does not exist' do
      assert_raise Grit::NoSuchPathError do
        Repository.new @dir, :create => false
      end
    end

    should 'fail if the target directory exists but is not an empty Git repository' do
      assert_raise Grit::InvalidGitRepositoryError do
        Repository.new File.dirname(__FILE__)
      end

      assert_raise InvalidRepositoryError do
        Repository.new File.join(File.dirname(File.dirname(__FILE__)), '.git')
      end
    end

  end

  context 'An existing backup repository' do

    setup do
      @repo_dir = Dir.mktmpdir
      `git init --bare #{@repo_dir}`
      ENV['GIT_DIR'] = @repo_dir
      ENV['GIT_WORK_TREE'] = File.expand_path '.'
      FileUtils.touch '.silo'
      `git add .silo`
      `git commit -m "Enabled Silo for this repository"`
      ENV['GIT_WORK_TREE'] = nil
      @repo = Repository.new @repo_dir
    end

    should 'contain a Git repository' do
      assert @repo.git.is_a? Grit::Repo
    end

    should 'be prepared' do
      assert_equal 1, @repo.git.commits.size
      assert @repo.prepared?
    end

    should 'not allow re-preparing the repository' do
      assert_raise AlreadyPreparedError do
        @repo.prepare
      end
    end

    teardown do
      FileUtils.rm_rf [@repo_dir, '.silo'], :secure => true
    end

  end

  context 'Backing up and restoring' do

    setup do
      @data_dir = Pathname.new(File.expand_path File.dirname(__FILE__)) + 'data'
      @repo_dir = Dir.mktmpdir
      @repo     = Repository.new @repo_dir
    end

    should 'save single files correctly' do
      @repo.add(@data_dir + 'file1')
      @repo.add(@data_dir + 'file2')

      assert_equal 3, @repo.git.commits.size
      assert (@repo.git.tree/('file1')).is_a?(Grit::Blob)
      assert (@repo.git.tree/('file2')).is_a?(Grit::Blob)
      assert_equal "Added file #{@data_dir + 'file1'} into '.'", @repo.git.commits[1].message
      assert_equal "Added file #{@data_dir + 'file2'} into '.'", @repo.git.commits[2].message
    end

    should 'save directory trees correctly' do
      @repo.add @data_dir

      assert_equal 2, @repo.git.commits.size
      assert_equal "Added directory #{@data_dir} into '.'", @repo.git.commits[1].message
      assert (@repo.git.tree/('data/file1')).is_a?(Grit::Blob)
      assert (@repo.git.tree/('data/file2')).is_a?(Grit::Blob)
      assert (@repo.git.tree/('data/subdir1')).is_a?(Grit::Tree)
      assert (@repo.git.tree/('data/subdir1/file1')).is_a?(Grit::Blob)
      assert (@repo.git.tree/('data/subdir2')).is_a?(Grit::Tree)
      assert (@repo.git.tree/('data/subdir2/file2')).is_a?(Grit::Blob)
    end

    should 'save single files correctly into a prefix directory' do
      @repo.add(@data_dir + 'file1', 'prefix')
      @repo.add(@data_dir + 'file2', 'prefix')

      assert_equal 3, @repo.git.commits.size
      assert (@repo.git.tree/('prefix/file1')).is_a?(Grit::Blob)
      assert (@repo.git.tree/('prefix/file2')).is_a?(Grit::Blob)
      assert_equal "Added file #{@data_dir + 'file1'} into 'prefix'", @repo.git.commits[1].message
      assert_equal "Added file #{@data_dir + 'file2'} into 'prefix'", @repo.git.commits[2].message
    end

    should 'save directory trees correctly into a prefix directory' do
      @repo.add @data_dir, 'prefix'

      assert_equal 2, @repo.git.commits.size
      assert_equal "Added directory #{@data_dir} into 'prefix'", @repo.git.commits[1].message
      assert (@repo.git.tree/('prefix/data/file1')).is_a?(Grit::Blob)
      assert (@repo.git.tree/('prefix/data/file2')).is_a?(Grit::Blob)
      assert (@repo.git.tree/('prefix/data/subdir1')).is_a?(Grit::Tree)
      assert (@repo.git.tree/('prefix/data/subdir1/file1')).is_a?(Grit::Blob)
      assert (@repo.git.tree/('prefix/data/subdir2')).is_a?(Grit::Tree)
      assert (@repo.git.tree/('prefix/data/subdir2/file2')).is_a?(Grit::Blob)
    end

    teardown do
      FileUtils.rm_rf @repo_dir, :secure => true
    end

  end

end
