require File.join(File.dirname(__FILE__), '..', 'lib', 'branches_setup')
require 'mocha'
require 'tempfile'

describe 'Branches::Setup' do
  describe 'setup_config_repo' do
    before(:all) do
      @path = File.join(File.dirname(__FILE__), 'repos', 'branches-admin')
      @tmpkey = Tempfile.new('admin_key')
      @tmpkey.write 'test'
      @tmpkey.close
      Branches::Setup.setup_config_repo(@path, @tmpkey.path)
    end

    after(:all) do
      FileUtils.rm_rf(@path)
      @tmpkey.unlink
    end

    it 'should create the given folder' do
      File.exist?(@path).should == true
      File.directory?(@path).should == true
    end
    
    it 'should contain a configuration file' do
      File.exist?(File.join(@path, 'config.rb')).should == true
    end
    
    it 'should contain the admin key' do
      File.exist?(File.join(@path, 'keys', 'admin')).should == true
    end
  end

  describe 'generate_authorized_keys' do
    it 'should create the authorized_keys file' do
      File.exist?(File.dirname(__FILE__), 'repos', '.ssh').should_not == true
      
      Branches::Setup.generate_authorized_keys(@path, @tmpkey.path)
    end
  end
end