require './lib/hangmanpics.rb'
require 'erb'

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

    def input_validation(guess='no guess', letters_guessed)
        @letters_guessed = letters_guessed
        @guess = guess
 
        unless guess.length == 1
            puts "You must guess a single letter."
            guess = ''
        end
        if letters_guessed.include?(guess)
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

class SAVE
    attr_accessor :erb
    def initialize
        @template = File.read('save_state.erb')
        @erb = ERB.new @template
    end

    def save_game(game_word, incorrect_guess_num, letters_guessed, word_progress)
        Dir.mkdir('saves') unless Dir.exist?('saves')

        filename = "saves/save_data.rb"
        save_data = erb.result(binding)

        File.open(filename, 'w') do |file|
            file.puts save_data
        end

    end

    def load_game
        if File.exist?('./saves/save_data.rb')
            require './saves/save_data.rb'
            return Save_state::GAME_WORD, Save_state::INCORRECT_GUESS_NUM, Save_state::LETTERS_GUESSED, Save_state::WORD_PROGRESS
        else
            puts 'No saves found.'
        end


    end
end

class GAME
    puts "Welcome to Hangman"
    puts "Would you like to load a saved game? 'y' or 'n'"
    open_load = gets.chomp.downcase
    if open_load == 'y'
        game_word, incorrect_guess_num, letters_guessed, word_progress = SAVE.new.load_game
    else
        game_word = WORD.new.secret_word().chomp
        incorrect_guess_num = 0
        letters_guessed = []
        word_progress = Array.new(game_word.length, "_ ")
    end

    gameboard = DRAW.new(game_word)
    gameboard.update_hangman(incorrect_guess_num, '', [], word_progress)

    while incorrect_guess_num < Pics::HANGMANPICS.length - 1 # Continue to ask for guess until full hangman has been drawn
        puts "Guess a letter"
        guess = gets.chomp.downcase
        GUESS.new().input_validation(guess, letters_guessed)
        if guess == ''
            GUESS.new().input_validation(letters_guessed)
        end
        letters_guessed << guess
        puts "Letters guessed: #{letters_guessed.uniq}"
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
        puts "Save game and quit? Enter 'y' to save or any key to continue."
        save = gets.chomp.downcase
        if save == 'y'
            SAVE.new.save_game(game_word, incorrect_guess_num, letters_guessed, word_progress)
            puts "Game has been saved. Thanks for playing!"
            break
        end
    end
    unless game_word == word_progress.join() || save == 'y'
        puts "\nYou ran out of guesses! The correct word was: #{game_word}\n\n"
    end
end

GAME.new()


