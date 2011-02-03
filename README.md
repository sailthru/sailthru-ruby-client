sailthru-ruby-client
====================

A simple client library to remotely access the `Sailthru REST API` as per [http://docs.sailthru.com/api](http://docs.sailthru.com/api)

It can make requests to following [API calls](http://docs.sailthru.com/api):

* [email](http://docs.sailthru.com/api/email)
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
	require 'lib/sailthru'

 	api_key = "api_key";
    api_secret = 'secret';
    api_url = "https://api.sailthru.com";
 	sailthru = Sailthru::SailthruClient.new(api_key, api_secret, api_url)

### [send](http://docs.sailthru.com/api/send)

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

### [email](http://docs.sailthru.com/api/email)

    #get email
    email = 'praj@sailthru.com'
    response = sailthru.get_email(email)

    #set email
    email = 'praj@sailthru.com'
    response = sailthru.set_email(email)

### [blast](http://docs.sailthru.com/api/blast)

	# schedule blast
	blast_name = 'My blast name'
	template = 'my-template'
	schedule_time = '+5 hours'
	from_name = 'prajwal tuladhar'
	from_email = 'praj@sailthru.com'
	subject = 'What's up!'
	html = '<p>Lorem ispum is great</p>'
	text = 'Lorem ispum is great'
	response = sailthru.schedule_blast(blast_name, template, schedule_time, from_name, from_email, subject, html, text)

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


### [list](http://docs.sailthru.com/api/list)

	#save list
	list_name = 'my-list'
	emails = ['praj@sailthru.com', 'ian@sailthru.com']
	response = sailthru.save_list(list_name, emails)

	#download /get list
	list_name = 'my-list'
	format = 'json'
	response = sailthru.get_list(list_name, format)

	#delete list
	list_name = 'my-list'
	response = sailthru.delete_list(list_name)

### [contacts](http://docs.sailthru.com/api/contacts)

	#import contacts
	email = 'infynyxx@aol.com'
	password = 'my super awesome password'
	with_names = true
	response = sailthru.import_contacts(email, password, with_names)

### [content](http://docs.sailthru.com/api/content)

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

### [alert](http://docs.sailthru.com/api/alert)

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

### [purchase](http://docs.sailthru.com/api/purchase)

	#purchase API call
	email = 'praj@sailthru.com'
	items = [{"price"=>1099, "qty"=>22, "title"=>"High-Impact Water Bottle", "url"=>"http://example.com/234/high-impact-water-bottle", "id"=>"234"}, {"price"=>500, "qty"=>2, "title"=>"Lorem Ispum", "url"=>"http://example.com/2304/lorem-ispum", "id"=>"2304"}]
	response = sailthru.purchase(email, items)

### [stats](http://docs.sailthru.com/api/stats)

	#stats list
	response = sailthru.stats_list()

	#stats blast
	blast_id = 42382
	response = sailthru.stats_blast(blast_id)

### [horizon](http://docs.sailthru.com/api/horizon)

	#get horizon user info
	email = 'praj@sailthru.com'
	response = sailthru.get_horizon(email)

	#set horizon data
	email = 'praj@sailthru.com'
	tags = ['red', 'blue']
	response = sailthru.set_horizon(email, tags)
