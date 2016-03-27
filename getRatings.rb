#Written by: Austin Koeppel
#Inspiration and help from selenium-recipes-in-ruby
#	and https://gist.github.com/skyzyx/ce1fd39d6d0dd8015cb6
#require 'os' #detect system os
require 'nokogiri' #parse html
require 'numeric' #absolute value
require 'selenium-webdriver' #selenium driver to get html

#This application uses a silenium driver to log into,
#and save movie data from netflix

def gleanRatings(html, fileName)
	movies = Hash.new

	doc = File.open(html) { |f| Nokogiri::HTML(f) }
	doc.xpath('//ul[@class = "retable"]/li[@class = "retableRow"]').each do |row|
		title = row.xpath('.//div[@class = "col title"]').text
		rating = row.xpath('.//div[@class = "col rating nowrap"]/div[@class = "starbar yellow oneRow"]/@data-your-rating').text
		movies[title] = rating.to_i.abs
	end
	
	f = File.new("#{fileName}.txt", "w+")
	movies.each do |key, value|
		f.puts "#{key} : #{value}"
	end
	f.close
end

def getHTML(username, password)
	driver = Selenium::WebDriver.for :firefox
	driver.navigate.to "http://www.Netflix.com/MoviesYouveSeen"

	element = driver.find_element(:id, 'email')
	element.send_keys username
	element = driver.find_element(:id, 'password')
	element.send_keys password
	element.submit
	element = driver.find_element(:class, 'body-new-header')

	for a in 1..50
		element.send_keys :page_down
	end
	
	f = File.new("ratings.html", "w+")
	f.puts driver.page_source
	f.close

end

getHTML(ARGV[0], ARGV[1])
gleanRatings("ratings.html", ARGV[0])
