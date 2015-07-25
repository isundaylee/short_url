# Short URL [![Build Status](https://travis-ci.org/isundaylee/short_url.svg?branch=master)](https://travis-ci.org/isundaylee/short_url)

A simple implementation of URL shortener built with Sinatra with a Redis backend. 

# Installation

To run this URL shortener, you need to first [set up a Redis server](http://redis.io/topics/quickstart). After that, you can start it as you would any other Rack app:

```bash
git clone https://github.com/isundaylee/short_url.git
rackup -p 3000  # start it on port 3000
```

# Usage - HTML (browser)

A demo of this app can be found at http://jiahao.link

To create short URLs, simply go to `http://yoursite.com` (currently only supports creating URLs with automatically generated names).

To access a short URL, simply visit `http://yoursite.com/name` (which is also returned to you in JSON after you created the short URL), and you will be redirected to the actual URL. 

# Usage - JSON REST

To create a short URL (you can also omit the name parameter to get a randomly generated name that could be as short as 2 characters): 

```
POST /

Params: {'name': 'google', 'url': 'http://google.com'}
Response: {'url': 'http://example.com/google'}
```

To retrieve the actual URL: 

```
GET /google

Response: {'actual_url': 'http://google.com'}
```

# Contribution

If you wanna contribute to this app, you can [create issues](https://github.com/isundaylee/short_url/issues), or submit a pull request as follows: 

1. Fork it. 
2. Create a branch (`git checkout -b new_feature`)
3. Commit your changes (`git commit -am "Implements an awesome feature. "`)
4. Push to the branch (`git push origin new_feature`)
5. Open a [pull request](https://github.com/isundaylee/short_url/pulls)
6. Wait, while feeling good for your contribution :)