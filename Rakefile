require 'pathname'

class ThisProject
  def self.this_file_path
    Pathname.new( __FILE__ ).expand_path
  end

  def self.project_root
    this_file_path.dirname
  end

  def self.this_file_path
    Pathname.new( __FILE__ ).expand_path
  end

  def self.project_path( *relative_path )
    project_root.join( *relative_path )
  end

  def self.version
    path = project_path( "init.rb" )
    line = path.read[/^\s*VERSION\s*=\s*.*/]
    if line then
      return line.match(/.*VERSION\s*=\s*['"](.*)['"]/)[1]
    end
  end

  def self.release_branch
    "main"
  end
end

task :version do
  puts ThisProject.version
end

task :release_check do
  unless `git branch` =~ /^\* #{ThisProject.release_branch}/
    abort "You must be on the #{ThisProject.release_branch} branch to release!"
  end
  unless `git status` =~ /^nothing to commit/m
    abort "Nope, sorry, you have unfinished business"
  end
end

desc "Create tag v#{ThisProject.version} and generate release on github"
task :release => [ :release_check ] do
  sh "git commit --allow-empty -a -m 'Release #{ThisProject.version}'"
  sh "git tag -a -m 'v#{ThisProject.version}' v#{ThisProject.version}"
  sh "git push origin #{ThisProject.release_branch}"
  sh "git push origin v#{ThisProject.version}"
end
