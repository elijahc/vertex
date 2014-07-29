# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
cores = ['BsiSpecimenPipeline', 'SleepJob']

(cores - Core.all.map{|c| c.class_name}).each do |c|
  Core.create({class_name: c})
end

bsi_instances = [
  {:name => 'Mirror', :url => 'https://websvc-mirror.bsisystems.com:2271/bsi/xmlrpc'},
  {:name => 'Production', :url => 'https://websvc.bsisystems.com:2262/bsi/xmlrpc'}
]

bsi_instances.each do |instance|
  BsiInstance.create(instance)
end
