class QuestionsController < ApplicationController
	def new
		@question = Question.new
	end

	def create
		@question = current_user.questions.build(params[:question])
		@question.save!
    if params[:topic_id]
      @rel = QuestionTopicRelationship.new(
        :topic_id => params[:topic_id],
        :question_id => @question.id)
      @rel.save!
      @rel.create_activity :create, owner: @question
    end
    @question.create_activity :create, owner: current_user


		redirect_to question_url(@question)
	end

  def update
    @question = Question.find(params[:id])
    @question.update_attributes!(params[:question])

    render :json => @question
  end

	def index
    @questions = Question
      .order("created_at DESC")
      .paginate(:page => params[:page], :per_page => 5)

    respond_to do |format|
      format.html
      format.json { render :json => questions.as_json(:includes => [:asker]) }
    end
	end

	def unanswered
		@questions = Question.recent_unanswered_questions
	end

	def show
		@question = Question.includes(:answers, :topics).find(params[:id])
		@comment = Comment.new
		@vote = Vote.new
    @rel = FollowQuestionRelationship.new
    @qtr = QuestionTopicRelationship.new
	end

  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    @activities = PublicActivity::Activity.where("trackable_type = ?
      AND trackable_id = ?", "Question", params[:id])
    @activities.each(&:destroy)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { render :json => @question }
    end
  end
end
