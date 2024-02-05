class OpportunitiesController < ApplicationController
  before_action :set_opportunity, only: [:show, :update, :destroy, :update_stage]
  
  def index
    @opportunities = Opportunity.includes(:patient, :doctor)
    opportunities = @opportunities.map do |opportunity|
      serailize_opportunity(opportunity)
    end
    render json: {opportunities: opportunities}, status: :ok
  end

  def show
    render json: @opportunity, status: :ok
  end

  def create
    @opportunity = Opportunity.new(opportunity_params)
    @opportunity.stage_history = { Lead: DateTime.now }
    if @opportunity.save
      render json: @opportunity, status: :created
    else
      render json: @opportunity.errors, status: :unprocessable_entity
    end
  end

  def update
    if @opportunity.update(opportunity_params)
      render json: @opportunity
    else
      render json: @opportunity.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @opportunity.destroy
    head :no_content
  end

  def update_stage
    if @opportunity
      case @opportunity.procedure_name
      when "Lead"
        update_opportunity_and_render('Qualified')
      when "Qualified"
        update_opportunity_and_render('Booked')
      when "Booked"
        update_opportunity_and_render('Treated')
      else
        render json: { errors: 'Stage skipped' }, status: :unprocessable_entity
      end
    end
  end

  def search_by_name_and_procedure
    if params[:search].present?
      @opportunities = Opportunity.search_by_name_and_procedure(params[:search])
      opportunities = @opportunities.map do |opportunity|
        serailize_opportunity(opportunity)
      end
      render json: {opportunities: opportunities}, status: :ok
    else
      render json: { message: 'No search term provided' }, status: :bad_request
    end
  end
  

  private

  def set_opportunity
    @opportunity = Opportunity.find(params[:id])
  end

  def opportunity_params
    params.require(:opportunity).permit(
      :procedure_name,
      :patient_id,
      :doctor_id,
      stage_history: [:Lead, :Qualified, :Booked, :Treated]
    )
  end  

  def serailize_opportunity(opportunity)
    {
      id: opportunity.id,
      procedure_name: opportunity.procedure_name,
      patient: opportunity.patient&.as_json(only: [:id, :first_name, :last_name, :age, :gender, :avatar]),
      doctor: opportunity.doctor&.as_json(only: [:id, :first_name, :last_name, :age, :gender, :avatar]),
      stage_history: opportunity.stage_history
    }
  end

  def update_opportunity_and_render(new_stage)
    @opportunity.procedure_name = new_stage
    @opportunity.stage_history[new_stage] = DateTime.now
    @opportunity.save
  
    render json: { opportunity: @opportunity }, status: :ok
  end
end
