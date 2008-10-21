require File.join(File.dirname(__FILE__), '..', 'lib', 'branches')

describe 'Global' do
  it 'should accept an array for read' do
    g = Branches::Global.new
    g.read = ['ken', 'john']
    g.read.should == ['ken', 'john']
  end

  it 'should accept an array for write' do
    g = Branches::Global.new
    g.write = ['ken', 'john']
    g.write.should == ['ken', 'john']
  end

  it 'should accept a string for read' do
    g = Branches::Global.new
    g.read = 'ken,john'
    g.read.should == ['ken', 'john']
  end

  it 'should accept a string for write' do
    g = Branches::Global.new
    g.write = 'ken,john'
    g.write.should == ['ken', 'john']
  end
end

describe 'Repo' do
  it 'should chomp off .git extensions' do
    r = Branches::Repo.new('repo.git')
    r.path.should == 'repo'
  end
end