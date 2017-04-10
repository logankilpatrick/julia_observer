namespace :scour do

  @api_requests = 0

  desc "scour for non-metadata packages"
  task packages: :environment do
    base_url = "https://api.github.com/search/repositories"
    base_url += "?sort=updated&order=asc&"
    base_url += "q=.jl+in:name+language:julia+created:"

    julia_releases, _ = check_and_hit_url \
      'https://api.github.com/repos/JuliaLang/julia/releases'

    julia_directory = "#{Rails.root}/tmp/julia"
    FileUtils.mkdir_p(julia_directory) \
      unless File.directory? julia_directory

    File.open("#{julia_directory}/releases.yml", 'w') do |h|
      h.write julia_releases.to_yaml
    end

    cur_start_date = Date.parse '2012-01-01'
    today_date = Date.today

    make_query_bar base_url, cur_start_date, today_date

    scoured_results = []

    while cur_start_date < today_date do

      cur_start_date -= 1.day
      cur_end_date = today_date

      while cur_end_date > cur_start_date
        date_query = cur_start_date.strftime('%Y-%m-%d') + '..'
        date_query += cur_end_date.strftime('%Y-%m-%d')

        cur_page = safe_hit_url ( base_url + date_query )
        break unless cur_page['total_count'] > 1000

        cur_end_date -= \
          0.5 * ( cur_end_date - cur_start_date )
      end

      total_count = cur_page['total_count']
      scoured_results << [ total_count ]

      cur_page = nil
      page_index = 0
      cur_count = 0

      while cur_count < total_count && \
          ( cur_page.nil? or not cur_page['items'].empty? )
        page_index += 1

        cur_url = base_url + date_query + "&page=#{ page_index }"
        cur_page = safe_hit_url cur_url

        is_bad_data = ( not cur_page['items'].present? )
        is_bad_data &&= ( not cur_page['items'].try(:empty?) )

        if is_bad_data
          CronLogMailer.log_email(
            "Scour", cur_page.to_yaml
          ).deliver_now

          throw "Invalid scoured page for: #{cur_url}"
        end

        cur_count += cur_page['items'].length

        cur_page['items'].each do |item|
          package_directory = "#{Rails.root}/#{@scour_directory}/#{item['name'].sub '.jl', ''}"
          next if File.directory? package_directory

          FileUtils.mkdir_p(package_directory)
          File.open("#{package_directory}/data.yml", 'w') do |h|
             h.write item.to_yaml
          end
        end
      end

      Dir.foreach(@scour_directory) do |directory|
        next if directory.starts_with? '.'
        next unless File.directory? \
          "#{@metadata_directory}/#{directory}"

        FileUtils.rm_rf "#{@scour_directory}/#{directory}"
      end

      scoured_results[-1] += [page_index, cur_start_date, cur_end_date]

      cur_start_date = cur_end_date
    end

    @bar.finished

    scoured_results.each do |scoured_result|
      scoured_print_out = "#{ scoured_result[2] } - #{ scoured_result[3] }"
      scoured_print_out += " : "
      scoured_print_out += "#{ scoured_result[0] } / #{ scoured_result[1] }"
      puts scoured_print_out
    end

  end

  desc "devour scoured data for database"
  task devour: :environment do
    julia_releases_file = "tmp/julia/releases.yml"
    julia_releases = YAML.load_file(julia_releases_file)

    bar = make_progress_bar julia_releases.count

    julia_releases.each do |julia_release|
      bar.inc
      Release.create! \
        published_at: julia_release['published_at'],
        tag_name: julia_release['tag_name']
    end

    bar.finished

    bar = make_progress_bar Dir["#{@scour_directory}/*"].count

    Dir.foreach(@scour_directory) do |directory|
      bar.inc

      next if directory.starts_with? '.'

      package_exists = \
        Package.custom_exists? directory, batch_scope: "current_batch_scope"

      next if package_exists

      package = Package.create! name: directory

      make_scoured_repository package, directory
    end

    bar.finished
  end

  def make_scoured_repository package, directory
    package_data_file = "#{@scour_directory}/#{directory}/data.yml"
    url = YAML.load_file(package_data_file)['clone_url']

    repository = Repository.create! url: url, package: package
  end

  def make_query_bar base_url, cur_start_date, cur_end_date
    date_query = cur_start_date.strftime('%Y-%m-%d') + '..'
    date_query += cur_end_date.strftime('%Y-%m-%d')

    cur_page = safe_hit_url ( base_url + date_query )
    total_queries = cur_page['total_count'] / 30
    total_queries *= 2

    @bar = make_progress_bar total_queries
  end

  def safe_hit_url cur_url
    @bar.inc if @bar.present?
    cur_page = blind_hit_url cur_url

    @api_requests += 1
    sleep(1.minute) \
      if (@api_requests % 10).zero?

    cur_page
  end

end
