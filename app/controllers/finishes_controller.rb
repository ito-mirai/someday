class FinishesController < ApplicationController
  def create
    @finish = Finish.new
  end

  def destroy
  end
end
