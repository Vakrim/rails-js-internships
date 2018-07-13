class AuthorsController < ApplicationController

  def index
    @authors = Author.all
    @author = Author.new
  end

  def show
    @author = Author.find(params[:id])
    @posts = @author.posts
  end

  def new
    @author = Author.new
  end

  def create
    @author = Author.create(author_params)
  end

  def edit
    @author = Author.find(params[:id])
  end

  def update
    @author = Author.find(params[:id])
    if @author.update(author_params)
      redirect_to authors_url, notice: 'Author has been updated'
    else
      render :edit
    end
  end

  def destroy
    @author = Author.find(params[:id])
    @author.destroy
  end

  private

    def author_params
      params.require(:author).permit(:name, :surname, :age)
    end

end
