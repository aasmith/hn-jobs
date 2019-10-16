require 'json'

comments = JSON.parse(STDIN.read).values

comments.select!  { |comment|  comment["text"] =~ /Seattle|Calgary/i }
comments.sort_by! { |comment| -comment["time"] }
comments.map!     { |comment|  comment["text"] + ("<p>posted %s" % Time.at(comment["time"])) }

puts "<p>" + comments.join("<hr><p>")
