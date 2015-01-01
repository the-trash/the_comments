json.comment render(partial: comment_template('comment.html'), locals: { tree: @comment })
json.comments_sum @commentable.reload.comments_sum
