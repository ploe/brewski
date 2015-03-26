#! /usr/bin/ruby

# madlib is the dumb templating system I use. We stuff junk in to a hash,
# the keys of which are the patterns we're looking for and the pattern
# in them is what we replace them.
# They are bog standard HTML comments with the pattern in curly braces
# e.g. <!-- {arsethat} -->
# This is so HTML pages can be edited in a regular editor - no worries 
# over how to render to test.
def madlib(str, tags)
	tags.keys.each do |pattern|
		str.gsub!(/<!-- {#{pattern}} -->/, tags[pattern])
	end

	str
end

# meta_refresh is used to do generate a meta tag to autorefresh the page
def meta_refresh(duration, uri)
	"<meta http-equiv=\"refresh\"content=\"#{duration}; url=#{uri}\" >"
end
