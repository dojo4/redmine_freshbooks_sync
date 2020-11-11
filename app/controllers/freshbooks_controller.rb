class FreshbooksController < FreshbooksBaseController
  def redirect
    code = params[:code]
    @freshbooks_client.store_token_for(code)
    render :show
  end

  def authorize
    redirect_to @freshbooks_client.authorize_url
  end

  def show
    @business = @freshbooks_client.owner_businesses.first
  end
end
