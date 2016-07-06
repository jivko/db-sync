namespace :db do
  namespace :sync do
    desc 'Download data from the databse into files.'
    task down: :environment do
      tables = ENV['tables'].present? ? ENV['tables'].split(',') : nil
      synchronizer = Db::Sync.new(sync_dir, tables)
      synchronizer.sync_down
    end

    desc 'Upload data from the files into the database.'
    task up: :environment do
      tables = ENV['tables'].present? ? ENV['tables'].split(',') : nil
      commit = ENV['commit'].present? ? ENV['commit'] == 'true' : nil
      synchronizer = Db::Sync.new(sync_dir, tables)
      sync_up_and_print(synchronizer, commit)
      if commit.nil? && synchronizer.log.present?
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

def self.sync_dir
  ENV['dir']
end
