require File.join(File.dirname(__FILE__), '..', 'lib', 'setup')
require 'mocha'

describe 'Branches::Setup' do
  describe 'setup_config_repo' do
    before(:all) do
      @path = File.join(File.dirname(__FILE__), 'repos', 'branches-admin')
      Branches::Setup.setup_config_repo(@path)
    end

    after(:all) do
      FileUtils.rm_rf(@path)
    end

    it 'should create the given folder' do
      Dir.exist?(@path).should == true
    end
    
    it 'should contain a configuration file' do
      File.exist?(File.join(@path, 'config.rb')).should == true
    end
    
    it 'should contain the admin key' do
      File.exist?(File.join(@path, 'keys', 'admin')).should == true
    end
  end
end