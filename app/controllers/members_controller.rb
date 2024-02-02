# app/controllers/members_controller.rb
class MembersController < ApplicationController
  before_action :set_member, only: [:show, :update, :destory]

  def index
    case params[:type]
    when nil
      render_members_by_role(nil)
    when "Doctor"
      render_members_by_role(1)
    when "Patient"
      render_members_by_role(2)
    else
      render json: { error: "Invalid type parameter" }, status: :unprocessable_entity
    end
  end

  def show
    if @member
      render json: { member: @member }, status: :ok
    else
      render json: { message: 'Member not found' }, status: :ok
    end
  end

  def create
    @member = Member.new(member_params)
    @member.age = calculate_age(params[:member][:dob])
    if @member.save
      render json: @member, status: :created
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  def update
    @member.age = calculate_age(params[:member][:dob])
    if @member.update(member_params)
      render json: {message: 'Member updated succesfully'}, status: :ok
    else
      render json: {message: 'Member not found'}
    end
  end

  def destory
    if @member
      @member.destory
      render json: {message: 'Member destoryed succesfully'}, status: :ok
    else
      render json: { message: 'Member not found' }, status: :not_found
    end
  end

  private

  def set_member
    @member = Member.find(params[:id])
  end

  def member_params
    params.require(:member).permit(:first_name, :last_name, :gender, :role, :avatar)
  end

  def render_members_by_role(role)
    if role.nil?
      @members = Member.all
    else
      @members = Member.where(role: role)
    end
    members_data = @members.map do |member|
      member_data = {
        id: member.id,
        first_name: member.first_name,
        last_name: member.last_name,
        gender: member.gender,
        age: member.age,
        role: member.role,
        avatar: member.avatar
      }  
      member_data
    end
  
    render json: { members: members_data }
  end

  def calculate_age(birth_year)
    dob = DateTime.parse(birth_year)
    current_date = Time.now
    current_date.year - dob.year
  end
end
