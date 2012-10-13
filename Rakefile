#!/usr/bin/env rake
require "bundler/gem_tasks"
require "shellwords"

def gemspec
  @gemspec ||= Bundler.load_gemspec("foreman.gemspec")
end

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

def remove_task(task_name)
  Rake.application.remove_task(task_name)
end

remove_task :release
desc "Build and push minecraft-foreman-#{gemspec.version}.gem to gems.blolol.com"
task :release => [:build] do
  gem_path = File.join("pkg", "minecraft-foreman-#{gemspec.version}.gem")
  sh "curl -F file=@#{gem_path.shellescape} -u #{ENV["BLOLOL_GEMS_CREDENTIALS"].shellescape} #{ENV["BLOLOL_GEMS_APP_URL"]}"
end
