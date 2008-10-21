module Branches
  class << self
    def config(&block)
      # initialize objects, if needed
      @@users ||= {}
      @@repos ||= {}
      @@global ||= Global.new
      @@repository_path ||= '~'
     
      # process the block
      class_eval(&block)
      
      # do some merging
      @@global.read = (@@global.read + @@global.write).uniq
      @@repos.each { |k,v| v.read = (v.read + v.write).uniq }

      @@repos
    end

    def user(name, keyfile=nil)
      @@users[name] = User.new(name, keyfile)
    end

    def global(&block)
      @@global.instance_eval(&block) unless block.nil?
      @@global
    end

    def repo(path, &block)
      r = Repo.new(path)
      r.instance_eval(&block)
      @@repos[path] = r
      r
    end

    def repos
      @@repos
    end

    def users
      @@users
    end

    def repository_path
      @@repository_path
    end

    def repository_path=(value)
      @@repository_path = value
    end
  end
end