require 'fileutils'

module Branches
  module Service
    class << self
      PATH_FILTER = Regexp.new("^'/*([a-zA-Z0-9][a-zA-Z0-9@._-]*(/[a-zA-Z0-9][a-zA-Z0-9@._-]*)*)'$")
      COMMANDS_READ = [
          'git-upload-pack',
          'git upload-pack',
          ]
      COMMANDS_WRITE = [
          'git-receive-pack',
          'git receive-pack',
          ]

      def run(opts)
        # get the ssh command
        command = ENV['SSH_ORIGINAL_COMMAND']
        raise 'Missing SSH_ORIGINAL_COMMAND environment variable' unless command

        # move to the home directory
        Dir.chdir(File.expand_path('~')) do
          # set the umask
          File.umask(0022)

          # load the configuration file
          load opts[:config]

          # move to processing
          args = process(opts[:user], command)
          
          # run it!
          system(*args)
        end
      end

      def process(user, command)
        # move to the repository path
        Dir.chdir(File.expand_path(Branches.repository_path)) do
          # get the command
          command, path = get_command(command)

          # chomp the .git, non .git takes precedence
          path = path.chomp('.git')

          # determine access type
          access = :read if COMMANDS_READ.include?(command)
          access = :write if COMMANDS_WRITE.include?(command)

          # check permissions
          raise 'Permission denied to the request repository' unless check_access(path, user, access)

          # enure it exists, without .git, then try it with .git, then create it with .git
          path += '.git' unless File.directory?(path)
          init_repository(path) unless File.directory?(path)

          # execute command
          ['git', 'shell', '-c', "#{command} '#{path}'"]
        end
      end

      def init_repository(path)
        FileUtils.mkdir_p(path, :mode => 0750)
        %x[git --git-dir=#{path} init]
      end

      def get_command(original)
        # check for newline
        raise 'Newline not allowed in commands' if original.include?("\n")

        # split first part
        command, path = original.split(' ', 2)

        # see if command is just 'git'
        if command == 'git'
          subcommand, path = path.split(' ', 2)
          command = "#{command} #{subcommand}"
        end
        
        # check the access request type
        raise 'Command not allowed' unless COMMANDS_READ.include?(command) || COMMANDS_WRITE.include?(command)
        
        # validate the path
        match = PATH_FILTER.match(path)
        raise 'Unsafe arguments' unless match && match[1] && !match[1].empty?
        path = match[1]

        [command, path]
      end

      def check_access(path, user, access)
        # if they have global access, grant it
        return true if Branches.global.send(access).include?(user)

        # get the repository and check its access level
        return Branches.repos[path].send(access).include?(user) if Branches.repos.has_key?(path)

        # record doesn't exist, no access
        false
      end
    end
  end
end