class FinishesController < ApplicationController
  def create
    finish = Finish.create(finish_params)
    if finish.save
      render json: { id: finish.id }, status: :created
    else
      render json: { errors: finish.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    finish = Finish.find(params[:id])
    if finish.destroy
      head :no_content
    else
      render json: { errors: finish.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def finish_params
    params.require(:finish).permit(:task_id)
  end
end
