require 'mechanize'
require 'csv'

salary_data = CSV.read('salary_data.csv')

teachers = []

salary_data.each do |sd|
  teacher = {}
  puts "-"*25
  mechanize = Mechanize.new

  first_name = sd[1]
  last_name = sd[0]

  teacher[:first_name] = first_name
  teacher[:last_name] = last_name

  page = mechanize.get('https://www.odu.edu/directory?F_NAME='+first_name+'&L_NAME='+last_name+'&SEARCH_IND=E')

  # puts page.inspect

  link = ""
  page.search("table.bordertable tr:nth-child(3) td:first a").each do |a|
    link = a['href'] 
    # puts a['href']
    puts "Name - " + a.text.strip
  end

  page = mechanize.get('https://www.odu.edu'+link)

  # puts page.inspect

  img_url = ""
  page.search("section.alpha ul.left_column li:nth-child(1) img").each do |img|
    img_url = img['src']
    puts "Image Url - " + img_url
  end

  department = ""
  if img_url == ""
    page.search("section.alpha ul.left_column li:nth-child(3)").each do |a|
      department = a.text.strip
      puts "Department - " + department
    end
  else
    page.search("section.alpha ul.left_column li:nth-child(4)").each do |a|
      department = a.text.strip
      puts "Department - " + department
    end
  end

  teacher[:department] = department

  education = []
  page.search(".tab-content ul.ul_in_tab li.fas_education dl").each do |a|
    edu = {}
    university, year, major, degree = ""
    a.search('dt').each do |a|
      university, year = a.text.strip.split(',')
    end
    a.search('dd:first').each do |a|
      a.search('strong').remove
      major = a.text
    end
    a.search('dd:last').each do |a|
      a.search('strong').remove
      degree = a.text
    end
    edu = {
      'university' => (university || "").strip,
      'year' => (year || "").strip,
      'major' => (major || "").strip,
      'degree' => (degree || "").strip,
    }
    education << edu
  end

  puts "education"
  puts education.first.inspect

  if education.any?
    teacher[:university] = education.first['university']
    teacher[:year] = education.first['year']
    teacher[:major] = education.first['major']
    teacher[:degree] = education.first['degree']
  end

  teachers << teacher
end

puts teachers.inspect

CSV.open('processed_salary_data.csv', 'w') do |csv_object|
  csv_object << teachers.first.keys
  teachers.each do |row_array|
    csv_object << row_array.values
  end
end

