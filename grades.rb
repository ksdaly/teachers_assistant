
require 'pry'

#reads in a csv file
class GradeReader
  require 'csv'
  attr_reader :all_students
  def initialize(filename)
    @all_students = {}
    CSV.foreach(filename, :headers => true) do |row|
      @all_students[row[0] + row[1]] = [row[2].to_i, row[3].to_i, row[4].to_i, row[5].to_i, row[6].to_i]
    end
  end
end

collection = GradeReader.new("students.csv")
collection.all_students.each do |student, grades|
  puts "#{student}: #{grades}"
end


#creates student objects and calculates their average
class AssignmentGrade
  attr_reader :name, :grades

  @@list = []
  def initialize(name, grades)
    @name = name
    @grades = grades
    @@list << self
  end

  def self.list
    @@list
  end

  def average
    grades.reduce(:+)/grades.count
  end
end


collection.all_students.each do |name, grades|
  AssignmentGrade.new(name, grades)
end

AssignmentGrade.list.each do |student|
  puts "#{student.name}: #{student.average}"
end


class FinalGrade
  def initialize(name, average_grade)

end
















