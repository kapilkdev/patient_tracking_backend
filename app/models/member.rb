class Member < ApplicationRecord
  has_many :opportunities_as_patient, class_name: 'Opportunity', foreign_key: 'patient_id', dependent: :destroy
  has_many :opportunities_as_doctor, class_name: 'Opportunity', foreign_key: 'doctor_id', dependent: :destroy

  enum gender: { Male: 1, Female: 2 }
  enum role: { doctor: 1, patient: 2 }
end
