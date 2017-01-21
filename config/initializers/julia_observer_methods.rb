def clean_field_list field_list
  cleaned_list = field_list.deep_dup
  cleaned_list.reject! { |field| field == 'id' }
  cleaned_list.reject! { |field| field.ends_with? '_id' }
  cleaned_list.reject! { |field| field.ends_with? '_at' }
  cleaned_list.reject! { |field| field.ends_with? '_type' }
  cleaned_list
end

def get_initial_batch_marker marker_type, default_value
  batch_directory = 'tmp/batch'
  file_name = "#{marker_type}.yml"
  file_path = "#{batch_directory}/#{file_name}"

  return YAML.load_file(file_path) \
    if File.exist? file_path

  FileUtils.mkdir_p(batch_directory) \
    unless File.directory? batch_directory

  File.open(file_path, 'w') do |h|
    h.puts default_value.to_yaml
  end

  default_value
end
