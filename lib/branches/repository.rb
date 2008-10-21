module Branches
  module Repository
    class << self
      def init(path)
        FileUtils.mkdir_p(path, :mode => 0750)
        exec('git', "--git-dir=#{path}", 'init')
      end
    end
  end
end