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

    next = moment(@start).startOf 'day'
    .add (count+correction) * @units, @measure

    if @isAfterEndDate(next) then null else next

  getFromDateCorrection: ->
    return 0 if not @from
    return 0 if moment(@from).isBefore @start

    start = moment(@start).startOf 'day'
    from = moment(@from).startOf 'day'

    Math.ceil Math.abs(start.diff(from, @measure, true)) / @units

  matches: (date) ->
    return false if @isBeforeFromDate date
    return false if @isBeforeStartDate date

    date = moment(date).startOf 'day'
    start = moment(@start).startOf 'day'
    diff = start.diff date, @measure, true

    return true if diff % @units is 0

    Math.floor(diff) % @units is 0 and
      @isRecurringOnLastDayOfMonth date

  isBeforeFromDate: (date) ->
    @from and moment(@from).startOf('day').isAfter date

  isBeforeStartDate: (date) ->
    moment(@start).startOf('day').isAfter date

  isAfterEndDate: (date) ->
    if not @end
      return false

    endOfEndDay = moment(@end).endOf('day')
    moment(date).isAfter(endOfEndDay)

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
