module Codebreaker
  class Game
    ATTEMPTS = 10
    SCORE_FILE_NAME = '.score'
    HINTS = 2
    attr_accessor :name
    attr_reader :attempts, :hints, :status

    def initialize
      @name = nil
      @status = nil
      start
    end

    def start
      @code = generate
      @attempts = ATTEMPTS
      @hints = HINTS
      @status = :play
    end

    def check(guess)
      @attempts -= 1
      return game_over unless attempts > 0
      raise ArgumentError.new('Guess must have 4 numbers from 1 to 6') if !valid_code?(guess)
      ans = guess.to_s.chars
      code = @code.dup
      ans.map!.with_index do |char, index|
        if char == code[index]
          code = code.chars.map {|code_char| code_char == char ? '+' : code_char}.join
          '+'
        else
          char
        end
      end
      ans.map! do |char|
        if char == '+'
          '+'
        else
          code.include?(char) ? '-' : ''
        end
      end
      ans.join == "++++" ? game_over(true) : ans.sort.join
    end

    def game_over(win = false)
      @status = win ? :win : :lose
    end

    def valid_code?(code)
      code.to_s.size == 4 && code.to_s.chars.all? {|char| (1..6).include? char.to_i}
    end

    def generate
      code = ''
      4.times {code+=(1+rand(6)).to_s}
      code
    end

    def hint
      if hints > 0
        @hints-=1
        @code[rand(4)]
      end
    end

    def save
      unless File.exist? SCORE_FILE_NAME
        File.write(SCORE_FILE_NAME,"name\tattempts\thints\tstatus\r\n")
      end
      unless name.nil?
        data = "#{name}\t#{ATTEMPTS-attempts}\t#{HINTS-hints}\t#{@status}"
        File.open(SCORE_FILE_NAME,'a') {|f| f.puts(data)}
      end
    end

    def score
      File.read(SCORE_FILE_NAME) if File.exist? SCORE_FILE_NAME
    end
  end
end
