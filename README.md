
# simple-recur

![Build status](https://api.travis-ci.org/jamiter/simple-recur.png)

> Calculate date recurrence.  A great alternative to [moment-recur](https://github.com/c-trimm/moment-recur) and [later](https://bunkat.github.io/later/).


## Install

```sh
npm install simple-recur
```


## Options

- `units` (Number)
- `measure` ('weeks', 'months', 'years')
- `start` (Date)
- `from` (Date)


## Examples

> JavaScript:

```js
const Recur = require('simple-recur');
const recur = new Recur(options);

// check if a given date matches this recurrence
const matches = recur.matches(new Date());
console.log('matches', matches);
// outputs: true/false

// get the next 3 occurrences
const nextThreeOccurrences = recur.next(3);
console.log('nextThreeOccurrences', nextThreeOccurrences);
// outputs: [moment, moment, moment]
```

> CoffeeScript:

```coffee-script
Recur = require 'simple-recur'

recur = new Recur
recur.every 2, 'month'

recur.next 3
# outputs: [moment, moment, moment]

recur.matches new Date
# outputs a boolean
```


## Test

```sh
npm test
```


## Build

```sh
npm run build
```


## Watch

```sh
npm run watch
```
