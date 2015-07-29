#!/usr/bin/env ruby

require 'open3'
require 'optparse'

Opts = Struct.new(:corna, :cornb, :side, :steps, :ncolors)

COLORS = ['(0, 0, 0)',
          '(87, 128, 255)',
          '(255, 128, 87)',
          '(63, 157, 200)',
          '(255, 255, 255)']

def get_wallpaper(opts)
  (1..opts.steps).map do |i|
    (1..opts.steps).map do |j|
      x = opts.corna + i * opts.side * 1.0 / opts.steps
      y = opts.cornb + j * opts.side * 1.0 / opts.steps

      c = (x * x + y * y).floor
      c % opts.ncolors
    end
  end
end

def header(width, height)
  "# ImageMagick pixel enumeration: #{width},#{height},255,rgb"
end

def get_text_for_wallpaper(wallpaper)
  # wallpaper is a 2D array
  header = header(wallpaper.first.length, wallpaper.length)
  body = wallpaper.map.with_index do |row, i|
    row.map.with_index do |value, j|
      "#{i},#{j}: #{COLORS[value]}"
    end  
  end.flatten.join "\n"
  header + "\n" + body
end

def print_wallpaper(wallpaper)
  # Reference: Manav (https://github.com/mx4492/turing-omnibus/blob/master/algorithmic-wallpaper.rb)
  text = get_text_for_wallpaper wallpaper
  Open3.capture2("convert txt:- out.png", :stdin_data => text)
end

def get_default_opts
  Opts.new(0, 0, 37, 100, 2)
end

def get_opts
  opts = get_default_opts

  OptionParser.new do |options|
    options.banner = "Usage: wallpaper.rb [options]"

    options.on("-x", "--corna X", Integer) {|x| opts.corna = x}
    options.on("-y", "--cornb Y", Integer) {|x| opts.cornb = x}
    options.on("-s", "--side SIDE", Integer) {|x| opts.side = x}
    options.on("-n", "--steps STEPS", Integer) {|x| opts.steps = x}
    options.on("-c", "--ncolors NUMBER", Integer) {|x| opts.ncolors = x if x <= COLORS.length}

    options.on_tail("-h", "--help", "Show this message") do
      puts options
      exit
    end
  end.parse!
  opts
end

def main
  opts = get_opts
  
  wallpaper = get_wallpaper(opts)
  print_wallpaper wallpaper
end

main if __FILE__ == $0 
