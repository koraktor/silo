# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2011, Sebastian Staudt

require 'tmpdir'

require 'helper'
require 'core_ext/pathname'

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
      @data_dir   = Pathname.new(File.dirname(__FILE__))/'data'
      @repo       = Repository.new Dir.mktmpdir
      @old_pwd    = Dir.pwd
      @target_dir = Pathname.new Dir.mktmpdir
      @work_dir   = Pathname.new Dir.mktmpdir
      Dir.chdir @work_dir
    end

    should 'save single files correctly' do
      @repo.add @data_dir/'file1'
      @repo.add @data_dir/'file2'

      assert_equal 3, @repo.git.commits.size
      assert (@repo.git.tree/('file1')).is_a? Grit::Blob
      assert (@repo.git.tree/('file2')).is_a? Grit::Blob
      assert_equal "Added file #{@data_dir + 'file1'} into '/'", @repo.git.commits[1].message
      assert_equal "Added file #{@data_dir + 'file2'} into '/'", @repo.git.commits[2].message
      assert_equal %w{.silo file1 file2}, @repo.contents

      assert_raise FileNotFoundError do
        @repo.restore 'file3'
      end
    end

    should 'save directory trees correctly' do
      @repo.add @data_dir

      assert_equal 2, @repo.git.commits.size
      assert_equal "Added directory #{@data_dir} into '/'", @repo.git.commits[1].message
      assert (@repo.git.tree/('data/file1')).is_a? Grit::Blob
      assert (@repo.git.tree/('data/file2')).is_a? Grit::Blob
      assert (@repo.git.tree/('data/subdir1')).is_a? Grit::Tree
      assert (@repo.git.tree/('data/subdir1/file1')).is_a? Grit::Blob
      assert (@repo.git.tree/('data/subdir2')).is_a? Grit::Tree
      assert (@repo.git.tree/('data/subdir2/file2')).is_a? Grit::Blob
      assert_equal %w{data data/file1 data/file2 data/subdir1 data/subdir1/file1 data/subdir2 data/subdir2/file2}, @repo.contents('data')
      assert_equal %w{data/subdir1 data/subdir1/file1}, @repo.contents('data/subdir1')
      assert_equal %w{data/subdir2 data/subdir2/file2}, @repo.contents('data/subdir2')

      assert_raise FileNotFoundError do
        @repo.restore 'file1'
      end
    end

    should 'save single files correctly into a prefix directory' do
      @repo.add @data_dir/'file1', 'prefix'
      @repo.add @data_dir/'file2', 'prefix'

      assert_equal 3, @repo.git.commits.size
      assert (@repo.git.tree/('prefix/file1')).is_a? Grit::Blob
      assert (@repo.git.tree/('prefix/file2')).is_a? Grit::Blob
      assert_equal "Added file #{@data_dir + 'file1'} into 'prefix'", @repo.git.commits[1].message
      assert_equal "Added file #{@data_dir + 'file2'} into 'prefix'", @repo.git.commits[2].message

      assert_raise FileNotFoundError do
        @repo.restore 'file1'
      end
    end

    should 'save directory trees correctly into a prefix directory' do
      @repo.add @data_dir, 'prefix'

      assert_equal 2, @repo.git.commits.size
      assert_equal "Added directory #{@data_dir} into 'prefix'", @repo.git.commits[1].message
      assert (@repo.git.tree/('prefix/data/file1')).is_a? Grit::Blob
      assert (@repo.git.tree/('prefix/data/file2')).is_a? Grit::Blob
      assert (@repo.git.tree/('prefix/data/subdir1')).is_a? Grit::Tree
      assert (@repo.git.tree/('prefix/data/subdir1/file1')).is_a? Grit::Blob
      assert (@repo.git.tree/('prefix/data/subdir2')).is_a? Grit::Tree
      assert (@repo.git.tree/('prefix/data/subdir2/file2')).is_a? Grit::Blob

      assert_raise FileNotFoundError do
        @repo.restore 'prefix/file1'
      end
    end

    should 'restore single files correctly' do
      @repo.add @data_dir
      @repo.add @data_dir/'file1'
      @repo.restore 'file1'
      @repo.restore 'data/file2', @target_dir

      assert File.exist? @work_dir/'file1'
      assert File.exist? @target_dir/'file2'
    end

    should 'restore directory trees correctly' do
      @repo.add @data_dir
      @repo.restore 'data'
      @repo.restore 'data/subdir1', @target_dir

      assert File.exist? @work_dir/'data/file1'
      assert File.exist? @work_dir/'data/file2'
      assert File.exist? @work_dir/'data/subdir1/file1'
      assert File.exist? @work_dir/'data/subdir2/file2'

      assert File.exist? @target_dir/'subdir1'
      assert File.exist? @target_dir/'subdir1/file1'
    end

    should 'remove files and directories correctly' do
      @repo.add @data_dir
      @repo.add @data_dir/'file1'

      @repo.remove 'data/file1'
      assert_equal 4, @repo.git.commits.size
      assert (@repo.git.tree/'data/file1').nil?

      @repo.remove 'data'
      assert_equal 5, @repo.git.commits.size
      assert (@repo.git.tree/'data').nil?

      @repo.remove 'file1'
      assert_equal 6, @repo.git.commits.size
      assert (@repo.git.tree/'file1').nil?
    end

    should 'purge files and directories correctly' do
      @repo.add @data_dir
      @repo.add @data_dir/'file1'

      @repo.purge 'data/file1'
      assert_equal 3, @repo.git.commits.size
      assert (@repo.git.tree/'data/file1').nil?

      @repo.purge 'data'
      assert_equal 2, @repo.git.commits.size
      assert (@repo.git.tree/'data').nil?

      @repo.purge 'file1'
      assert_equal 1, @repo.git.commits.size
      assert (@repo.git.tree/'file1').nil?

      @repo.add @data_dir
      @repo.add @data_dir/'file1'

      @repo.purge 'data', false
      @repo.purge 'file1', false
      assert_equal 3, @repo.git.commits.size
      assert (@repo.git.tree/'data').nil?
      assert (@repo.git.tree/'file1').nil?
    end

    teardown do
      Dir.chdir @old_pwd
      FileUtils.rm_rf [@repo.path, @work_dir, @target_dir], :secure => true
    end

  end

end
