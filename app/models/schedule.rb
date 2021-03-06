require 'nokogiri'
include ActionView::Helpers::NumberHelper
class Schedule < ActiveRecord::Base
  DAYS = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
  APPROVED_CLASSES = %w(sculpt iyoga stretch & abs pilates mat zumba
  pilates yoga abs bodysculpt core fluidity melt pilates mat boot
  assets dance barre vinyasa)
  APPROVED_LOCATIONS = %w(23rd 13th 21st astor cooper)

  serialize :schedule_data
  attr_accessor :html

  def html=(html)
    @html = html
    schedule_hash = {}
    DAYS.each do |day|
      schedule_hash[day] =self.approved_classes(day)
    end
    self.schedule_data = schedule_hash
  end

  def tables
    page = Nokogiri::HTML.parse(html)
    tables = []
    page.css("table").each do |t|
      if DAYS.include?(t.css('caption').text)
        tables << t
      end
    end
    tables
  end

  def table_for(weekday)
    tables.each do |t|
      if t.css('caption').text == weekday
        return t
      end
    end
  end

  def approved_classes(weekday)
    table = table_for(weekday)
    klasses = []
    i = 0
    table.css('tr').each do |row|
      class_location = row.css('.views-field-field-class-location')[0].text
      APPROVED_LOCATIONS.each do |approved_location|
        if class_location.downcase.match(approved_location)
          class_title = row.css("td.views-field-field-class-title")[0].text
          APPROVED_CLASSES.each do |approved_class|
            if class_title.downcase.match(approved_class)
              class_end = class_end_string( row.css('.views-field-field-class-end-time')[0].text)
              class_start = class_start_string(row.css('.views-field-field-class-start-time')[0].text)
              i += 1
              klasses << Hashie::Mash.new(
                title: class_title.gsub("\n", "").strip,
                location: class_location.gsub("\n", "").strip,
                start_time: class_start.gsub("\n", "").strip,
                end_time: class_end.gsub("\n", "").strip,
                instructor: row.css('.views-field-field-class-instructor')[0].text.gsub("\n", "").strip,
                id: i
              )
              break
            end
          end
          break
        end
      end
    end
    klasses
  end

  def class_end_string(original_end)
    class_end_int = original_end.gsub(/\D+/, '').to_i
    if class_end_int < 1200
      class_end = "#{original_end.gsub(" ", "")} am"
    elsif class_end_int < 1300
      class_end = "#{original_end.gsub(" ", "")} pm"
    else
      class_end = "#{number_with_precision(((class_end_int - 1200)/100.0), precision: 2)} pm".gsub('.', ':')
    end
  end

  def class_start_string(original_start)
    class_start_int = original_start.gsub(/\D+/, '').to_i
    if class_start_int < 1200
      class_start = original_start.gsub(/-/, 'am')
    elsif class_start_int < 1300
      class_start = original_start.gsub(/-/, 'pm')
    else
      class_start = "#{number_with_precision(((class_start_int - 1200)/100.0), precision: 2)} pm".gsub('.', ':')
    end

    class_start
  end

  def as_json
    schedule= []
    DAYS.each do |day|
      day_hash = {}
      klasses = []
      approved_classes(day).each do |approved_class|
        klasses << approved_class.to_hash
      end
      day_hash = {"day" => day, "classes" => klasses}
      schedule << day_hash
    end
    { schedule: schedule }
  end
end
