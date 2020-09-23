# HN Job Puller

Downloads recent "Who Wants to be Hired?" correspondence, and finds qualified candidates meeting a given (regex) criteria.

## Usage

Download the latest posts and responses. A cache is populated in `cache.json` to prevent redundant pulls.

```
$ ruby hnpull.rb
```

Filter the current cache of postings against a provided regexp.

Multiple filters are ANDed together.

Search for postings matching SRE or devops:

```
$ ./filter "sre|devops"
```

Search for SRE and DevOps in Seattle:

```
$ ./filter "sre|devops" "seattle"
```

Read `candidates.html` using your favourite web browser.

