require 'sinatra'

require './Madlib.rb'
require './Dynamo.rb'

get '/new' do
	form = Dynamo.new
	form.append({
		'tag' => "INPUT",
		'attributes' => {
			'id' => "drink",
			'name' => "drink",
			'placeholder' => 'name?',
			'type' => 'text',
		} 
	}).select(%w(cider wine other))
	.append({
		'tag' => "BUTTON",
		'content' => "submit"
	}).to_s
end
