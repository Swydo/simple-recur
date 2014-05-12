simple-recur
============

Calculate date recurrence

![Build status](https://api.travis-ci.org/jamiter/simple-recur.png)

## Test

    npm test

## Build

    npm run build

## Watch

    npm run watch

## Options

- units (Number)
- measure ('weeks', 'months', 'years')
- start (Date)
- from (Date)

## Examples

```coffee-script

    Recur = require 'simple-recur'

    recur = new Recur
    recur.every 2, 'month'

    recur.next 3
    # outputs: [moment, moment, moment]

    recur.matches new Date
    # outputs a boolean

```