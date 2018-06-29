module RSpecConfigurationHelper
  def self.load_config(failsafe = true)
    rspec_file = '.rspec'
    file_path = nil
    File.open(rspec_file).each do |line|
      file_path = line.split('--options ').last.strip if line.match '--options\s?.+ya?ml'
    end

    if file_path.nil?
      puts 'No rspec2db config specified in .rspec'
      return nil
    elsif !File.exists?(file_path)
      puts 'could not find the config file at the following location: ' + file_path
      abort 'exiting... please check your config file' if failsafe
      nil
    else
      config = YAML::load(File.open(file_path))
      config['file_path'] = file_path
      config
    end
    override_default_config config
  end

  def self.generate_local_config(rspec2db_config_file)
    if File.exist?(rspec2db_config_file)
      puts 'Default config file exists, override with default? (Y/N)'
      override = STDIN.gets.chomp
      return if override == 'N' || override == 'n'
    end

    puts 'Creating default rspec2db config file (' + rspec2db_config_file + ')'
    rspec2db_bundler_path = Bundler.rubygems.find_name('rspec2db').first.full_gem_path
    rspec2db_config_src = rspec2db_bundler_path + '/config/rspec2db.yml'
    FileUtils.cp rspec2db_config_src, rspec2db_config_file
  end

  def self.load_local_config
    rspec2db_default_config_file = './rspec2db.yaml'
    rspec2db_project_config = RSpecConfigurationHelper.load_config
    rspec_options_file = '.rspec'
    unless rspec2db_project_config.nil?
      puts 'Using project config file'
    else
      puts 'No project file specified in .rspec. Looking for default rspec2db.yaml file'
      if File.exists? rspec2db_default_config_file
        rspec2db_project_config = YAML::load(File.open(rspec2db_default_config_file))
      else
        puts 'File not found, generating a default rpsec2db.yaml'
        RSpecConfigurationHelper.generate_local_config(rspec2db_default_config_file)
        rspec2db_project_config = YAML::load(File.open(rspec2db_default_config_file))
      end
      RSpecConfigurationHelper.insert_rspec2db_formatter rspec_options_file, rspec2db_default_config_file
    end

    Hash[rspec2db_project_config['dbconnection'].map { |k, v| [k.to_sym, v] }]
  end

  def self.insert_rspec2db_formatter(rspec_file, rspec2db_config_file)
    rspec2db_formatter = "--format Rspec2db\n--options #{rspec2db_config_file}"
    puts 'Adding rspec2db options and formatter to ' + rspec_file
    File.open(rspec_file, 'a') do |f|
      f.puts rspec2db_formatter
      f.flush
    end
  end

  def self.override_default_config(config)
    config["options"].each do |key, value|
      config["options"][key] = ENV[key.upcase] unless ENV[key.upcase].nil?
    end

    config["dbconnection"].each do |key, value|
      config["dbconnection"][key] = ENV[key.upcase] unless ENV[key.upcase].nil?
    end
    config
  end

  def self.check_rspec_options
    rspec_options_file = '.rspec'
    rspec2db_config_file = './rspec2db.yaml'

    return nil unless File.exist?(rspec_options_file)
    config = RSpecConfigurationHelper.load_config(false)
    if config.nil?
      puts 'Creating rspec2db config file (' + rspec2db_config_file + ')'
      RSpecConfigurationHelper.generate_local_config rspec2db_config_file
      RSpecConfigurationHelper.insert_rspec2db_formatter rspec_options_file, rspec2db_config_file
      return RSpecConfigurationHelper.load_config
    end
    puts 'rspec2db config file already exists (' + config['file_path'] + ')'
    config['dbconnection']
  end


  def extract_rspec_core_version
    Gem.loaded_specs['rspec-core'].version.to_s.split('.').map { |v| v.to_i }
  end

  def load_snippet_extractor
    major_version, minor_version = @rspec_core_version

    if major_version == 3 && minor_version < 4
      require 'rspec/core/formatters/snippet_extractor'
      RSpec::Core::Formatters::SnippetExtractor.new
    elsif major_version == 3 && minor_version >= 4
      require 'rspec/core/formatters/html_snippet_extractor'
      RSpec::Core::Formatters::HtmlSnippetExtractor.new
    end
  end

  def print_example_failed_content(example)
    print_content = ''
    exception = example.execution_result.exception
    return print_content if exception.backtrace.nil?

    backtrace_content = exception.backtrace.map { |line| RSpec::Core::BacktraceFormatter.new.backtrace_line(line) }
    backtrace_content.compact!
    snippet_extractor ||= load_snippet_extractor

    snippet_content = snippet_extractor.snippet(backtrace_content)
    snippet_content = snippet_content.sub( "class=\"offending\"", "class=\"offending\" style=\"background-color: red;\"" )
    print_content = "    <pre class=\"ruby\" style=\"background-color: #E6E6E6; border: 1px solid;\"><code>#{snippet_content}</code></pre>"
    print_content
  end
end
