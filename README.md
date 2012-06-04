sailthru-ruby-client
====================

A simple client library to remotely access the `Sailthru REST API` as per [http://docs.sailthru.com/api](http://docs.sailthru.com/api)

By default, it will make request in `JSON` format.

It can make requests to following [API calls](http://docs.sailthru.com/api):

* [email](http://docs.sailthru.com/api/email)
* [user](http://docs.sailthru.com/api/user)
* [send](http://docs.sailthru.com/api/send)
* [blast](http://docs.sailthru.com/api/blast)
* [template](http://docs.sailthru.com/api/template)
* [list](http://docs.sailthru.com/api/list)
* [contacts](http://docs.sailthru.com/api/contacts)
* [content](http://docs.sailthru.com/api/content)
* [alert](http://docs.sailthru.com/api/alert)
* [stats](http://docs.sailthru.com/api/stats)
* [purchase](http://docs.sailthru.com/api/purchase)
* [horizon](http://docs.sailthru.com/api/horizon)

### Installing from rubygems.org (Tested with Ruby 1.8.7)
    $ gem install sailthru-client

Examples
--------

``` ruby
require 'sailthru' #if using as gem

api_key = "api_key";
api_secret = 'secret';
sailthru = Sailthru::SailthruClient.new(api_key, api_secret)

# GET http://docs.sailthru.com/api/user API call
user_key = 'email'
email = 'praj@sailthru.com'
fields = {'vars' => 1, 'lists' => 1}
data = {
    'id' => email,
    'key' => user_key,
    'fields' => fields
}
response = sailthru.api_get('user', data)

# POST http://docs.sailthru.com/api/user API call
user_sid = '4e2879472d7acd6d97144f9e' #sailthru ID
lists = {
    "list-A" => 1,
    "list-B" => 1,
    "list-C" => 0 #optout of this list
}
vars = {
    'name' => 'Prajwal Tuladhar',
    'address' => {
        'city': 'New York',
        'state': 'NY',
        'zipcode': 10011
    }
}
data = {
    'id' => user_sid,
    'lists' => lists,
    'vars' => vars
}
response = sailthru.api_post('user', data)

```

### [send](http://docs.sailthru.com/api/send)
``` ruby
#send
template_name = 'my-template'
email = 'praj@sailthru.com'
vars = {'name' => 'Prajwal Tuladhar', "myvar" => [1111,2,3]}
options = {'test' => 1}
schedule_time = '+3 hours'
response = sailthru.send(template_name, email, vars, options, schedule_time)

#get send
send_id = '6363'
response = sailthru.get_send(send_id)

#cancel send
send_id = '236236sbs'
response = sailthru.cancel_send(send_id)

#multi send
template_name = 'my-template'
emails = 'praj@sailthru.com, ian@sailthru.com'
vars = {'name' => 'Prajwal Tuladhar', "myvar" => [1111,2,3]}
options = {'test' => 1}
response = sailthru.multi_send(template_name, emails, vars, options)
```

### [user](http://docs.sailthru.com/api/user)
```ruby
#create new user profile
options = {
    'vars' => {
        'name' => 'Prajwal Tuladhar',
        'address' => 'New York, NY'
    }
}
response = sailthru.create_new_user(options)

#update existing user by Sailthru ID
options = {
    'keys' => {
        'email' => 'praj@sailthru.com',
        'twitter' => 'infynyxx',
        'fb' => 726310296
    },
    'lists' => {
        'list-1' => 1,
        'list-2' => 1,
    }
}
response = sailthru.save_user('4e2879472d7acd6d97144f9e', options)

#update existing user by email
options = {
    'key' => 'email',
    'lists' => {
        'list-1' => 0
    }
}
response = sailthru.save_user('praj@sailthru.com', options)

#get user by Sailthru ID
fields = {
    'keys' => 1,
    'vars' => 1,
    'activity' => 1
}
response = sailthru.get_user_by_sid('4e2879472d7acd6d97144f9e')

#get user by Custom key
response = sailthru.get_user_by_key('praj@sailthru.com', 'email', fields)

```


### [email](http://docs.sailthru.com/api/email)
``` ruby
#get email
email = 'praj@sailthru.com'
response = sailthru.get_email(email)

#set email
email = 'praj@sailthru.com'
response = sailthru.set_email(email)
```

### [blast](http://docs.sailthru.com/api/blast)
``` ruby
#schedule blast
blast_name = 'My blast name'
template = 'my-template'
schedule_time = '+5 hours'
from_name = 'prajwal tuladhar'
from_email = 'praj@sailthru.com'
subject = "What's up!"
html = '<p>Lorem ispum is great</p>'
text = 'Lorem ispum is great'
response = sailthru.schedule_blast(blast_name, template, schedule_time, from_name, from_email, subject, html, text)

#schedule blast from template
template = 'default'
list = 'default'
schedule_time = 'now'
response = sailthru.schedule_blast_from_template(template, list, schedule_time)

#schedule blast from previous blast
blast_id = 67535
schedule_time ='now'
vars = {
'my_var' => '3y6366546363',
'my_var2' => [7,8,9],
'my_var3' => {'president' => 'obama', 'nested' => {'vp' => 'palin'}}
}
options = {:vars => vars}
response = sailthru.schedule_blast_from_blast(blast_id, "now", options)

#update blast
blast_id = 7886
name = 'prajwal tuladhar 64'
response = sailthru.update_blast(blast_id, name = name)

#get blast info
blast_id = 7886
response = sailthru.get_blast(blast_id)

#cancel blast
blast_id = 7886
response = sailthru.cancel_blast(blast_id)

#delete blast
blast_id = 7886
response = sailthru.delete_blast(blast_id)
```

### [list](http://docs.sailthru.com/api/list)

Get information about a list, or create a list.

``` ruby
#save list
list_name = 'my-list'
options = {
    'primary' => 1,
}
response = sailthru.save_list(list_name, options)

#get list information
list_name = 'my-list'
response = sailthru.get_list(list_name)

#get all lists
response = sailthru.get_lists()

#delete list
list_name = 'my-list'
response = sailthru.delete_list(list_name)
```

### [content](http://docs.sailthru.com/api/content)
``` ruby
#push content
title = 'hello world'
url = 'http://example.com/product-url'
response = sailthru.push_content(title, url)

#another push content exammple
title = 'hello world'
url = 'http://example.com/product-url'
tags = ["blue", "red", "green"]
vars = {'vars' => ['price' => 17299]}
date = nil
response = sailthru.push_content(title, url, date, tags = tags, vars = vars)
```

### [alert](http://docs.sailthru.com/api/alert)
``` ruby
#get alert info
email = 'praj@sailthru.com'
response = sailthru.get_alert(email)

#save alert
email = 'praj@sailthru.com'
type = 'daily'
_when = '+5 hours'
extras = {'tags' => ['red', 'blue'], 'match' => {'type' => 'yellow'}}
response = sailthru.save_alert(email, type, _when, extras)

#delete alert
email = 'praj@sailthru.com'
alert_id = '4d4b17a36763d930210007ba'
response = sailthru.delete_alert(email, alert_id)
``` ruby

### [purchase](http://docs.sailthru.com/api/purchase)
``` ruby
#purchase API call
email = 'praj@sailthru.com'
items = [{"price"=>1099, "qty"=>22, "title"=>"High-Impact Water Bottle", "url"=>"http://example.com/234/high-impact-water-bottle", "id"=>"234"}, {"price"=>500, "qty"=>2, "title"=>"Lorem Ispum", "url"=>"http://example.com/2304/lorem-ispum", "id"=>"2304"}]
response = sailthru.purchase(email, items)
```

### [stats](http://docs.sailthru.com/api/stats)
``` ruby
#stats list
response = sailthru.stats_list()

#stats blast
blast_id = 42382
response = sailthru.stats_blast(blast_id)
```

### [horizon](http://docs.sailthru.com/api/horizon)
``` ruby
#get horizon user info
email = 'praj@sailthru.com'
response = sailthru.get_horizon(email)

#set horizon data
email = 'praj@sailthru.com'
tags = ['red', 'blue']
response = sailthru.set_horizon(email, tags)
```


### [job] (http://docs.sailthru.com/api/job)
``` ruby
# get status of job id
job_id = '4dd58f036803fa3b5500000b'
response = sailthru.get_job_status(job_id)

# process import job for email string
list = 'test-list'
emails = 'a@a.com,b@b.com'
response = sailthru.process_import_job(list, emails)

# process import job from CSV or text file
list = 'test-list'
source_file = '/home/praj/Desktop/emails.txt'
response = sailthru.process_import_job(list, source_file)

# process snapshot job
query = {}
report_email = 'praj@sailthru.com'
postback_url = 'http://example.com/reports/snapshot_postback'
response = sailthru.process_snapshot_job(query)

# process export list job
list = 'test-list'
response = sailthru.process_export_list_job(list)
```
