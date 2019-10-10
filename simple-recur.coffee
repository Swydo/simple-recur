dayjs = @dayjs or require 'dayjs'

DateString = (date) -> dayjs(date).format 'YYYY-MM-DD'

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
    @start ?= dayjs()

  next: (begin = 1, end) ->
    if not end
      end = begin
      begin = 0

    (@nextAt i for i in [begin...end])

  nextAt: (count = 1) ->
    correction = @getFromDateCorrection()

    next = dayjs(@start).startOf 'day'
    .add (count+correction) * @units, @measure

    if @isAfterEndDate(next) then null else next

  getFromDateCorrection: ->
    return 0 if not @from
    return 0 if dayjs(@from).isBefore @start

    start = dayjs(@start).startOf 'day'
    from = dayjs(@from).startOf 'day'

    Math.ceil Math.abs(start.diff(from, @measure, true)) / @units

  matches: (date) ->
    return false if @isBeforeFromDate date
    return false if @isBeforeStartDate date
    return false if @isAfterEndDate date

    date = dayjs(date).startOf 'day'
    start = dayjs(@start).startOf 'day'
    diff = start.diff date, @measure, true

    return true if diff % @units is 0

    Math.floor(diff) % @units is 0 and
      @isRecurringOnLastDayOfMonth date

  isBeforeFromDate: (date) ->
    @from and dayjs(@from).startOf('day').isAfter date

  isBeforeStartDate: (date) ->
    dayjs(@start).startOf('day').isAfter date

  isAfterEndDate: (date) ->
    if not @end
      return false

    endOfEndDay = dayjs(@end).endOf('day')
    dayjs(date).isAfter(endOfEndDay)

  isRecurringOnLastDayOfMonth: (date) ->
    return false if @measure isnt 'month'

    recurringMonthDay = dayjs(@start).date()
    dateMonthEndDay = dayjs(date).endOf('month').date()

    (recurringMonthDay > dateMonthEndDay) and
      dayjs(date).date() is dateMonthEndDay

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
