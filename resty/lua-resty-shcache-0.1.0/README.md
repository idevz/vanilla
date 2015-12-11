shcache - simple cache object atop ngx.shared.DICT
==================================================

shcache is an attempt at using ngx.shared.DICT with a caching state machine layed on top

it assumes that you're using some slower external lookup (memc, *sql, redis, etc) that you
want to cache the result of, inside your ngx_lua application code.

it aims at :

* being very simple to use from a user perspective
* minimizing the number of external lookup, notably by caching negative lookups and preventing
external lookup stampeded via the usage of locks
* minimizing the amount of serialization / de-serialization to store/load the in cache
* be as fault-tolerant as possible, in case the external lookup fails ( see: cache load stale )


This is based on the lock mechanism devised by Yichun "agentzh" Zhang, and available here:
http://github.com/agentzh/lua-resty-lock

It assumes that a "locks" shared dict, has been created using the directive
`lua_shared_dict` in your Nginx conf.

An overview of the state machine is available within this repo, as a graphviz file.


Usage
=====

    local shcache = require("shcache")
    local cmsgpack = require("cmsgpack")

    -- use lua-resty-memcached connector to get data
    local memc = require("memcached")


    local function load_from_cache(key)

        -- closure to perform external lookup to memcache
        local lookup = function ()
            local memc, err = memcached:new()
            if not memc then
                neturn nil, err
            end

            local ok, err = memc:connect("127.0.0.1", 11211)
            if not ok then
                return nil, err
            end

            local value, flags, err = memc:get(key)
            memc:close()

            if not value then
                return nil, err
            end

            -- return data in the form of a table
            return { value = value,
                     flags = flags }
        end

        local my_cache_table = shcache:new(
            ngx.shared.cache_dict
            { external_lookup = lookup,
              encode = cmsgpack.pack,
              decode = cmsgpack.decode,
            },
            { positive_ttl = 10,           -- cache good data for 10s
              negative_ttl = 3,            -- cache failed lookup for 3s
              name = 'my_cache',           -- "named" cache, useful for debug / report
            }
        )

        local my_table, from_cache = my_cache_table:load(key)

        if my_table then
            if from_cache then
                -- cache_status == "HIT" (or "STALE")
                print "cache hit"
            else
                -- cache_status == "MISS"
                print "cache miss (valid data)"
            end
        else
            if from_cache then
                -- cache_status == "HIT_NEGATIVE"
                print "cache hit negative"
            else
                -- cache_status == "NO_DATA"
                print "cache miss (bad data)"
            end
        end

    end


    -- example of logging code on a "named" shcache
    local function log_shcache()
        local shcache_obj = ngx.ctx.shcache['my_cache']

        print shcache_obj.cache_status -- HIT, MISS, HIT_NEGATIVE, STALE or NO_DATA
        print shcache_obj.lock_status  -- NO_LOCK, IMMEDIATE or WAITED
    end



Methods
=======

new
---

`syntax: cache_obj = shcache:new(ngx.shared.DICT, callbacks, opts?)`

Creates an shcache object which implements the caching state machine in the attached documents

`ngx.shared.DICT` is the shared dictionnary (declared in Nginx conf by `lua_shared_dict` directive) to use

`callbacks.external_lookup` is the only required function, it's the closure necessary to lookup data. It should return the value if one exists, and optionally an error string to be logged, and/or an optional TTL value which overrides the positive_ttl option when saving a positive lookup.

`callbacks.encode` and `callbacks.decode` are optional (default to identity), if you intend to store a complex
Lua type (tables for instance), they should be declared as ngx.shared.DICT can only store text.

The `opts` table accepts the following options :

* `opts.positive_ttl`
save a valid external loookup for, in seconds
* `opts.positive_ttl`
save a invalid loookup for, in seconds
* `opts.actualize_ttl`
re-actualize a stale record for, in seconds
* `opts.lock_options`
set option to lock see : http://github.com/agentzh/lua-resty-lock for more details.
* `opts.name`
if shcache object is named, it will automatically register itself in ngx.ctx.shcache (useful for logging).

load
----

`syntax: data, from_cache = shcache:load(key)`

Use key to load data from cache, if no cache is available `callbacks.external_lookup` will be called

if data is available from cache `callbacks.decode` will be called before returning the data


Author
======

Matthieu Tourne <matthieu.tourne@gmail.com>
Rajeev Sharma  <rajeev@cloudflare.com>
John Graham Cumming <john@cloudflare.com>

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2013-2014, by CloudFlare Inc.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
