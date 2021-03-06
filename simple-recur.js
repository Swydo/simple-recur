// Generated by CoffeeScript 1.9.0
(function() {
  var DateString, Recur, moment;

  moment = this.moment || require('moment');

  DateString = function(date) {
    return moment(date).format('YYYY-MM-DD');
  };

  Recur = (function() {
    Recur.attributes = {
      units: Number,
      measure: String,
      start: DateString,
      end: DateString,
      from: DateString
    };

    function Recur(data) {
      if (data == null) {
        data = {};
      }
      this.set(data);
      this.setDefaults();
    }

    Recur.prototype.set = function(data) {
      var attr;
      if (data == null) {
        data = {};
      }
      for (attr in this.constructor.attributes) {
        if (data[attr] != null) {
          this[attr] = data[attr];
        }
      }
      return this;
    };

    Recur.prototype.setDefaults = function() {
      if (this.units == null) {
        this.units = 1;
      }
      if (this.measure == null) {
        this.measure = 'month';
      }
      return this.start != null ? this.start : this.start = moment();
    };

    Recur.prototype.next = function(begin, end) {
      var i, _i, _results;
      if (begin == null) {
        begin = 1;
      }
      if (!end) {
        end = begin;
        begin = 0;
      }
      _results = [];
      for (i = _i = begin; begin <= end ? _i < end : _i > end; i = begin <= end ? ++_i : --_i) {
        _results.push(this.nextAt(i));
      }
      return _results;
    };

    Recur.prototype.nextAt = function(count) {
      var correction, next;
      if (count == null) {
        count = 1;
      }
      correction = this.getFromDateCorrection();
      next = moment(this.start).startOf('day').add((count + correction) * this.units, this.measure);
      if (this.isAfterEndDate(next)) {
        return null;
      } else {
        return next;
      }
    };

    Recur.prototype.getFromDateCorrection = function() {
      var from, start;
      if (!this.from) {
        return 0;
      }
      if (moment(this.from).isBefore(this.start)) {
        return 0;
      }
      start = moment(this.start).startOf('day');
      from = moment(this.from).startOf('day');
      return Math.ceil(Math.abs(start.diff(from, this.measure, true)) / this.units);
    };

    Recur.prototype.matches = function(date) {
      var diff, start;
      if (this.isBeforeFromDate(date)) {
        return false;
      }
      if (this.isBeforeStartDate(date)) {
        return false;
      }
      if (this.isAfterEndDate(date)) {
        return false;
      }
      date = moment(date).startOf('day');
      start = moment(this.start).startOf('day');
      diff = start.diff(date, this.measure, true);
      if (diff % this.units === 0) {
        return true;
      }
      return Math.floor(diff) % this.units === 0 && this.isRecurringOnLastDayOfMonth(date);
    };

    Recur.prototype.isBeforeFromDate = function(date) {
      return this.from && moment(this.from).startOf('day').isAfter(date);
    };

    Recur.prototype.isBeforeStartDate = function(date) {
      return moment(this.start).startOf('day').isAfter(date);
    };

    Recur.prototype.isAfterEndDate = function(date) {
      var endOfEndDay;
      if (!this.end) {
        return false;
      }
      endOfEndDay = moment(this.end).endOf('day');
      return moment(date).isAfter(endOfEndDay);
    };

    Recur.prototype.isRecurringOnLastDayOfMonth = function(date) {
      var dateMonthEndDay, recurringMonthDay;
      if (this.measure !== 'month') {
        return false;
      }
      recurringMonthDay = moment(this.start).date();
      dateMonthEndDay = moment(date).endOf('month').date();
      return (recurringMonthDay > dateMonthEndDay) && moment(date).date() === dateMonthEndDay;
    };

    Recur.prototype.every = function(_at_units, _at_measure) {
      this.units = _at_units;
      this.measure = _at_measure;
      return this;
    };

    Recur.prototype.clone = function(data) {
      return new this.constructor(this).set(data);
    };

    Recur.prototype.toJSON = function() {
      var attr, json, type, _ref;
      json = {};
      _ref = this.constructor.attributes;
      for (attr in _ref) {
        type = _ref[attr];
        if (this[attr] != null) {
          json[attr] = type(this[attr]);
        }
      }
      delete json.from;
      return json;
    };

    return Recur;

  })();

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = Recur;
  } else {
    this.Recur = Recur;
  }

}).call(this);
