# [`./jq`](https://stedolan.github.io/jq/)

**`jq` is like `sed` for JSON data** -
you can use it to slice and filter and map and transform structured data with the same ease that sed, awk, grep and friends let you play with text.

---

# What is it good for?

* Highlight json data
* Transform JSON(, csv, tsv and virtually everything) to JSON
* Process JSON data (basically full-blown map-reduce functionality)
  *can't work with multiple sources*
* Also as a calculator

---

# Quick background

* 3 years old (started in early 2013)
* Written in C
* No runtime dependencies (really portable)
* Extendable with custom modules

---

# Let's crunch the data

```bash
# Calculator
$ jq --null-input '1 + 2'
# => 3
```

---

# Basic usage

```bash
# Format & highlight json data
$ cat some.json | jq
$ curl http://json.org/example.json | jq
```

---

# Next step in usage

```bash
# Simple transformations
$ echo '{"foo": 1, "bar": 2}' | jq '.foo'
# => 1

# Extract data from array
$ echo '[{"foo": 1, "bar": 2}, {"foo": 2, "bar": 3}]' | jq '.[].foo'
# => 1
     2
```

---

## Quick manual - Basic filters
[`man jq`](https://stedolan.github.io/jq/manual)

* `.`
* `.foo`, `.foo.bar`
* `.foo?`
* `.[<string>]`, `.[2]`, `.[10:15]`
* `.[]`
* `.[]?`
* `,` - multiple selector
* `|` - pipe

---

## Quick manual - Constuction
* `[1, 2, 3]`
* `{foo: .bar}`
* `{(.user): .titles}`

---

## Quick manual - Operators

* `+`, `-`, `*`, `/`, `%`, `length`, ...
* `has(key)`, `in`, `to_entries`, `from_entries`, `with_entries`, ...
* `map`, `map_values`, `reduce`, `select`, `sort`, `sort_by`, `group_by`, `uniq`, `uniq_by`, ...
* `flatten`, `range`, ...
* `any`, `all`, ...
* Hey, it's a full language with controll flow. (`if`, `foreach`, `recursion` ...)

---

## Quick manual - etc.

* Conditions, comparsion
  * `==`, `!=`, `>`, `<`, `>=`, `<=`
  * `if then else end`
  * `and`, `or`, `not`
* Alternative op. `//`
* `try catch`
* RegularExpression support (same engine as in Ruby)
* Variables - `.foo[].name as $names` (destructive assignment is supported)
* Assignment - editing the JSON
* Modules

---

# Advanced usage
Extract offer contracts from offers!

---

# Input

```json
{
  "offer_id": "1",
  "offer_name": "Nice offer - PPL - HU/RU - DOI [WAP] [Exclusive]",
  "offer_contracts": {
    "offer_contract_info": [
      {
        "offer_contract_id": "123",
        "offer_link": "http://www.niceoffer.com/?foo=bar"
      },
      {
        "offer_contract_id": "321",
        "offer_link": "http://www.other-offer.com/?foo=baz"
      },
      ...
    ]
  }
}
```

---

# Output

we'd like to see (jsonl)

```json
{"contract_id":"123","country":"HU/RU","platform":"mobile","domain":"niceoffer.com"}
{"contract_id":"321","country":"HU/RU","platform":"mobile","domain":"other-offer.com"}
```

---

# Solution

```bash
$ cat offers.json | jq --from-file solution.jq
```

---

# `solution.jq`

```bash
.offer_name as $offer_name |
(.offer_name | capture("\\s+(?<val>[A-Z]{2}(\\/[A-Z]{2})*)\\s+"; "n") // {val: ""}) as $country |
(.offer_name | capture("\\s\\[(?<val>\\w+)\\]\\s?"; "n") // {val: ""}) as $platform |
.offer_contracts.offer_contract_info |
[.] | flatten(1) | .[] |
  (.offer_link | capture("https?:\\/\\/(www\\.)?(?<val>[\\w\\.-]+).*$"; "n") // {val: ""}) as $domain |
  {
    contract_id: .offer_contract_id,
    country: $country.val,
    platform: ($platform.val | ascii_downcase | sub("wap"; "mobile") | sub("web"; "desktop")),
    domain: $domain.val,
  }
```

---

# That's all
