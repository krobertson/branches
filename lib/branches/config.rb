module Branches
  class << self
    def config(&block)
      # initialize objects, if needed
      reset

      # process the block
      class_eval(&block)
      
      # do some merging
      @@global.read = (@@global.read + @@global.write).uniq
      @@repos.each { |k,v| v.read = (v.read + v.write).uniq }

      @@repos
    end

    def reset
      @@keydir = 'keys'
      @@repos = {}
      @@global = Global.new
      @@repository_path = '~'
    end

    def global(&block)
      @@global.instance_eval(&block) unless block.nil?
      @@global
    end

    def repo(path, &block)
      r = Repo.new(path)
      r.instance_eval(&block)
      @@repos[r.path] = r
      r
    end

    def repos
      @@repos
    end

    def keydir(path=nil)
      @@keydir = path if path
      @@keydir
    end

    def repository_path(value=nil)
      @@repository_path = value if value
      @@repository_path
    end
  end
end