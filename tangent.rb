require 'pry'
require 'csv'

class GradeReader
  attr_accessor :from_file
  def initialize(from_file)
    @from_file = from_file
  end

  def read
    CSV.foreach(@from_file, :headers => true) do |row|
      build_student(row)
    end
  end

  def build_student(row)
    Student.new(row[0], row[1], [row[2].to_i, row[3].to_i, row[4].to_i, row[5].to_i, row[6].to_i] )
  end
end

class Student
  attr_accessor :first_name, :last_name, :grades

  @@classroom = []
  def initialize(first_name, last_name, grades)
    @first_name = first_name
    @last_name = last_name
    @grades = grades
    Student.classroom << self
  end

  def self.classroom
    @@classroom
  end

  def average
    (grades.inject(:+) / grades.size.to_f).round(1)
  end

  def letter_grade
    if average >= 90
      return "A"
    elsif average >= 80
      return "B"
    elsif average >= 70
      return "C"
    elsif average >= 60
      return "D"
    else
      return "F"
    end
  end

  def self.sort
    classroom.sort_by {|student| [student.last_name,student.first_name]}
  end

  def self.all_grades
    grades = []
    classroom.each do |student|
      grades << student.grades
    end
    grades.flatten!
  end

  def self.grade_count
    all_grades.size
  end

  def self.grade_sum
    all_grades.reduce(:+)
  end

  def self.class_average
    grade_sum/grade_count
  end

  def self.class_min
    all_grades.min
  end

  def self.class_max
    all_grades.max
  end

  def self.class_variance
    sum = all_grades.inject(0){|sum, n| sum + (n - class_average) ** 2}
    (1 / grade_count.to_f * sum)
  end

  def self.class_standard_deviation
    Math.sqrt(class_variance).round(1)
  end

end

class Classroom
  attr_reader :students

  def initialize(filename)
    GradeReader.new(filename).read
    @students = Student.sort
  end

  def display_all_grades
    students.each do |student|
      puts "#{student.first_name} #{student.last_name}: #{student.grades.join(", ")}"
    end
  end

  def display_average_grades
    students.each do |student|
      puts "#{student.first_name} #{student.last_name}: #{student.average}"
    end
  end

  def display_letter_grades
    students.each do |student|
      puts "#{student.first_name} #{student.last_name}: #{student.letter_grade}"
    end
  end

  def display_class_average
    puts "Class average: #{Student.class_average}"
  end

  def display_class_min
    puts "Class min: #{Student.class_min}"
  end

  def display_class_max
    puts "Class max: #{Student.class_max}"
  end

  def display_class_sdiv
    puts "Class standard deviation: #{Student.class_standard_deviation}"
  end

end

new_classroom = Classroom.new("students.csv")
puts "ALL GRADES"
new_classroom.display_all_grades
puts "AVERAGE  GRADE"
new_classroom.display_average_grades
puts "LETTER GRADES"
new_classroom.display_letter_grades
puts "CLASS AVERAGES"
new_classroom.display_class_average
new_classroom.display_class_min
new_classroom.display_class_max
new_classroom.display_class_sdiv




