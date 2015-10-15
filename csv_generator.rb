#!/usr/bin/env ruby

class CSVGenerator

  def initialize
    @output_file = ARGV[0]
    @number_of_columns = ARGV[1].to_i
    @number_of_rows = ARGV[2].to_i
    @output_directory = "#{File.basename($0, ".*")}_output"
    self.argument_check
  end

  def argument_check
    (ARGV.size != 3) ? prompt_user : run_the_works
  end

  def prompt_user
    buffer(2)
    puts "Creation parameters can be passed to the script as arguments like so:"
    puts "#{$0} <output_file> <number_of_columns> <number_of_rows>"
    buffer(2)
    puts "Proceeding with prompted questions..."
    puts "Name of output file?"
    @output_file = gets.chomp
    puts "How many columns?"
    @number_of_columns = gets.chomp.to_i
    puts "How many rows?"
    @number_of_rows = gets.chomp.to_i
    buffer
    run_the_works
  end

  def buffer(int = 1)
    puts "\n" * int
  end

  def creating_text
    buffer(2)
    puts "Creating #{@output_file} to contain #{@number_of_columns} columns and #{@number_of_rows} rows..."
    buffer(2)
  end

  def exit_text
    buffer(2)
    puts "File has been generated here: #{@output_directory}/#{@output_file}"
    abort
  end

  def create_output_directory
    Dir.mkdir(@output_directory) unless File.exists?(@output_directory)
  end

  def write_columns
    puts "Writing columns..."
    @number_of_columns.times do |col|
      write_to_file(",#{col}_Column")
    end
  end

  def write_rows
    puts "Writing rows..."
    @number_of_rows.times do
      @number_of_columns.times do
        write_to_file(",data")
      end
      write_newline
    end
  end

  def write_newline
    write_to_file("\n")
  end

  def write_to_file(string)
    File.open("#{@output_directory}/#{@output_file}", 'a+') { |f| f.write(string) }
  end

  def run_the_works
    self.creating_text
    self.create_output_directory
    self.write_columns
    self.write_newline
    self.write_rows
    self.exit_text
  end

end

# Driver code....

app = CSVGenerator.new
# app.argument_check