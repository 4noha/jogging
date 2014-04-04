# -*- coding: utf-8 -*-


require 'sdl'
require "starruby"
include StarRuby

YOUR_WEIGHT = 62

font = Font.new("Osaka", 24)
white = Color.new(255, 255, 255)
before_time = time = Time.now.instance_eval { '%s.%06d' % [strftime('%S'), (usec / 1000.0).round] }.to_f
b_cnt = cnt = button_count = 0
kcal = 0.0
tate = false
ten_cnt = 0

#キャリブレーション
16.times do
  puts `osascript -e 'tell application "System Events" \n key code 107 \n end tell'`
end
8.times do
  puts `osascript -e 'tell application "System Events" \n key code 113 \n end tell'`
end
current_brightness = 8

Game.run(320, 240, :title => "Gamepad") do |game|
  break if Input.keys(:keyboard).include?(:escape)

  s = game.screen
  s.clear

  before_time_buffer = time
  time = Time.now.instance_eval { '%s.%06d' % [strftime('%S'), (usec / 1000.0).round] }.to_f
  if time-before_time > 1.0 || time-before_time < 0

    if (ten_cnt == 10)
      tate = !tate
      ten_cnt = 0
    else
      ten_cnt += 1
    end
    kcal += 0.04*button_count.to_f

    before_time = time
    level = 16 * button_count / cnt.to_f
    level = 16 if level > 16

    if level > current_brightness
      (level-current_brightness).to_i.times do
        puts `osascript -e 'tell application "System Events" \n key code 113 \n end tell'`
      end
      current_brightness = level
    else
      if current_brightness > level
        (current_brightness-level).to_i.times do
          puts `osascript -e 'tell application "System Events" \n key code 107 \n end tell'`
        end
        current_brightness = level
      end
    end
    button_count = 0
    b_cnt = cnt
    cnt = 0
    before_time = time
  else
  end

  # キー取得
  keys = Input.keys(:gamepad)
  s.render_text("Directions:", 8, 8,  font, white)
  # 方向キーだけ抽出して文字列配列に変換
  directions = keys.select{|b| b.kind_of?(Symbol)}.map{|b|b.to_s}
  # 配列の描画
  s.render_text("Buttons:", 8, 56, font, white)
  buttons = keys.select{|b| b.kind_of?(Integer)}.map{|b|b.to_s}
  s.render_text(buttons.join(","), 24, 80, font, white)


  unless directions.first.nil?
    s.render_text(directions.join(","), 24, 32, font, white)
    if (directions.first == "left" || directions.first =="right") && !tate
        button_count+=1
    else
      if (directions.first == "down" || directions.first =="up") && tate
        button_count+=1
      end
    end
  end
#  unless buttons.first.nil?
#    button_count+=1
#  end

  s.render_text("FPS:"+b_cnt.to_s, 8, 104, font, white)
  s.render_text("PushPerSec:"+button_count.to_s, 8, 128, font, white)
  s.render_text("CurrentBrightness:"+current_brightness.to_i.to_s, 8, 148, font, white)
  s.render_text("kcal:"+kcal.to_s, 8, 168, font, white)
  s.render_text("Direction:Horizonal←→", 8, 188, font, white)if (!tate)
  s.render_text("Direction:Vertical↑↓", 8, 188, font, white)if (tate)
  cnt+= 1

end

puts `osascript -e 'tell application "System Events" \n key code 113 \n end tell'`
puts `osascript -e 'tell application "System Events" \n key code 107 \n end tell'`
