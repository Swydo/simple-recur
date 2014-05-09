simple-recur
============

Calculate date recurrence

## Test

    npm test

## Build

    npm run build

## Watch

    npm run watch

## Examples

```coffee-script
Recur = require 'simple-recur'

recur = new Recur
recur.every 2, 'month'

recur.next 3
// outputs: [moment, moment, moment]

recur.matches new Date
// outputs a boolean
```