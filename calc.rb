
#
# Written by rubenwardy
# License: WTFPL
#
# $ ruby calc.rb
#
# Turns a string such as "( 0 - (6) + ( 6 ^ 2 - 4 * 1 * 5 ) ^ (1 / 2) ) / ( 2 * 1)"
# into a binary syntax tree, and then into Reverse Polish Notation, and then executes it.
#
# String is typed in the terminal during program execution
#



#
# Tree Node
#
class STNode
  def initialize(value, left = nil, right = nil)
    @left  = left
    @right = right
    @value = value
  end

  def crawl(obj)
    res = ''
    res += "#{@left.crawl(obj)} " if @left
    res += "#{@right.crawl(obj)} " if @right
    res += @value
    res.strip!

    obj&.submit(@value)

    res
  end
end

#
# Run a tree
#
class Executor
  def initialize
    @stack = []
    @failed = false
  end

  def pop
    @stack.pop
  end

  def push(val)
    @stack.push(val)
  end

  def submit(value)
    value.strip!
    # print "'" + value + "' "
    # debug()
    case value
    when '+'
      one = pop
      two = pop

      if one.nil? || two.nil?
        puts 'Failed to execute +'
        @failed = true
        return nil
      end

      push(two + one)
    when '*' then
      one = pop
      two = pop

      if one.nil? || two.nil?
        puts 'Failed to execute *'
        @failed = true
        return nil
      end

      push(two * one)
    when '/' then
      one = pop
      two = pop

      if one.nil? || two.nil?
        puts 'Failed to execute /'
        @failed = true
        return nil
      end

      push(two / one)
    when '-' then
      one = pop
      two = pop

      if one.nil? || two.nil?
        puts 'Failed to execute -'
        @failed = true
        return nil
      end

      push(two - one)
    when '^' then
      one = pop
      two = pop

      if one.nil? || two.nil?
        puts 'Failed to execute ^'
        @failed = true
        return nil
      end

      push(two ** one)
    when /\A[-+]?\d+\z/
      push(value.to_f)
    else
      puts "Unrecognised symbol #{value}"
      @failed = true
    end
  end

  def debug
    print 'stack:'
    @stack.each do |i|
      print " #{i.to_s}"
    end
    puts
  end

  def result
    return nil if @failed

    @stack.pop
  end
end

#
# Turn a string into a tree
#
def process_string(input)
  input.strip!
  if (input[0] == '(') && (input[-1] == ')')
    is_right = true
    level = 0
    input[0..-2].split('').each do |c|
      level += 1 if c == '('
      level -= 1 if c == ')'
      if level.zero?
        is_right = false
        break
      end
    end
    input = input[1..-2] if is_right
  end
  level = 0
  output = ''
  # print "\tInput: " + input
  input.split('').each do |c|
    level += 1 if c == '('
    output += if level.zero?
                c
              else
                '_'
              end
    level -= 1 if c == ')'
  end
  if level != 0
    puts 'Syntax Error'
    return nil
  end
  # puts  (" " * (60 - input.length)) + "=>   " + output

  idx = output.index('+')
  if idx.nil?
    idx = output.index('-')
    if idx.nil?
      idx = output.index('*')
      if idx.nil?
        idx = output.index('/')
        if idx.nil?
          idx = output.index('^')
          node = if idx.nil?
                   STNode.new(input, nil, nil)
                 else
                   STNode.new('^', process_string(input[0..(idx -1)]), process_string(input[(idx+1)..-1]))
                 end
        else
          node = STNode.new('/', process_string(input[0..(idx -1)]), process_string(input[(idx+1)..-1]))
        end
      else
        node = STNode.new('*', process_string(input[0..(idx -1)]), process_string(input[(idx+1)..-1]))
      end
    else
      node = STNode.new('-', process_string(input[0..(idx -1)]), process_string(input[(idx+1)..-1]))
    end
  else
    node = STNode.new('+', process_string(input[0..(idx -1)]), process_string(input[(idx+1)..-1]))
  end
end

#
# API Functions
#
def unit(input, output)
  tree = process_string(input)

  unless tree
    puts "#{input}: FAILED"
    return
  end

  res = tree.crawl(nil)

  if res == output
    puts "#{input}#{' ' * (60 - input.length)}: PASSED"
  elsif !res
    puts "#{input}#{' ' * (60 - input.length)}: FAILED"
  else
    puts "#{input}#{' ' * (60 - input.length)}: FAILED, #{res}"
  end
end

def run(input)
  tree = process_string(input)

  ex = Executor.new

  tree&.crawl(ex)

  ex.result
end




#
# MAIN PROGRAM
#

puts '======================================================================'
puts '============================= UNIT TESTS ============================='
puts '======================================================================'
unit('1 + 1', '1 1 +')
unit('2 + (1 + 1)', '2 1 1 + +')
unit('2 + (3 - 1)', '2 3 1 - +')
unit('10000 / 10000', '10000 10000 /')
unit('1 + (2 * 3) / 3', '1 2 3 * 3 / +')
unit('2 ^ 2', '2 2 ^')
unit('( 0 - 6 + ( 6 ^ 2 - 4 * 1 * 5 ) ^ (1 / 2) ) / ( 2 * 1)', '0 6 - 6 2 ^ 4 1 5 * * - 1 2 / ^ + 2 1 * /')
puts '======================================================================'
puts '======================================================================'

loop do
  puts
  print 'Enter Expression: '
  inp = gets.chomp
  break if (!inp) || (inp == '')

  res = run(inp)
  puts "= #{res.to_s}" if res
end
