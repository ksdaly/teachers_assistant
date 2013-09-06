#!usr/bin/env ruby

require 'pry'

require 'CSV'

# ---CLASSES---

#responsible for reading in grade data from a CSV
class GradeReader

  def initialize(file)
    @file = file
  end

  def create_student_record
    @student_records = []
    CSV.foreach(@file) do |row|
      student = {}
      student[:first_name] = row[0]
      student[:last_name] = row[1]
      student[:grades] = row[2..-1].map { |grade| grade.to_f }

      @student_records << Student.new(student[:first_name], student[:last_name], student[:grades])
    end
    @student_records
  end

  def student_records
    @student_records
  end

  def create_grade_summary
    all_grades = []
    @student_records.each_with_index do |student, index|
      all_grades << student.grades
    end
    GradeSummary.new(all_grades.flatten!)
  end

  def print_results
    create_student_record.each_with_index do |student, index|
      puts "Student Name: #{student.full_name}"
      puts "Final Grade: #{student.letter_grade}"
      puts ""
    end
  end

end

#an object that represents a participant in a class
class Student
  attr_reader :grades

  def initialize(first_name, last_name, grades)
    @first_name = first_name
    @last_name = last_name
    @grades = grades
  end

  def average
    @grades.reduce(0) { |sum, grade| sum + grade } / @grades.length
  end

  def first_name
    @first_name
  end

  def last_name
    @last_name
  end

  def full_name
    "#{@first_name}#{@last_name}"
  end

  GRADE = {
    'A' => 90,
    'B' => 80,
    'C' => 70,
    'D' => 60,
    'F' => 0
  }

  def letter_grade
    GRADE.each do |letter, value|
      if average >= value
        return letter
      end
    end
  end
end


class GradeSummary

  def initialize(grades)
    @grades = grades
  end

  def class_average
    @grades.reduce(0) { |sum, grade| sum + grade } / @grades.length
  end

  def class_min
    @grades.min
  end

  def class_max
    @grades.max
  end

  def class_variance
    sum = @grades.reduce(0) { |sum, n| sum + (n - class_average) ** 2 }
    (1 / @grades.length.to_f * sum)
  end

  def class_std_dev
    Math.sqrt(class_variance).round(1)
  end

end


#writes a text file with grade detail
class WriteGrades

  def initialize(students)
    @students = students
  end

  def sort
    @students.sort_by { |student| [student.last_name,student.first_name] }
  end

  def create_file
    CSV.open( 'class_report.csv', 'w') do |csv|
      csv << ['First Name','Last Name','Average Grade','Final Letter Grade']
      sort.each do |student|
        csv << [student.first_name,student.last_name,student.average,student.letter_grade]
      end
    end
  end
end


# # ---START OF PROGRAM---

reader = GradeReader.new('student_records.csv')
reader.print_results
summary = reader.create_grade_summary
puts "Class Average: #{summary.class_average}"
puts "Class Min: #{summary.class_min}"
puts "Class Max: #{summary.class_max}"
puts "Class Standard Deviation: #{summary.class_std_dev}"

new_file = WriteGrades.new(reader.student_records)
new_file.create_file
