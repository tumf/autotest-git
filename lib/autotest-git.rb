#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require "autotest"
require "git"

class AutotestGit < Autotest

  def git_update?
    git = Git.open(".")
    sha = git.object("HEAD").sha
    return false if sha == @sha
    @sha = sha
    true
  end

  def run_tests
    hook :run_command
    new_mtime = self.find_files_to_test
    return unless new_mtime
    self.last_mtime = new_mtime

    cmd = self.make_test_cmd self.files_to_test
    return if cmd.empty?

    # check if commited
    return unless git_update? 

    puts cmd unless options[:quiet]

    old_sync = $stdout.sync
    $stdout.sync = true
    self.results = []
    line = []
    begin
      open "| #{cmd}", "r" do |f|
        until f.eof? do
          c = f.getc or break
          if RUBY19 then
            print c
          else
            putc c
          end
          line << c
          if c == ?\n then
            self.results << if RUBY19 then
                              line.join
                            else
                              line.pack "c*"
                            end
            line.clear
          end
        end
      end
    ensure
      $stdout.sync = old_sync
    end
    hook :ran_command
    self.results = self.results.join

    handle_results self.results
  end
end
