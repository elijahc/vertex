namespace :bp do
  desc "Create new parser"
  task :new_parser do
    `touch ./app/parsers/new_parser.rb`
  end
end
