



def start
  create_hc_folders
  update_database
end

def create_hc_folders
  hc_location_type_id = LocationType.find_by(name: 'Hospital / Health facility').id

  Location.where(location_type_id: hc_location_type_id).each do |location|
    district = Location.find(location.parent_location)
    FileUtils.mkdir_p "/Users/mwatha/Drop/#{district.name}/#{location.name}"
  end

end

def update_database
  hc_location_type_id = LocationType.find_by(name: 'Hospital / Health facility').id

  Location.where(location_type_id: hc_location_type_id).each_with_index do |location, index|
    district = Location.find(location.parent_location)
    entries = Dir.entries("/Users/mwatha/Drop/#{district.name}/#{location.name}")

    (entries || []).each do |entry|
      if entry.match(/Quarterly|Cumulative/i)
        entry_datetime = entry.split('_')[1..-1].join('')
        entry_datetime = entry_datetime.split('.')[0..1].join("")
        date = entry_datetime[0..9]
        time = entry_datetime[10..-1]
        time = time[1..6].split("")
        
        set_time = []
        time.each_with_index do |t, i|
          set_time << t
          if i.odd?
            set_time << ':'
          end
        end

        encounter_datetime = "#{date} #{set_time.join('')[0..-2]}".to_time
        report_name = entry.match(/Quarterly/i) ? 'Quarterly' : 'Cumulative'
        process_file(report_name,entry,district, location, encounter_datetime)
      end
    end

  end

end


def process_file(report_name, file_name, district, facility, encounter_datetime)
  begin
    spreadsheet = Roo::Spreadsheet.open("/Users/mwatha/Drop/#{district.name}/#{facility.name}/#{file_name}")
  rescue
    puts "Error:  ..... #{district.name}, #{facility.name}, #{file_name}"
    return
  end
  set_gender = nil 
  
  0.upto(36).each do |i|
    gender, age_group, tx_curr, re_init, transfer_in, defual_one, 
      defual_two, defual_three,stopped, died, transfer_out =  spreadsheet.row(i) if report_name.match(/Quarterly/i)

    gender, age_group, tx_curr, defual_one, defual_two,
      defual_three,stopped, died, transfer_out =  spreadsheet.row(i) if report_name.match(/Cumulative/i)

    set_gender = (gender.blank? ? set_gender : gender)


    next if age_group.blank?
    next if age_group.split.join.blank?
    case_type = CaseType.find_by(name: "#{set_gender} #{age_group}")
    puts "--- #{case_type.name}"

    reported_case = create_case(report_name, facility, case_type, encounter_datetime)
    
    indicators = [
      ['New on ART', tx_curr],
      ['Re-Initiated', re_init],
      ['Transferred-In',transfer_in],
      ['Defaulted first month', defual_one],
      ['Defaulted second month', defual_two],
      ['Defaulted third month', defual_three],
      ['Stopped', stopped],
      ['Died', died],
      ['Transferred Out', transfer_out]
    ] if report_name.match(/Quarterly/i)

    indicators = [
      ['New on ART', tx_curr],
      ['Defaulted first month', defual_one],
      ['Defaulted second month', defual_two],
      ['Defaulted third month', defual_three],
      ['Stopped', stopped],
      ['Died', died],
      ['Transferred Out', transfer_out]
    ] if report_name.match(/Cumulative/i)


    indicators.each do |indicator_name, val|
      i = create_indicator(reported_case, indicator_name, val)
      puts "Create: #{report_name}:::#{indicator_name} ---- #{val} ..."
    end

  end

end

def create_case(report_name, facility, case_type, encounter_datetime)
  reported_case = Case.find_by(location_id: facility.id, 
    case_type_id: case_type.id,
      case_reported_datetime: encounter_datetime)
  
  reported_case = Case.create(location_id: facility.id, 
    case_type_id: case_type.id, description: report_name,
      case_reported_datetime: encounter_datetime) if reported_case.blank?

  return reported_case
end

def create_indicator(reported_case, indicator_name, val)
  indicator_type = IndicatorType.find_by(name: indicator_name)

  indicator = Indicator.find_by(indicator_type_id: indicator_type.id, 
    case_id: reported_case.id)
  
  indicator.update_columns(value: val, updated_at: Time.now()) unless indicator.blank?

  indicator = Indicator.create(indicator_type_id: indicator_type.id, 
    case_id: reported_case.id, value: val) if indicator.blank?
  

  return indicator
end



start
