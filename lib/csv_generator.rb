#!/usr/bin/env ruby

class CSVGenerator

  # Let's declare these variables as read only functions. This way,
  # when you declare `@output_file = opts[:out]` inside of initialize,
  # users of that instance can still call a method to access that variable.
  #
  #    gen = CSVGenerator.new(opts)
  #    puts "My Output file has #{gen.number_of_columns} columns in #{gen.output_file}"
  #
  # You'll also note that inside of your instance methods, you can
  # replace `@output_file` with `output_file` simply because of this
  # line.  Pretty cool, huh!
  attr_reader :output_file, :number_of_columns, :number_of_rows

  # So why the (!) bang? It will indicate to users that this is an
  # actionable method, used to parse CLI arguments, similar to `OptionParser`
  #
  # By using this method, we can refactor it later on if we decided to
  # use a proper parser.  For now, let's try ARGV, then prompt the user.
  #
  # This may look a little weird, but essentially we're deferring arg
  # parsing validation to parse_argv, or if that returns nil, we call
  # prompt_user.  It's essentially what you had earlier, but is a
  # little more 'Ruby'.
  #
  # (ARGV.size != 3) ? prompt_user : parge_argv )
  def self.parse!
    new( parse_argv || prompt_user )
  end

  # Return nil if ARGV wasn't passed
  def self.parse_argv
    return if ARGV.size != 3
    {out: ARGV[0], cols: ARGV[1], rows: ARGV[2]}
  end

  # We'll move up the instance method prompt_user and make some slight
  # changes.  For now I'm removed the buffer method all together and
  # just settled for newlines.
  def self.prompt_user
    args = {}
    puts "Creation parameters can be passed to the script as arguments like so:"
    puts "#{$0} <output_file> <number_of_columns> <number_of_rows>\n\n"
    puts "Proceeding with prompted questions..."
    puts "Name of output file?"
    args[:out] = gets.chomp
    puts "How many columns?"
    args[:cols] = gets.chomp.to_i
    puts "How many rows?"
    args[:rows] = gets.chomp.to_i
    puts # newline
    return args
  end

  # Let's declare what the user can and cannot call by making some
  # methods private.  Specifically parse_argv and prompt_user.
  private_class_method :prompt_user, :parse_argv

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

    # Let's be lazy about this and create a method.
    # @output_directory  = "#{File.basename($0, ".*")}_output"

    run_the_works
  end

  # We want the full path, it'll just be easier to deal with later and
  # prevent any "WHERE'S MY #*@!ing file?!" bugs
  def output_directory
    @output_directory ||= File.absolute_path(set_output_dir)
  end

  # Let's mark everything after here as `private`, so users know that
  # they only really need to call `CSVGenerator.new(opts)`
  private

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

  # Going to remove the `self` reference `#initialize` for more info.
  def run_the_works
    creating_text
    create_output_directory
    write_columns
    write_newline
    write_rows
    exit_text
  end

  # If the user inputs a absolute path to their file
  # (/home/user/csv.out) then let's use that.
  def set_output_dir
    # If they've used a relative path ("csv.out"), let's return the
    # default you used originally in initialize
    if (dir = File.dirname(output_file)) == "."
      return "#{File.basename($0, ".*")}_output"
    end
    return dir
  end

  # So now that we aren't sourcing ARGV for parameters and we're redefined
  # how we call `CSVGenerator.new`, I'm going to deprecate this method.
  #
  # Since `#argument_check` was called inside of initialize, users
  # would rarely have called it, if ever, but because it was defined as a public method
  # I'm going to simple deprecate it until the next release.
  #
  # Now that `#argument_check` is private, I'm going to flat out remove it.
  # def argument_check; end


  ##
  # :section: Output formatting
  #
  # Everything else is to help format text

  def creating_text
    puts "\n\nCreating #{output_file} to contain #{number_of_columns} columns and #{number_of_rows} rows...\n\n"
  end

  def exit_text
    puts "File has been generated here: #{output_directory}/#{output_file}"
  end

  def write_columns
    puts "Writing columns..."
    number_of_columns.times do |col|
      write_to_file(",#{col}_Column")
    end
  end

  def write_rows
    puts "Writing rows..."
    number_of_rows.times do
      number_of_columns.times do
        write_to_file(",data")
      end
      write_newline
    end
  end

  def write_newline
    write_to_file("\n")
  end

  def write_to_file(string)
    File.open("#{output_directory}/#{output_file}", 'a+') { |f| f.write(string) }
  end

  def create_output_directory
    Dir.mkdir(output_directory) unless File.exists?(output_directory)
  end
end

##
# Gunna start off by how much I *hate* when folks do this, but I
# wanted to leave a comment so you can see how it would work if you
# really wanted to keep the bin scripts and the library scripts in the
# same file.
#
#    if __FILE__==$0
#      CSVGenerator.parse!
#    end
