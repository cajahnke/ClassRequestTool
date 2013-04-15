class AssessmentsController < ApplicationController
  
  def index
    @assessments = Assessment.find(:all, :order => :name)
  end  
  
  def new
    @assessment = Assessment.new
    @course = Course.find(params[:course_id])
  end
  
  def edit
    @assessment = Assessment.find(params[:id])
  end
  
  def create
    @assessment = Assessment.new(params[:assessment])
    @assessment.course = Course.find(params[:course_id])
    respond_to do |format|
      if @assessment.save
        format.html { redirect_to course_url(@assessment.course), notice: 'assessment was successfully created.' }
        format.json { render json: @assessment, status: :created, assessment: @assessment }
      else
        format.html { render action: "new" }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @assessment = Assessment.find(params[:id])

    respond_to do |format|
      if @assessment.update_attributes(params[:assessment])
        format.html { redirect_to assessments_url, notice: 'assessment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @assessment = Assessment.find(params[:id])
    @assessment.destroy

    respond_to do |format|
      format.html { redirect_to assessments_url }
      format.json { head :no_content }
    end
  end
end
