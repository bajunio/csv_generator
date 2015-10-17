#!/usr/bin/env ruby

class CSVGenerator

  ##
  # Pass in a hash as args
  # Alternatively you could set specific args, like
  #
  #   `initialize(output_file, column_count, row_count)`
  #
  # but that would also limit flexibility in the future to make
  # changes to the API.
  def initialize(opts={})
    # Validate arguments first, there's no need to proceed if things
    # aren't gunna work anyways.
    #
    # I've decided to rename `#argument_check` to `#validate_args`.
    # Why? Well, it sounds more idomatic. Rails calls it's parameter check
    # classes `Validators` for example.
    #
    # Also want to briely 'explain thy `self`'. There's usually no
    # need the call `self.method` inside of instance methods.  All of
    # your method calls are already scoped to that particular instance.
    validate_args(opts)

    @output_file       = opts[:out]
    @number_of_columns = opts[:cols].to_i
    @number_of_rows    = opts[:rows].to_i
    @output_directory  = "#{File.basename($0, ".*")}_output"
  end

  # So now that we aren't sourcing ARGV for parameters and we're redefined
  # how we call `CSVGenerator.new`, I'm going to deprecate this method.
  #
  # Since `#argument_check` was called inside of initialize, users
  # would rarely have called it, if ever, but because it was defined as a public method
  # I'm going to simple deprecate it until the next release.
  #
  def argument_check
    warn "[DEPRECATION] `argument_check` is deprecated and will be removed in future release"
    #   (ARGV.size != 3) ? prompt_user : run_the_works
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

  # Let's cycle through the keys we require and select those key
  # values equal nil in the opts hash.  Essentially:
  #
  #     required_args = [:out, :rows, :cols]
  #     missing = []
  #     required_args.each do |sym|
  #       if opts[sym].nil?
  #         missing << :out
  #       end
  #     end
  #
  # Then, if `missing.any?` we know that some arguments were not
  # passed and we should raise an exception.  Rather than do all that
  # here, we'll call instance method `#usage` and pass it the missing args.
  def validate_args(opts={})
    return if (missing = [:out, :rows, :cols].select{|a| opts[a].nil? }).empty?
    usage(missing)
  end


  # Params are an array of missing parameters passed as a splat (*).
  # All splat does is says "you can pass me as any individual
  # arguments as your want and I'll pretend like you passed me an
  # array instead".  Here's an illustration:
  #
  #    usage_args(:out, :cols, :rows)
  #
  #    def usage_args(arg1, arg2, arg3)
  #        arg4 = :format
  #        usagesplat(arg1, arg2, arg3, arg4)
  #    end
  #
  #    def usage_splat(*args)
  #        puts args.join(', ')
  #        # :out, :cols, :rows, :format
  #    end
  #
  # By calling exit 1, you're letting users know that there was an error.
  def usage(*args)
    if args.any?
      puts 'Missing argument' + (args.size > 1 ? 's' : '') + ': ' + args.join(',')
    end
    puts "Usage: #{$0} <output_file> <number_of_columns> <number_of_rows>"
    exit 1
  end

end

# Driver code....

app = CSVGenerator.new
# app.argument_check
