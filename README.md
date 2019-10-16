# HN Job Puller

Downloads recent "Who Wants to be Hired?" correspondence, and finds qualified candidates meeting a given (regex) criteria.

## Usage

Download the latest posts and responses. A cache is populated in `cache.json` to prevent redundant pulls.

```
$ ruby hnpull.rb
```

Filter the current cache against some specifics in filter.rb. Edit this file to change requirements.

```
$ ruby filter.rb < cache.json > candidates.html
```

Read `candidates.html` using your favourite web browser.

## TODO

 * Usability
 * Cache expiration / purging
