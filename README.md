# Logstash Plugin
## Atlassian Crowd REST API for user lookups

This is a plugin for [Logstash](https://github.com/elasticsearch/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

Looks up user email based on username by making a REST API call to Atlassian Crowd server.

Example Grok Filter for Atlassian Stash Auth Log.
```
STASH_CAPTCHA %{IP:proxy},%{IP:client} \| %{WORD:error} \| %{WORD:user1} \| %{INT:epoch_time} \| %{WORD:user2} \| (?<error>{%{QS}:%{QS},%{QS}:"For security reasons you must answer a CAPTCHA question."}) \| %{INT:minuteinday}x%{INT:reqnumsincerestart}x%{INT:concurrentreqs} \| %{DATA:something}
```

Logstash Config Stanza for using this filter should look like the following.

The config should look like this:

```
     filter {
       crowd {
               crowdURL       => "https:/crowd/rest/usermanagement/1/user"
               crowdUsername  => "username"
               crowdPassword  => "password"
               timeout        => 4
               username_field => "user1"
       }
     }
# username_field = Is a required field that points to the field in the event
#                  before it's passed to this plugin that contains the
#                  Key / Value pair needed to perform the Atlassian Crowd
#                  REST lookup.
# crowdURL       = Is a required field that provides the URL to your Atlassian
#                  Crowd REST service.
# crowdUsername  = Is a required field that you must have previously setup
#                  in your Atlassian Crowd UI to allow REST calls. This is
#                  not a standard user account, or admin account. Crowd
#                  refers to these special accounts as Application Accounts.
# crowdPassword  = Is a required field that specifies the password used by
#                  this Atlassian Crowd Application Account.
# timeout        = Defines the amount of time the plugin should wait for the
#                  Atlassian Crowd REST service to respond. This is not required
#                  since a default of 2 seconds is set below. If you want to change
#                  the value you can do so in the logstash configuration file as
#                  shown above.
```
