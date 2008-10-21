require File.join(File.dirname(__FILE__), '..', 'lib', 'branches')

describe 'Branches.config' do
  before(:all) do

    Branches.config do
      user 'ken', 'keys/ken.pub'
      user 'john', 'keys/john.pub'
      user 'jane'

      global do |g|
        g.write = 'ken'
      end

      repo 'branches' do |r|
        r.read = 'john'
        r.write = 'jane'
        r.hooks = 'rake sometask'
      end
    end
  
  end
  
  describe 'users' do
    it 'should accept users' do
      Branches.users.size.should == 3
    end

    it 'should have their key path' do
      Branches.users['ken'].keyfile.should == 'keys/ken.pub'
      Branches.users['john'].keyfile.should == 'keys/john.pub'
    end

    it 'should allow users with no keyfile given' do
      Branches.users['jane'].keyfile.should == nil
    end
  end
end