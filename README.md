domonodo
========

`domonodo` is a work-in-progress library for working with Domo.com's User and Data APIs.

## Version
0.0.2 - Implemented Domo's Data APIs and did some preliminary testing on most of the functions
0.0.1 - Implemented basic Authorization and User APIs

## Installation

    npm install domonodo

## Usage
    var domo = require('domonodo');

    // Store our authorization credentials
    var credentials = {
    	clientId: '<your clientId>',
    	clientSecret: '<your clientSecret>'
    };

	// Create a new UserClient 
	var duc = new domo.UserClient(credentials);
	// Authorize our client
	duc.getToken({}, function(err, res, body) {
		// List our Domo users
	    duc.listUsers({}, function(err, res, body) {
	        console.log(body);
	    });
	});

	// Create a new DataClient
	var ddc = new domo.DataClient(credentials);
	// Authorize our client
	ddc.getToken({}, function(err, res, body) {
		// List 10 datasets
	    ddc.listDataSets({ sort: 'name', fields: 'all', offset: '0', limit: 10 }, function(err, res, body) {
	    	// Grab the first id returned (you would usually want to validate the results a bit)
	    	var dsid = body[0].id
	    	// Retrieve the metadata for the first dataset id
	    	ddc.getDataSet(dsid, {}, function(err, res, body) {
	        	console.log(body);
	    	});
	    	// Download the dataset in CSV format (can be a lot of data, beware!)
	    	ddc.pullData(dsid, {}, function(err, res, body) {
	        	console.log(body);
	    	});
	    });
	});

## Credits

Robert W Saunders &lt;eibbors@gmail.com&gt;

## License

(The MIT License)

Copyright (c) 2016 Robert W Saunders &lt;eibbors@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.