# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#create location types
location_types = [
  'Region', 'District', 'Hospital / Health facility'
]

location_types.select do |name|
  LocationType.create(name: name)
end


#create case types
case_types = [
  'New on ART', 'Re-Initiated', 'Transferred-In','Defaulted first month',
  'Stopped','Died','Transferred Out','Defaulted second month','Defaulted third month'
]

case_types.select do |name|
  IndicatorType.create(name: name)
end

#create indicator types
age_group = [
  '15-19','20-24', '25-29', '30-34','35-39','40-44',
  '45-49', '50+','<1','1-4','5-9','10-14','Unknown Age'
]

indicator_types = {}
indicator_types['Males'] = age_group
indicator_types['Females'] = age_group

indicator_types.select do |name, attrs|
  attrs.select do |a|
    CaseType.create(name: "#{name} #{a}")
  end
end

region_location_type_id = LocationType.find_by(name: 'Region').id
district_location_type_id = LocationType.find_by(name: 'District').id
hc_location_type_id = LocationType.find_by(name: 'Hospital / Health facility').id

spreadsheet = Roo::Spreadsheet.open("#{Rails.root}/db/data/List_of_all_eSites.xlsx")
header = spreadsheet.row(1)
(2..spreadsheet.last_row).each do |i|
  row = Hash[[header, spreadsheet.row(i)].transpose]
  region_name, district_name = row["Region"], row["District"]
  ecard = row['CDC Full site list 2']
  poc = row['EMR Sites']

  next if region_name.blank? 
  region = Location.find_by(name: region_name)
  region = Location.create(name: region_name,
    location_type_id: region_location_type_id) if region.blank?

  district = Location.find_by(name: district_name)
  district = Location.create(name: district_name, 
    location_type_id: district_location_type_id, 
      parent_location: region.id) if district.blank? 

  Location.create(name: ecard, 
    location_type_id: hc_location_type_id, 
      parent_location: district.id) unless ecard.blank? 

  Location.create(name: poc, 
    location_type_id: hc_location_type_id, 
      parent_location: district.id) unless poc.blank? 

  puts "Created #{poc} ..." unless poc.blank?
  puts "Created #{ecard} ..." unless ecard.blank?
end
