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

      def run
        begin
          # get the user
          user = ARGV[0]
          raise 'Mussing argument: USER' unless user

          # get the ssh command
          command = ENV['SSH_ORIGINAL_COMMAND']
          raise 'Missing SSH_ORIGINAL_COMMAND environment variable' unless command

          # move to the home directory
          Dir.chdir('~')
          File.umask(0022)

          # move to processing
          process(user, command)
        rescue => e
          STDERR.puts e
        end
      end

      def process(user, command)
        # load the configuration file
        load 'branches.config'

        # move to the repository path
        Dir.chdir(File.expand_path(Branches.repository_path))

        # get the command
        command, path = get_command(command)

        # add .git suffix if not found
        path += '.git' if path !~ /\.git$/

        # determine access type
        access = :read if COMMANDS_READ.include?(command)
        access = :write if COMMANDS_WRITE.include?(command)

        # check permissions
        raise 'Permission denied to the request repository' unless check_access(path, user, access)

        # enure it exists
        init_repository(path) unless File.directory?(path)

        # execute command
        system('git', 'shell', '-c', "#{command} '#{path}'")
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

        # chomp the .git
        path = path.chomp('.git')

        # get the repository and check its access level
        Branches.repos[path].send(access).include?(user) if Branches.repos.has_key?(path)

        # record doesn't exist, no access
        false
      end
    end
  end
end