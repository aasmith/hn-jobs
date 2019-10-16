require 'json'
require 'net/http'
require 'thread'
require 'uri'

name  = "whoishiring"                      # hn username
lead  = /^Ask HN: Who wants to be hired/   # Title string to match on.
limit = 15                                 # How many posts by the user to look at for the matching title before giving up.

cache = begin
  JSON.parse(File.read "cache.json")
rescue Errno::ENOENT
  # Create an emtpy cache if the file doesn't exist.
  {}
end

def fetch(id, type: :item)
  5.times do |i|
    uri = URI.parse("https://hacker-news.firebaseio.com/v0/%s/%s.json" % [type, id])
    response = Net::HTTP.get_response(uri)

    if Net::HTTPSuccess === response
      break JSON.parse response.body
    else
      warn response.body
      abort "Error code %s fetching %s %s, %s." % [response.code, type, id, i.zero? ? "aborting" : "retrying"]
    end
  end
end

def user(id)
  fetch id, type: :user
end

def item(id)
  fetch id, type: :item
end

user = user(name)

warn "Found %s posts from %s, scanning the first %s for %s..." % [
  user["submitted"].size, name, limit, lead.to_s
]

posts = []

user["submitted"].first(limit).each do |id|
  item = item(id)
  posts << item if item["title"] =~ lead
end

warn "Have %s relevant posts, fetching comments from each..." % posts.size

mutex = Mutex.new
comments = cache
threads  = []

posts.each do |post|
  post["kids"].each do |id|

    next if comments.key? id.to_s || comments["dead"] || comments["deleted"]

    loop do
      if threads.size > 100 && threads.count(&:alive?) > 100
        # warn "waiting for more sockets"
        sleep 0.05
      else
        break
      end
    end

    threads << Thread.new do
      item = item(id)

      mutex.synchronize do
        comments[id] = item if item
      end
    end

  end
end

threads.each &:join

warn "Cache now contains %s comments." % comments.size

File.write "cache.json", JSON.generate(comments)

__END__

curl -q -sS "https://hacker-news.firebaseio.com/v0/user/whoishiring.json?print=pretty"
{
  "about" : "This account automatically submits a &#x27;Who is Hiring?&#x27; post at 11 AM Eastern time on the first weekday of every month.",
  "created" : 1287610767,
  "id" : "whoishiring",
  "karma" : 31575,
  "submitted" : [ 21126014, 21126013, 21126012, 3300386, 3300378, 3300371, 3181801, 3181796, 3060222, 3060221, 2949790, 2949787, 2831651, 2831646, 2607058, 2607052, 2503209, 2503204, 2456337, 2456333, 2412958, 2396088, 2396027, 2392675, 2392657, 2392582, 2392274, 2391828 ]
}

curl -q -sS "https://hacker-news.firebaseio.com/v0/item/21126012.json?print=pretty"
{
  "by" : "whoishiring",
  "descendants" : 380,
  "id" : 21126012,
  "kids" : [ 21187014, 21138195, 21128920, 21129826, 21133954, 21128891, 21128848, 21130811, 21133572, 21131818, 21129989, 21126704, 21129660, 21128917, 21132837, 21134562, 21128927, 21132026, 21136844, 21134865, 21134182, 21133395, 21132647, 21133168, 21127344, 21134251, 21131761, 21128950, 21131010, 21128399 ],
  "score" : 170,
  "text" : "Share your information if you are looking for work. Please use this format:<p><pre><code>  Location:\n  Remote:\n  Willing to relocate:\n  Technologies:\n  Résumé&#x2F;CV:\n  Email:\n</code></pre>\nReaders: please only email these addresses to discuss work opportunities.",
  "time" : 1569942018,
  "title" : "Ask HN: Who wants to be hired? (October 2019)",
  "type" : "story"
}
