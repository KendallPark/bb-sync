require 'mechanize'
require 'fileutils'
require 'yaml'

class Scraper
  ROOT_URL = "https://bblearn.missouri.edu"
  COURSE_SCHEMA = YAML::load_file(File.join(File.dirname(__FILE__), 'courses.yml'))
  CONFIG = YAML::load_file(File.join(File.dirname(__FILE__), 'config.yml'))
  SAVE_DIR = File.expand_path CONFIG["save_dir"]
  USERNAME = CONFIG["pawprint"]
  PASSWORD = CONFIG["password"]
  @@mechanize = Mechanize.new

  def self.scrape!(username=USERNAME, password=PASSWORD, save_dir=SAVE_DIR)
    @@mechanize.get('https://bblearn.missouri.edu/webapps/portal/execute/defaultTab') do |login_page|
      login(login_page, username, password)

      COURSE_SCHEMA.each do |course_name, course|
        course["sections"].each do |section_name, section|
          section_url = "https://bblearn.missouri.edu/webapps/blackboard/content/listContent.jsp?course_id=#{course['course_id']}&content_id=#{section['content_id']}"
          scrape_section section_url, [course_name, section_name], save_dir
        end
      end
    end
  end

  def self.login(page, username, password)
    form = page.form_with(:action => '/webapps/login/')
    username_field = form.field_with(:name => "user_id")
    username_field.value = username
    password_field = form.field_with(:name => "password")
    password_field.value = password
    form.submit
  end

  def self.scrape_section(page_url, dir_array, save_dir)
    page = @@mechanize.get(page_url)
    page.search("//li[substring(@id, 1, 15) = 'contentListItem']").each do |content|
      title = content.search("h3 span").last.text
      match = title.match(/(.*) - Updated (.*)/)
      title = match[1] if match

      content.search("ul.attachments a").each do |attachment|
        url = attachment.attributes["href"].value
        subtitle = ""
        subtitle_match = attachment.text.match(/(.*) - Click here to view/)
        subtitle = " -- #{subtitle_match[1]}" if subtitle_match

        content_title = "#{title}#{subtitle}"
        next if Dir.glob(File.join(save_dir, *dir_array, "#{content_title}*")).any?
        downloaded_file = @@mechanize.get(File.join(ROOT_URL, url))
        file_ext = downloaded_file.filename[/\.[^.]*$/]
        save_path = File.join(save_dir, *dir_array, "#{content_title}#{file_ext}")
        downloaded_file.save!(save_path)
      end

      folder_link = content.search("h3 a").first
      next unless folder_link
      url = folder_link.attributes["href"].value
      scrape_section(File.join(ROOT_URL, url), dir_array + [title], save_dir) if url.include? "/webapps/blackboard/content/listContent.jsp"
    end
  end
end
