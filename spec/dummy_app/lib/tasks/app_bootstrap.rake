namespace :db do
  desc "DB: drop, create, migrate"
  task bootstrap: :environment do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
  end
end