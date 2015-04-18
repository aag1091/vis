require 'mechanize'
require 'csv'

salary_data = CSV.read('salary_data.csv')

salary_data.each do |sd|

  mechanize = Mechanize.new

  first_name = sd[1]
  last_name = sd[0]

  page = mechanize.get('https://www.odu.edu/directory?F_NAME='+first_name+'&L_NAME='+last_name+'&SEARCH_IND=E')

  # puts page.inspect

  link = ""
  page.search("table.bordertable tr:nth-child(3) td:first a").each do |a|
    link = a['href'] 
    puts a['href']
    puts a.text.strip
  end

  page = mechanize.get('https://www.odu.edu'+link)

  # puts page.inspect

  department = ""
  page.search("section.alpha ul.left_column li:nth-child(3)").each do |a|
    department = a.text.strip
    puts department
  end

  education = []
  page.search(".tab-content ul.ul_in_tab li.fas_education dl").each do |a|
    edu = {}
    university, year, major, degree = ""
    a.search('dt').each do |a|
      university, year = a.text.strip.split(',')
    end
    a.search('dd:first').each do |a|
      a.search('strong').remove
      major = a.text.strip
    end
    a.search('dd:last').each do |a|
      a.search('strong').remove
      degree = a.text.strip
    end
    edu = {
      'university' => university.strip,
      'year' => year.strip,
      'major' => major,
      'degree' => degree,
    }
    education << edu
  end

  puts education.inspect

end