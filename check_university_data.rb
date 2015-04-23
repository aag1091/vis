require 'csv'

universities = CSV.read('postscndryunivsrvy2013dirinfo12.csv', encoding: "iso-8859-1:UTF-8", :headers => true)

print universities.inspect

print universities.select{ |u| u['INSTNM'] == "Old Dominion University" }
