class Opportunity < ApplicationRecord
  include PgSearch::Model

  validates :patient_id, :doctor_id, presence: true

  validate :validate_member_role
  
  belongs_to :patient, class_name: 'Member', foreign_key: 'patient_id'
  belongs_to :doctor, class_name: 'Member', foreign_key: 'doctor_id'

  pg_search_scope :search_by_name_and_procedure,
                  against: [:procedure_name],
                  associated_against: {
                    doctor: [:first_name, :last_name],
                    patient: [:first_name, :last_name]
                  },
                  using: {
                    tsearch: { prefix: true }
                  }
  private

  def validate_member_role
    doctor = Member.find_by(id: doctor_id)
    patient = Member.find_by(id: patient_id)
    if doctor && patient
      if patient_id.present? && patient.role != 'patient'
        errors.add(:patient_id, 'should have pateint role')
      elsif doctor_id.present? && doctor.role != 'doctor'
        errors.add(:doctor_id, 'should have doctor')
      end
    end
  end
end
