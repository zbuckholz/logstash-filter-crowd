# encoding: utf-8
#
# Atlassian Crowd Filter
#
# This filter will lookup user email from Crowd REST API using username.
# Before using this you must create an application account in Crowd and
# allow the IP of your logstash indexing server access.
#

require "logstash/filters/base"
require "logstash/namespace"
require "json"
require "rest_client"

# The Atlassian Crowd filter performs a lookup of a user email address
# if given a username.
#
# The config should look like this:
#
#     filter {
#       crowd {
#       	crowdURL => "https:/crowd/rest/usermanagement/1/user"
#       	crowdUsername => "username"
#       	crowdPassword => "password"
#       	timeout => 2
#       	username_field => "user1"
#       }
#     }
#
class LogStash::Filters::Crowd < LogStash::Filters::Base

  config_name "crowd"
  milestone 1 

  # Username field that contains look up value, in my grok filter I parse the stash logs and assign the user having a captcha problem to user1
  config :username_field, :validate => :string, :required => true

  # Determine what action to do: append or replace the values in the field
  # specified under "username"
  config :action, :validate => [ "append", "replace" ], :default => "append"

  # Atlassian Crowd REST API URL
  config :crowdURL, :validate => :string, :required => true

  # Atlassian Crowd REST API Username
  config :crowdUsername, :validate => :string, :required => true

  # Atlassian Crowd REST API Password
  config :crowdPassword, :validate => :string, :required => true
  
  # RestClient timeout
  config :timeout, :validate => :number, :default => 2

  public
  def register
	@resource = RestClient::Resource.new(@crowdURL,
                        :user => @crowdUsername,
                        :password => @crowdPassword,
                        :timeout => timeout)
  end # def register

  public
  def filter(event)
    return unless filter?(event)
		if event[username_field]
  			username = event[username_field]
				completeURL = crowdURL + "?username" + "=" + username # this line is throwning nil err
				begin
					response = @resource.get(:accept => 'json', :params => {:username => username})
				rescue => e
					e.response
				end
				begin
    					responseHash = JSON.parse(response)
				rescue => e
					e.backtrace
				end
				begin
					if responseHash["email"]
    						email = responseHash["email"]
						event['email'] = email
    						filter_matched(event)
					end
				rescue => e
					e.backtrace
				end
		end
  end


end # class LogStash::Filters::Crowd
