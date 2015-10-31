<<BEGIN
There are lots of feeds that my actions drive: twitter, github, fitbit, etc.. I want to be able to specify in a fairly terse way my goals are for the activities that are reflected in those feeds, so I can track, eg., whether I'm writing enough, etc..

I'd like to specify this like so:

feed_url: "https://api.github.com/users/mattknox/events"
time-selector: ["created_at"]
filters: [{op: "=", val: "PushEvent", selector: ["type"]},

]
data-selector:


BEGIN

my_gh = {
  url: "https://api.github.com/users/mattknox/events",
  time-selector: ["created_at"],
  filters: [{op: "=", val: "PushEvent", selector: ["type"]},
            {op: ".match", val: "mattknox/", selector: ["repo", "name"]},
           ],
  data-selector: ["payload", "commits"],
}

require "httparty"
require "active_support/time"

def interpret(spec)
  response = HTTParty.get spec["url"]
  relevant = response.select { |elt| Time.parse(elt.send( spec[:time_selector])).today? }
end

def eval_selector(obj, arr)
  # this evaluates a chain of argumentless selectors
  arr.inject(obj) {|m, x| evapp(m, x) }
end

def evapp(x, str)
  if "." == str.first
    x.send(str)
  else
    x[str]
  end
end
