require 'net/http'
require 'nokogiri'
require 'open-uri'
class ScheduleController < ApplicationController

  APPROVED_CLASSES = %w(
  Sculpt
  IYoga
  Stretch & Abs
  Pilates Mat
  Zumba
  Pilates
  Yoga
  Abs
  BodySculpt
  Core
  Fluidity
  Melt
  Pilates Mat
  Boot
  Assets
  Dance
  Barre
  )
  def index
    @page = Nokogiri::HTML(open('http://nyhrc.com/find-class-instructor?field_class_location_id_value=All&field_class_category_value=All&field_class_instructor_value_selective=All&field_class_title_value_selective=All'))
    @approved_classes = APPROVED_CLASSES
    @approved_locations = %w(23rd 13th 21st Astor)

  end
end
