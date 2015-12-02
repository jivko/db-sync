namespace :db do
  namespace :sync do
    desc 'Dump data from the databse into a file.'
    task :dump do
      print 'dumping'
    end

    desc 'Load data from the yaml into a file.'
    task :load do
      print 'loading'
    end
  end
end
