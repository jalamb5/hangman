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
    attr_accessor :game_word, :incorrect_guess_num, :guess, :correct_locations, :word_progress

    def initialize(game_word)
        @game_word = game_word

    end

    def update_hangman(incorrect_guess_num=0, guess='', correct_locations=[], word_progress=[])
        @incorrect_guess_num = incorrect_guess_num
        @guess = guess
        @correct_locations = correct_locations
        @word_progress = word_progress

        puts Pics::HANGMANPICS[incorrect_guess_num]
        update_word()
    end

    def update_word
        if word_progress == []
            word_progress << "_ " * game_word.length
        end
        word_fill = word_progress
        unless correct_locations == []
            correct_locations.each do |index|
                word_fill[index] = guess
            end
        end
        puts word_fill.join(' ')
        return word_fill
        
    end
end

class GUESS
    attr_accessor :guess, :game_word
    def initialize(guess=nil, game_word=nil)
        @guess = guess
        @game_word = game_word
    end

    def input_validation(guess, char_bank)
        @char_bank = char_bank
        @guess = guess
        # guess = gets.chomp
        unless guess.length == 1
            puts "You must guess a single letter."
            guess = ''
        end
        if char_bank.include?(guess)
            puts "You've already chosen that letter, guess another."
            guess = ''
        end
        return guess
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
    puts game_word
    incorrect_guess_num = 0
    char_bank = []
    word_progress = Array.new(game_word.length, "_ ")
    gameboard = DRAW.new(game_word)
    gameboard.update_hangman()
    while incorrect_guess_num < Pics::HANGMANPICS.length - 1 # Continue to ask for guess until full hangman has been drawn
        puts "Guess a letter"
        guess = gets.chomp.downcase
        GUESS.new().input_validation(guess, char_bank)
        if guess == ''
            GUESS.new().input_validation(char_bank)
        end
        char_bank << guess
        puts "Letters guessed: #{char_bank.uniq}"
        correct_locations = GUESS.new(guess, game_word).guess_analyzer()
        if correct_locations == []
            incorrect_guess_num += 1
        end
        word_array = gameboard.update_hangman(incorrect_guess_num, guess, correct_locations, word_progress)
        word_array.each_with_index do |char, index|
            if word_progress[index] == '_ '
                word_progress[index] = char
            end
        end
        if game_word == word_progress.join()
            puts "\nYou win!\n\n"
            break
        end
        
    end
    unless game_word == word_progress.join()
        puts "\nYou ran out of guesses! The correct word was: #{game_word}\n\n"
    end
end

GAME.new()


