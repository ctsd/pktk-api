class ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  before_action :require_token

  def require_token
    unless params.require('verify_token') == "__INSERT_VERIFY_TOKEN__"
      render json: "Forbidden", status: 401
      exit
    end
  end

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

    prms = json_params.permit(:messenger_id, :name, :team, :lat, :lng)

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

      prms = json_params.permit(:lat, :lng)
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
    elsif @user.on == false
      render json: { message: "PKTK not switched on", status: 402 }, status: 402
    else

      @message = Message.new(json_params.permit(:text))
      @message.lat = @user.lat
      @message.long = @user.lng
      @message.user_id = @user.id

      if @message.save()

        users = User.within(0.5, :origin => @user).where(on: true).where.not(id: @user.id)

        users.each do |u|
          data = {
            recipient: {
              id: u.messenger_id
            },
            message: {
            	text: @user.name + ": " + @message.text
            }
          }
          uri = URI.parse('https://graph.facebook.com/v2.6/me/messages?access_token=__INSERT_ACCESS_TOKEN__')
          # x = Net::HTTP.post_form(uri, data)
          req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
          req.body = data.to_json
          res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http| http.request req}
          puts res.body
          puts u.messenger_id
          puts data.to_json

        end

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
        users_zone = User.within(0.5, :origin => @user).where.not(id: @user.id).length
        users_online = User.within(0.5, :origin => @user).where(on: true).where.not(id: @user.id).length
        render json: { user: @user, zone: { online: users_online, all: users_zone } }, status: 200
      else
        render json: { message: "Failed", status: 400 }, status: 400
      end

    end

  end


end
