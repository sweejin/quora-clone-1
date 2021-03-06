class CommentsController < ApplicationController
	def create
		@comment = current_user.answers.build(params[:comment])
		@comment.save!
    activity = @comment.create_activity :create, owner: current_user
    Notification.create!(
      { activity_id: activity.id, user_id: @comment.question.asker_id }
    )

    render :json => @comment.as_json(:include => [:answerer, :votes])
	end

	def destroy
		@comment = Comment.find(params[:id])
		@comment.destroy

    @activities = PublicActivity::Activity.where("trackable_type = ?
      AND trackable_id = ?", "Comment", params[:id])
    @activities.each(&:destroy)

		render :json => @comment
	end
end
