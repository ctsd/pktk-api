class ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  def getUser
    id = params.require(:messenger_id)
    @user = User.find_by messenger_id: id
    if @user == nil
      render json: { message: "User not found", status: 404 }, status: 404
    else
      render json: @user, status: 200
    end
  end

  def createUser
    information = request.raw_post
    data_parsed = JSON.parse(information)
    json_params = ActionController::Parameters.new(data_parsed)

    prms = json_params.permit(:messenger_id, :name, :team, :lat, :long)

    @user = User.new(prms)

    if @user.save()
      render json: @user, status: 200
    else
      render json: { message: "User already exists with this messenger_id", status: 400 }, status: 400
    end
  end

  def postLocation
    information = request.raw_post
    data_parsed = JSON.parse(information)
    json_params = ActionController::Parameters.new(data_parsed)

    id = json_params.require(:messenger_id)

    @user = User.find_by messenger_id: id
    if @user == nil
      render json: { message: "User not found", status: 404 }, status: 404
    else

      prms = json_params.permit(:lat, :long)
      @user.update_attributes(prms)

      if @user.save()
        render json: @user, status: 200
      else
        render json: { message: "Failed updating", status: 400 }, status: 400
      end

    end
  end

  def postMessage

    information = request.raw_post
    data_parsed = JSON.parse(information)
    json_params = ActionController::Parameters.new(data_parsed)

    id = json_params.require(:messenger_id)

    @user = User.find_by messenger_id: id
    if @user == nil
      render json: { message: "User not found", status: 404 }, status: 404
    else

      @message = Message.new(json_params.permit(:text))
      @message.lat = @user.lat
      @message.long = @user.long
      @message.user_id = @user.id

      if @message.save()
        render json: @message, status: 200
      else
        render json: { message: "Failed", status: 400 }, status: 400
      end

    end
  end

  def switchPKTK

    information = request.raw_post
    data_parsed = JSON.parse(information)
    json_params = ActionController::Parameters.new(data_parsed)

    id = json_params.require(:messenger_id)

    @user = User.find_by messenger_id: id
    if @user == nil
      render json: { message: "User not found", status: 404 }, status: 404
    else

      @user.on = json_params.require(:status)

      if @user.save()
        render json: @user, status: 200
      else
        render json: { message: "Failed", status: 400 }, status: 400
      end

    end

  end


end
