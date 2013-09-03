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
    Student.new(row[0].strip, row[1].strip, [row[2].to_i, row[3].to_i, row[4].to_i, row[5].to_i, row[6].to_i] )
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
end

class GradeSummary
  attr_reader :grades

  def initialize
    @grades = []
    Student.classroom.each do |student|
      @grades << student.grades
    end
    @grades.flatten!
  end

  def grade_count
    grades.size
  end

  def grade_sum
    grades.inject(:+)
  end

  def class_average
    grade_sum/grade_count
  end

  def class_min
    grades.min
  end

  def class_max
    grades.max
  end

  def class_variance
    sum = grades.inject(0){|sum, n| sum + (n - class_average) ** 2}
    (1 / grade_count.to_f * sum)
  end

  def class_standard_deviation
    Math.sqrt(class_variance).round(1)
  end
end


class Classroom
  attr_reader :students, :grades

  def initialize(filename)
    GradeReader.new(filename).read
    @students = Student.sort
    @grades = GradeSummary.new
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
    puts "Class average: #{grades.class_average}"
  end

  def display_class_min
    puts "Class min: #{grades.class_min}"
  end

  def display_class_max
    puts "Class max: #{grades.class_max}"
  end

  def display_class_sdiv
    puts "Class standard deviation: #{grades.class_standard_deviation}"
  end

  def write_to_csv
    CSV.open("student_report.csv", "wb") do |csv|
      csv << ["last name", "first name", "average grade", "final grade"]
      students.each do |student|
        csv << [student.last_name, student.first_name, student.average, student.letter_grade]
      end
    end
  end
end


puts "Please specify a .CSV file to load:"
filepath = gets.chomp
while !(File.exists?(filepath) && /.csv/.match(filepath))
  puts "The file you specified is invalid. Please enter it again:"
  filepath = gets.chomp
end

test_array = []
File.open(filepath, 'r').each_line do |line|
  test_array << line.split(',')
end

if test_array[1..-1].any? { |row| row.size != test_array[0].size }
  raise 'The file you specified contains invalid data'
end



new_classroom = Classroom.new(filepath)
puts "ALL GRADES"
new_classroom.display_all_grades
puts ""
puts "AVERAGE  GRADE"
new_classroom.display_average_grades
puts ""
puts "LETTER GRADES"
new_classroom.display_letter_grades
puts ""
puts "CLASS AVERAGES"
new_classroom.display_class_average
new_classroom.display_class_min
new_classroom.display_class_max
new_classroom.display_class_sdiv
new_classroom.write_to_csv




