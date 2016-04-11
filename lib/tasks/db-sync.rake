namespace :db do
  namespace :sync do
    desc 'Download data from the databse into files.'
    task down: :environment do
      synchronizer = Db::Sync.new
      synchronizer.sync_down
    end

    desc 'Upload data from the files into the database.'
    task up: :environment do
      commit = ENV['commit'] == 'true'
      synchronizer = Db::Sync.new
      sync_up_and_print(synchronizer, commit)
      if !commit && synchronizer.log.present?
        print "Commit Changes? [y/n]\n"
        sync_up_and_print(synchronizer, true) if STDIN.gets.chomp == 'y'
      end
    end
  end
end

def self.sync_up_and_print(synchronizer, commit)
  synchronizer.sync_up(commit)
  print synchronizer.log.join("\n") + "\n"
end
