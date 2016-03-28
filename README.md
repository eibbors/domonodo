domonodo
========

`domonodo` is a work-in-progress implementation of the Domo.com's User and Dataset APIs.
It can currently get you an authorization token and use that to execute some of the User API requests.

## Version
0.0.1

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
    var du = new domo.UserClient(credentials);
    // Authorize our client
    du.getToken({}, function(err, res, body) {
    	du.listUsers(function(err, res, body) {
    		// log our users
    		console.log(body);
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