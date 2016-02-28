namespace :db do
  namespace :sync do
    desc 'Download data from the databse into files.'
    task down: :environment do
      Db::Sync.sync_down
    end

    desc 'Upload data from the files into the database.'
    task up: :environment do
      Db::Sync.sync_up
    end
  end
end
