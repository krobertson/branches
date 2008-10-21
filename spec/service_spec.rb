require File.join(File.dirname(__FILE__), '..', 'lib', 'branches')
require 'mocha'

describe 'Branches::Service' do
  before(:each) do
    Branches.reset
    Branches.config do
      repository_path File.join(File.dirname(__FILE__), 'repos')

      global do |g|
        g.write = 'ken'
        g.read = 'sam'
      end

      repo 'test' do |r|
        r.read = 'john'
        r.write = 'jane'
      end
    end
  end

  describe 'run' do
    before(:each) do
      ARGV[0] = 'ken'
      ENV['SSH_ORIGINAL_COMMAND'] = 'git-upload-pack test.git'
    end
    
    it 'should raise an error when no user given' do
      lambda do
        ARGV[0] = nil
        Branches::Service.run
      end.should raise_error('Missing argument: USER')
    end

    it 'should raise an error when no command given' do
      lambda do
        ENV['SSH_ORIGINAL_COMMAND'] = nil
        Branches::Service.run()
      end.should raise_error('Missing SSH_ORIGINAL_COMMAND environment variable')
    end

    it 'should set umask' do
      # basically wait for it to error out reading the config
      lambda { Branches::Service.run }.should raise_error(LoadError)
      File.umask.should == 0022
    end
  end

  describe 'process' do
    before(:all) do
      @output = Branches::Service.process('ken', 'git-upload-pack \'test.git\'')
    end
    
    it 'should accept a passed in repository path' do
      Branches.repository_path.should == File.join(File.dirname(__FILE__), 'repos')
    end

    it 'should return a valid command' do
      ['git', 'shell', '-c', "git-upload-pack 'test.git'"]
    end

    it 'should return valid command args' do
      @output.should == ['git', 'shell', '-c', "git-upload-pack 'test.git'"]
    end

    it 'should raise exception on invalid permissions' do
      lambda { Branches::Service.process('anonymous', 'git-upload-pack \'test.git\'') }.should raise_error('Permission denied to the request repository')
    end
  end

  describe 'get_command' do
    it 'should throw an exception if the command contains a new line' do
      lambda { Branches::Service.get_command("some\ncommand") }.should raise_error('Newline not allowed in commands')
    end

    it 'should throw an exception on non-allowed commands' do
      lambda { Branches::Service.get_command('echo \'test.git\'')  }.should raise_error('Command not allowed')
    end

    it 'should throw an exception for a poorly formatted path' do
      lambda { Branches::Service.get_command('git-upload-pack \'bad"path\'') }.should raise_error('Unsafe arguments')
    end

    it 'should accept proper commands' do
      Branches::Service.get_command('git-upload-pack \'test.git\'').should == ['git-upload-pack', 'test.git']
    end

    it 'should accept nested paths' do
      Branches::Service.get_command('git-upload-pack \'folder/test.git\'').should == ['git-upload-pack', 'folder/test.git']
    end

    it 'should accept commands with spaces' do
      Branches::Service.get_command('git upload-pack \'test.git\'').should == ['git upload-pack', 'test.git']
    end
  end

  describe 'check_access' do
    it 'should return valid for global permissions' do
      Branches::Service.check_access('test', 'ken', :write).should == true
    end

    it 'should accept non-present repo permissions for global' do
      Branches::Service.check_access('non-existant', 'ken', :write).should == true
    end

    it 'should process specific repository permissions' do
      Branches::Service.check_access('test', 'jane', :write).should == true
      Branches::Service.check_access('test', 'john', :write).should == false
    end

    it 'should chop a .git off before checking' do
      Branches::Service.check_access('test.git', 'jane', :write).should == true
      Branches::Service.check_access('test.git', 'john', :write).should == false
    end
  end
end