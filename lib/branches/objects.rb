module Branches
  class Global
    attr_accessor :read, :write, :hooks
    
    def initialize
      @read = []
      @write = []
    end

    def read=(value)
      @read = value.is_a?(Array) ? value : value.split(',')
    end

    def write=(value)
      @write = value.is_a?(Array) ? value : value.split(',')
    end
  end

  class Repo < Global
    attr_accessor :path
    def initialize(path)
      @path = path.chomp('.git')
      @read = []
      @write = []
    end
  end

  class User
    attr_accessor :name, :keyfile

    def initialize(name, keyfile=nil)
      @name = name
      @keyfile = keyfile
    end
  end
end