# request
a super simple library for interfacing with [**`HttpService::RequestAsync`**](https://developer.roblox.com/en-us/api-reference/function/HttpService/RequestAsync). Based on the [request](https://github.com/request/request) JavaScript library.

## Releases
The `request` library is available in the [releases tab](../../releases/latest). You can also grab a copy from the [Roblox library page](https://www.roblox.com/library/2847890638).

-----

## Table of Contents
1. [Basic Usage](#basic-usage)
2. [Asynchronous Usage](#asynchronous-usage)
3. [Advanced Usage](#advanced-usage)
4. [Request Options](#request-options)
5. [Response Table](#response-table)

## Basic Usage
```lua
local request = require(path.to.Request)

request("https://reqres.in/api/users/1", function(err, response, body)
    assert(not err, err) -- If an error occurs, break script and print to output.

    print("Response status code:", response.StatusCode) -- Print received status code.
    print("Response body:", body) -- Print received response body.
end)
```

> **Output**\
> `Response status code: 200`\
> `Response body: table: 0xffed705111f84d17bdf5`

***Note:** this will break if not fetching JSON data. The `request` library assumes responses are JSON-encoded. See* [**Request Options**](#request-options) *to learn how to disable automatic JSON parsing.*

-----

## Asynchronous Usage
The `request` library also supports [@evaera](https://github.com/evaera)'s [Promise](https://github.com/evaera/roblox-lua-promise) library.

```lua
request:async("https://reqres.in/api/users/2"):andThen(function(body)
    print("Response body:", body) -- Print received response body.
end):catch(function(err)
    return error(err) -- Catch any errors and print to output.
end)
```

> **Output**\
> `Response body: table: 0x8d9e92fc12754000acf7`

## Advanced Usage
In addition to making basic `GET` requests, a dictionary can also be passed in as the first parameter. See [**Request Options**](#request-options) for a full list of available options.

```lua
request({
    baseUrl = "https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker",
    url = "/6ba5ee838731937f27f2ffba3605cd5e6fbc483b/version-guid.txt",
    json = false
}, function(err, response, body)
    assert(not err, err) -- If an error occurs, break script and print to output.

    print("Response status code:", response.StatusCode) -- Print received status code.
    print("Response body:", body) -- Print received response body.
end)
```

> **Output**\
> `Response status code: 200`\
> `Response body: version-1086667668c048ce`

-----

## Request Options
### Required

- `url` - the URL (or path when using `baseUrl`) to make a request to.

### Optional

- `baseUrl` - this is prepended to `url` to form a full URL. For example, when `baseUrl = "https://api.trello.com/1"` and `url = "/boards/123456789"`, the two entries will concatenate to `"https://api.trello.com/1/boards/123456789"`.
- `method` - the HTTP request method to use when performing a request. Defaults to `GET`.
- `headers` - a dictionary of headers to pass to the request. If unset, `Content-Type` will be set to `application/json` when `json = true`.
- `body` - a string to send with the request. Can also be an array or dictionary, when using `json = true`.
- `resolveWithFullResponse` - **async only** - if `true`, the full reponse object is returned when the Promise resolves. Otherwise, only the response body is returned. Defaults to `false`.

## Response Table
The response table is [almost identical](https://developer.roblox.com/en-us/api-reference/function/HttpService/RequestAsync#response-dictionary-fields) to that returned from `HttpService::RequestAsync`.

- `Success` - boolean value which equals `true` if the value of `StatusCode` is within the `200 - 299` range.
- `StatusCode` - HTTP response code.
- `StatusMessage` - HTTP status message received from server.
- `Headers` - a dictionary of response headers.
- `Body` - the data received back from the server (will be a table if response is JSON-encoded and `json = true` in request options).
- `ResponseTime` - the time (in seconds) that was taken to receive a response from the server.
