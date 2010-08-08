new_git_project = ! File.exist?('.git')

git :init if new_git_project

generate('rspec')
generate('cucumber')

gem 'andand'
gem "erubis"
gem "haml"
gem "notahat-machinist", :lib => 'machinist', :source => "http://gems.github.com"

run 'rm README'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/images/rails.png'
run 'rm public/javascripts/*.js'
run 'touch public/javascripts/application.js'

JQUERY = "1.4.2"

run 'curl -L http://code.jquery.com/jquery-#{JQUERY}.min.js > public/javascripts/jquery-#{JQUERY}.min.js'

file '.gitignore', <<-EOF
.DS_Store
coverage/*
db/*.sqlite3
log/*.log
tmp/**/*
EOF

file 'config.ru', <<-EOF
ENV['RAILS_ENV'] = ENV['RACK_ENV'] if !ENV['RAILS_ENV'] && ENV['RACK_ENV']

require "config/environment"

use Rails::Rack::LogTailer
use Rails::Rack::Static
run ActionController::Dispatcher.new
EOF

file 'app/views/layouts/application.html.haml', <<-EOF
!!!
%html
  %head
    %title New project
    = stylesheet_link_tag "main"
    = javascript_include_tag "http://ajax.googleapis.com/ajax/libs/jquery/#{JQUERY}/jquery.min.js"
    = javascript_include_tag "application"
  %body
    -if flash[:notice]
      .notice= flash[:notice]
    -if flash[:alert]
      .alert= flash[:alert]
    =yield
EOF


route "map.root :controller => 'root'"

file 'app/controllers/root_controller.rb', <<-EOF
class RootController < ApplicationController

  def index
  end
end
EOF

file 'app/views/root/index.html.haml', <<-EOF
%h1 Welcome
EOF

append_file 'Rakefile', <<-EOF

# Run spec and cucumber as default task
task :default => :cucumber
EOF

file 'spec/blueprints.rb', <<-EOF
require 'machinist/active_record'
require 'faker'
require 'sham'
EOF

append_file 'spec/spec_helper', <<-EOF
require 'spec/blueprints'
EOF


rake "db:migrate"

if new_git_project
  git :add => '.'
  git :commit => "-a -m 'Initial commit'"
end
