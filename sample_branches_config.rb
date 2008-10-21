Branches.config do
  user 'ken', 'keys/ken.pub'
  user 'john', 'keys/john.pub'
  user 'jane', 'keys/jane.pub'

  global do |g|
    g.write = 'ken'
  end

	repo 'branches' do |r|
	  r.read = 'john'
	  r.write = 'jane'
	  r.hooks = 'rake sometask'
  end
end