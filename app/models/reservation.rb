class ResValidator < ActiveModel::Validator
  def validate(record)
    if record.guest == record.listing.host
      record.errors[:guest] << "Hosts cannot reserve their own listing!"
    end


    i = record.checkin
    o = record.checkout
    unless i.nil? || o.nil?
      record.errors[:checkin] << "Check-in cannot be on or before check-out!" if i >= o

      Reservation.all.each { |res|
        if res.checkin.between?(i, o) || res.checkout.between?(i, o) || (res.checkin < i && res.checkout > o)
          record.errors[:checkin] << "Dates not available!"
          #binding.pry
        end
      }
    end
  end
end


class Reservation < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :listing
  belongs_to :guest, :class_name => "User"

  has_one :review

  validates :checkin, :checkout, presence: true
  validate :available, :checkout_after_checkin, :guest_and_host_not_the_same

  def duration
    (checkout - checkin).to_i
  end

  def total_price
    listing.price * duration
  end

  private


  def available
    Reservation.where(listing_id: listing.id).where.not(id: id).each do |r|
      booked_dates = r.checkin..r.checkout
      if booked_dates === checkin || booked_dates === checkout
        errors.add(:guest_id, "Sorry, this place isn't available during your requested dates.")
      end
    end
  end

  def guest_and_host_not_the_same
    if guest_id == listing.host_id
      errors.add(:guest_id, "You can't book your own apartment.")
    end
  end

  def checkout_after_checkin
    if checkout && checkin && checkout <= checkin
      errors.add(:guest_id, "Your check-out date needs to be after your check-in.")
    end
  end
end