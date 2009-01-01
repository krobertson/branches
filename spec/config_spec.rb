require File.join(File.dirname(__FILE__), '..', 'lib', 'branches')

describe 'Branches.config' do
  before(:all) do

    Branches.config do
      keydir 'keys'

      global do |g|
        g.write = 'ken'
        g.read << 'sam'
      end

      repo 'branches' do |r|
        r.read = 'john'
        r.write = 'jane'
      end
    end
  
  end

  after(:all) do
    Branches.reset
  end
  
  describe 'keydir' do
    it 'should accept the directory' do
      Branches.keydir.should == 'keys'
    end
  end

  describe 'global' do
    it 'should track global write access WITH reads' do
      Branches.global.write.should include('ken')
    end
    
    it 'should track global read access' do
      Branches.global.read.should include('sam', 'ken')
    end
  end

  describe 'repos' do
    it 'should contain the specified repos' do
      Branches.repos.size.should == 1
      Branches.repos.keys.should include('branches')
    end
    
    it 'should track write access' do
      Branches.repos['branches'].write.should include('jane')
    end

    it 'should track read access' do
      Branches.repos['branches'].read.should include('john', 'jane')
    end

    it 'should store repos with .git chopped off' do
      Branches.repo('repo.git') { |r| r.read << 'ken' }
      Branches.repos.keys.should include('repo')
      Branches.repos.keys.should_not include('repo.git')
    end
  end
end