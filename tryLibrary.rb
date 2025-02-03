# coding: utf-8
def pretty_print(text, width)
  words = text.split(" ")
  line = ""
  result = []

  words.each do |word|
    if line.length + word.length + 1 > width
      result << line.strip
      line = word + " "
    else
      line += word + " "
    end
  end

  result << line.strip unless line.empty?

  result.each { |line| puts line }
end

text = "I Need To Be Myself
I Can't Be No One Else
I'm Feeling Supersonic
Give Me Gin And Tonic
You Can Have It All But How Much Do You Want It?
You Make Me Laugh
Give Me Your Autograph
Can I Ride With You In Your BMW?
You Can Sail With Me In My Yellow Submarine
You Need To Find Out
'Cause No One's Gonna Tell You What I'm On About
You Need To Find A Way For What You Want To Say
But Before Tomorrow"
width = 20
pretty_print(text, width)
