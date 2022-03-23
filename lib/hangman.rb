require './lib/hangmanpics.rb'

class WORD
    attr_accessor :file
    def initialize
        @file = File.open('dictionary.txt')
    end

    def secret_word
        game_word = File.readlines(file).sample
        if (5...12).cover?(game_word.length)
            file.close
            game_word
        else
            secret_word()
        end
    end
end

class DRAW
    attr_accessor :game_word, :incorrect_guess_num, :guess, :correct_locations
    def initialize(game_word)
        @game_word = game_word

    end

    def update_hangman(incorrect_guess_num=0, guess=nil, correct_locations=[])
        @incorrect_guess_num = incorrect_guess_num
        @guess = guess
        @correct_locations = correct_locations
        if correct_locations == []
            p incorrect_guess_num
        end
        puts Pics::HANGMANPICS[incorrect_guess_num]
        update_word()
    end

    def update_word
        word_blanks = "_ " * game_word.length
        word_fill = word_blanks.split(' ')
        unless correct_locations == []
            correct_locations.each do |index|
                word_fill[index] = guess
            end
        end
        
        puts word_fill.join(' ')
    end
end

class GUESS
    attr_accessor :guess, :game_word
    def initialize(guess=nil, game_word=nil)
        @guess = guess
        @game_word = game_word
    end

    def input_validation
        guess = gets.chomp
        unless guess.length == 1
            puts "You must guess a single letter."
            input_validation()
        end
    end

    def guess_analyzer
        correct_locations = []
        game_word.split('').each_with_index do |char, index|
            if guess == char
                correct_locations << index
            end
        end
        return correct_locations
    end
end

class GAME
    puts "Welcome to Hangman"
    game_word = WORD.new.secret_word().chomp
    incorrect_guess_num = 0
    gameboard = DRAW.new(game_word)
    gameboard.update_hangman()
    while incorrect_guess_num < Pics::HANGMANPICS.length - 1 # Continue to ask for guess until full hangman has been drawn
        puts "Guess a letter"
        guess = GUESS.new().input_validation()
        correct_locations = GUESS.new(guess, game_word).guess_analyzer()
        if correct_locations == []
            incorrect_guess_num += 1
        end
        gameboard.update_hangman(incorrect_guess_num, guess, correct_locations)
    end
end

GAME.new()

# TODO: make correct guesses persist
# TODO: validate input