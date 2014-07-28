# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
e = User.all.first
j = Job.create(name: 'Test Job', job_type: 'test', spec: '/dev/null')

cores = ['BsiSpecimenPipeline', 'Asylum', 'SleepJob']

(cores - Core.all.map{|c| c.class_name}).each do |c|
  Core.create({class_name: c})
end
