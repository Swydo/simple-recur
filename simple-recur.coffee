moment = @moment or require 'moment'

DateString = (date) -> moment(date).format 'YYYY-MM-DD'

class Recur

  @attributes:
    units: Number
    measure: String
    start: DateString
    end: DateString
    from: DateString

  constructor: (data = {}) ->
    @set data
    @setDefaults()

  set: (data = {}) ->
    for attr of @constructor.attributes when data[attr]?
      @[attr] = data[attr]
    this

  setDefaults: ->
    @units ?= 1
    @measure ?= 'month'
    @start ?= moment()

  next: (begin = 1, end) ->
    if not end
      end = begin
      begin = 0

    (@nextAt i for i in [begin...end])

  nextAt: (count = 1) ->
    correction = @getFromDateCorrection()

    moment(@start).startOf 'day'
    .add (count+correction) * @units, @measure

  getFromDateCorrection: ->
    return 0 if not @from
    return 0 if moment(@from).isBefore @start

    start = moment(@start).startOf 'day'
    from = moment(@from).startOf 'day'

    Math.ceil from.diff(start, @measure, true) / @units

  matches: (date) ->
    return false if @isBeforeFromDate date
    return false if @isBeforeStartDate date

    date = moment(date).startOf 'day'
    start = moment(@start).startOf 'day'
    diff = date.diff start, @measure, true

    return true if diff % @units is 0

    Math.ceil(diff) % @units is 0 and
      @isRecurringOnLastDayOfMonth date

  isBeforeFromDate: (date) ->
    @from and moment(@from).startOf('day').isAfter date

  isBeforeStartDate: (date) ->
    moment(@start).startOf('day').isAfter date

  isRecurringOnLastDayOfMonth: (date) ->
    return false if @measure isnt 'month'

    recurringMonthDay = moment(@start).date()
    dateMonthEndDay = moment(date).endOf('month').date()

    (recurringMonthDay > dateMonthEndDay) and
      moment(date).date() is dateMonthEndDay

  every: (@units, @measure) ->
    @

  clone: (data) ->
    new @constructor(this).set data

  toJSON: ->
    json = {}
    for attr, type of @constructor.attributes when @[attr]?
      json[attr] = type @[attr]

    delete json.from #temp attribute

    json

if module?.exports?
  module.exports = Recur
else
  @Recur = Recur
