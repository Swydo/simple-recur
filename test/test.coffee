chai = require 'chai'
expect = chai.expect

moment = require 'moment'

describe "Scheduling Recur", ->
  beforeEach ->
    @format = 'YYYY-MM-DD'
    @date = new Date 3000, 0, 1

    Recur = require '../simple-recur'
    @recur = new Recur

  describe 'defaults', ->
    it 'should have units 1', ->
      expect @recur.units
      .to.equal 1

    it 'should have measure "month"', ->
      expect @recur.measure
      .to.equal 'month'

  describe '#set', ->
    it 'should set values of the timer', ->
      data =
        units: 3
        measure: 'week'

      @recur.set data

      for attr, value of data
        expect(@recur[attr], attr).to.equal value

  describe '#nextAt', ->
    it 'should return a moment object', ->
      expect moment.isMoment @recur.nextAt()
      .to.equal true

    it 'should return the last day the previous month is larger', ->
      @recur.set
        measure: 'month'
        units: 1
        start: '3000-01-31'

      expect @recur.nextAt().date()
      .to.equal 28

    it 'should return the last day when the previous month is larger', ->
      @recur.set
        measure: 'month'
        units: 1
        start: '3000-05-31'

      expect @recur.nextAt().format @format
      .to.equal '3000-06-30'

    it 'every 4 days', ->
      @recur.set
        units: 4
        measure: 'day'
        start: '3000-04-04'

      next = @recur.nextAt()

      expect next.format @format
      .to.equal '3000-04-08'

    it 'every 3 weeks', ->
      @recur.set
        units: 3
        measure: 'week'
        start: @date

      expect @recur.nextAt().format @format
      .to.equal '3000-01-22'

    it 'every 5 months', ->
      @recur.set
        units: 5
        measure: 'month'
        start: @date

      next = @recur.nextAt()

      expect next.format @format
      .to.equal '3000-06-01'

    it 'every 2 weeks on Monday', ->
      @recur.set
        units: 2
        measure: 'week'
        start: moment(@date).day(1)

      next = @recur.nextAt()

      expect next.format @format
      .to.equal '3000-01-13'

      expect next.format 'dddd'
      .to.equal 'Monday'

      next = @recur.nextAt(2)

      expect next.format @format
      .to.equal '3000-01-27'

    it 'every 3 months on the 15th', ->
      @recur.set
        units: 3
        measure: 'month'
        start: moment(@date).date(15)

      expect @recur.nextAt(0).format @format
      .to.equal '3000-01-15'

      expect @recur.nextAt(1).format @format
      .to.equal '3000-04-15'

    describe 'with from date', ->
      it 'should be able to suspend a single month', ->
        @recur.set
          measure: 'month'
          units: 1
          start: '3000-11-30'
          from: '3000-12-31'

        expect @recur.nextAt(0).format @format
        .to.equal '3001-01-30'

      it 'should be able to suspend months', ->
        @recur.set
          measure: 'month'
          units: 2
          start: '2999-01-01'
          from: '3000-04-15'

        expect @recur.nextAt(0).format @format
        .to.equal '3000-05-01'

      it 'should be able to suspend weeks', ->
        @recur.set
          measure: 'week'
          units: 2
          start: '2000-01-01'
          from: '3000-02-02'

        expect @recur.nextAt(0).format @format
        .to.equal '3000-02-15'

    describe 'with end date', ->
      it 'should return the next date when before the end date', ->
        @recur.set
          measure: 'week'
          units: 1,
          end: moment().add(2, 'week')
        next = @recur.nextAt().format(@format)

        expectedNext = moment().add(1, 'week').format(@format);
        expect(next).to.equal(expectedNext);

      it 'should return the next date when on the end date', ->
        @recur.set
          measure: 'week'
          units: 2,
          end: moment().add(2, 'week')
        next = @recur.nextAt().format(@format)

        expectedNext = moment().add(2, 'weeks').format(@format);
        expect(next).to.equal(expectedNext);
      it 'should return null when the next date would be after the end date', ->
        @recur.set
          measure: 'week'
          units: 3,
          end: moment().add(2, 'week')
        nextMoment = @recur.nextAt()

        expect(nextMoment).to.equal(null);

  describe '#matches', ->
    it 'should match next month', ->
      @recur.set start: @date

      feb1 = new Date 3000, 1, 1
      expect @recur.matches(feb1), '1 Feb'
      .to.equal true

      feb2 = new Date 3000, 1, 2

      expect @recur.matches(feb2), '2 Feb'
      .to.equal false

    it 'should match next 2 weeks', ->
      @recur.set
        start: @date
        measure: 'week'
        unit: 2

      after2weeks = moment(@date).add 2, 'weeks'
      expect @recur.matches(after2weeks)
      .to.equal true

      expect @recur.matches after2weeks.add(1, 'day')
      .to.equal false

    it 'should match the last day when the previous month is larger', ->
      @recur.set
        measure: 'month'
        units: 3
        start: '3000-01-31'

      expect @recur.matches('3000-02-28'), "match 3000-02-28"
      .to.equal false

      expect @recur.matches('3000-04-29'), "match 3000-02-29"
      .to.equal false

      expect @recur.matches('3000-04-30'), "match 3000-05-30"
      .to.equal true

      expect @recur.matches('3000-07-31'), "match 3000-07-31"
      .to.equal true

      expect @recur.matches('3000-08-31'), "match 3000-08-31"
      .to.equal false

    it 'should not match a date which is before the from date', ->
      @recur.set
        measure: 'month'
        unit: 1
        start: '3000-01-01'
        from: '3000-03-01'

      expect @recur.matches('3000-02-01'), '1st of Februari'
      .to.equal false

    it 'should match a date which is before the end date', ->
      @recur.set
        measure: 'month'
        unit: 1
        start: '3000-02-01'
        end: '3000-04-01'
      
      expect @recur.matches('3000-03-01')
      .to.equal true

    it 'should match a date which is on the end date', ->
      @recur.set
        measure: 'month'
        unit: 1
        start: '3000-02-01'
        end: '3000-04-01'
      
      expect @recur.matches('3000-04-01')
      .to.equal true

    it 'should not match a date which is after the end date', ->
      @recur.set
        measure: 'month'
        unit: 1
        start: '3000-02-01'
        end: '3000-04-01'
      
      expect @recur.matches('3000-05-01')
      .to.equal false
      
    it 'should not always match last day of month', ->
      @recur.set
        measure: 'month'
        units: 1
        start: '3000-11-30'
        from: '3001-11-30'

      expect @recur.matches('3001-12-31'), "match 3001-12-31"
      .to.equal false

  describe '#getFromDateCorrection', ->
    it 'should add calculate the correction', ->
      @recur.set
        start: moment().format('YYYY-MM-DD')
        measure: 'day'
        units: 1
        from: moment().add(2,'days')

      expect @recur.getFromDateCorrection()
      .to.equal 2

  describe '#clone', ->
    it 'should have the same values as the original', ->
      @recur.set
        measure: 'year'
        units: 3

      clone = @recur.clone()
      attributes = [
        'units'
        'measure'
      ]

      for attr in attributes
        expect(clone[attr], attr).to.equal @recur[attr]

    it 'should be able to overrule original values', ->
      @recur.set
        units: 3
        measure: 'month'

      clone = @recur.clone
        measure: 'year'

      expect(clone.units).to.equal 3
      expect(clone.measure).to.equal 'year'
