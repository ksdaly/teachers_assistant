require 'csv'
class GradeReader
  # attr_accessor :from_file, :to_destination
  # def initialize(from_file, to_destination = {})
  attr_accessor :from_file
  def initialize(from_file)
    @from_file = from_file
    # @to_destination = to_destination
  end

  def read
    CSV.foreach(@from_file, :headers => true) do |row|
      # @to_destination[row[0] + row[1]] = [row[2].to_i, row[3].to_i, row[4].to_i, row[5].to_i, row[6].to_i]
      build_student(row)
    end
  end

  def build_student(row)
    Student.new(row[0], row[1], [row[2].to_i, row[3].to_i, row[4].to_i, row[5].to_i, row[6].to_i] )
  end

end

class Student
  attr_accessor :grade

  @@classroom = []
  def initialize(first_name, last_name, grade)
    @first_name = first_name
    @last_name = last_name
    @grade = grade
    Student.classroom << self
  end

  def self.classroom
    @@classroom
  end
end

class GradeSummary
  attr_reader :class_average

  def initialize(all_grades)
    @all_grades = all_grades
  end

  def analyze_averages
    @student_averages

end






test = GradeReader.new("students.csv")
test.read
puts Student.classroom.inspect
puts GradeSummary.all.inspect
# puts test.to_destination


