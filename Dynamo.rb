#! /usr/bin/ruby

class Dynamo

def initialize
	@value = ""
end

# incredibly agnostic html rendering function, give it a raw string or a 
# hash and watch it work its magic. The idea is the Dynamo is a dynamic 
# widget on the page.
def write(params)
	if params.is_a? String then
                @value = params
        elsif params.is_a? Hash then
                @value = render_hash(params)
        end

	self
end

def append(params)
	if params.is_a? String then 
		@value += params
	elsif params.is_a? Hash then
		@value += render_hash(params)
	end

	self
end

# wrap takes the existing Dynamo and wraps it with the tag
def wrap(tag="", attributes=nil)
	write({
                'tag' => tag,
                'content' => to_s,
                'attributes' => attributes
        })
	self
end

def a_href(content, href, params={})
	href = Dynamo.href(href, params)

	append({
		'tag' => "A",
		'content' => content,
		'attributes' => {
			'href' => href,
		}
	})

	self
end

# class method as URL's will be nice to generate on their own
def Dynamo.href(href, params={})
	anchor = ""
	params.keys.each do |k|
		if params[k].is_a? String then 
			if href =~ /\?/ then
				href += "&amp;"
			else
				href += "?"
			end

			href += "#{CGI.escape(k.to_s)}=#{CGI.escape(params[k].to_s)}"

		elsif params[k] == true then
			anchor = "##{k}"
		end
	end

	href += anchor
end

# Crazy macro used to generate a table header, with URLs generated
# and emphasis on the current sort order.
# The actual sorting will always be done in the module, and 
# images will be clipped on later...
def tr_head(params, table, url, headings)
	if not headings.is_a? Array then return self end

	append({
		'tag' => "TR", 
		'attributes' => {
			'class' => "head",
		}
	})

	headings.each do |p|
		downs = p.downcase
		heading = Dynamo.new.append(p)
		order = 'asc'
		if (downs == params["#{table}_sortby"]) then
			heading.wrap("STRONG")
			if params["#{table}_order"] == "asc" then order = "des" end
		end

		content = Dynamo.new.a_href(heading.to_s, "#{url}", {
			"#{table}_sortby" => downs,
			"#{table}_order" => order,
			"#{table}" => true,
		})

		append({
			'tag' => "TD",
			'content' => content.to_s,
			'attributes' => {
				'class' => p,
			},
		})
	end
	append("</TR>\n")

	self
end

def tr_data(src, trclass, params)
	if not params.is_a? Array then return self end

	append({
		'tag' => "TR", 
		'attributes' => {
			'class' => trclass,
		}
	})

	params.each do |p|
		append({
			'tag' => "TD",
			'content' => src[p],
			'attributes' => {
				'class' => p,
			},
		})
	end

	append("</TR>\n")

	self
end

def clear_float
	append({
                'tag' => "DIV",
                'content' => "",
                'attributes' => {
                        'style' => "clear: both",
                }
        })
	
	self
end

def select(src)
	box = Dynamo.new
	if src.is_a? Array then
		src.sort.each { |opt|
			box.append({
				'content' => opt,
				'newline' => true,
				'tag' => "OPTION",
				'attributes' => {
					'value' => opt
				}
			})
		}
	end
	box.wrap("SELECT")
	append(box.to_s)

	self
end

def to_s
	return @value
end

def sub!(dst, src)
	@value.sub!(dst, src)
	self
end

private

attr_accessor :value

# hash can have members content, tag and attributes
# content is a plain ol' string
# tag is the type of html element to render
# attributes are the attributes of the tag, this is a nested hash
# the members of attributes can either be a string or boolean true
# string renders as: key="value" e.g. href="/home"
# true renders as: key e.g. checked
def render_hash(params)
	value = ""
	if params['tag'] then 
		value += "<#{params['tag']}{attributes}>"

		attributes = ""
		if params['attributes'].is_a? Hash then
			params['attributes'].keys.sort.each do |k|
				v = params['attributes'][k]
				if v.is_a?(String) then 
					attributes += " #{k}=\"#{v}\""
				elsif v == true then
					attributes += " #{k}";
				end
			end
		end
		value.sub!(/{attributes}/, attributes)
	
	end

	if params['content'] then value += "#{params['content']}" end

	if (params['tag'] != nil) and (params['content'] != nil) then value += "</#{params['tag']}>" end

	if params['newline'] then value += "\n" end

	value
end

end
