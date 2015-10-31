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
  time_selector: ["created_at"],
  filters: [{op: "==", val: "PushEvent", selector: ["type"]},
            {op: "match", val: "mattknox/", selector: ["repo", "name"]},
           ],
  data_selector: ["payload", "commits"],
}

require "httparty"
require "active_support/all"

def interpret(spec)
  response = HTTParty.get spec[:url]
  relevant = response.select { |elt| relevant_element?(elt, spec) }

end

def relevant_element?(elt, spec)
  Time.parse(eval_selector(elt, spec[:time_selector])).in_time_zone("Pacific Time (US & Canada)").today? &&
    spec[:filters].all? {|f| run_filter(elt, f)}
end

def eval_selector(obj, arr)
  # this evaluates a chain of argumentless selectors
  arr.inject(obj) {|m, x| evapp(m, x) }
end

def run_filter(obj, f)
  x = eval_selector(obj, f[:selector])
  x.send f[:op], f[:val]
end

def evapp(x, str)
  if "." == str.first
    x.send(str)
  else
    x[str]
  end
end
