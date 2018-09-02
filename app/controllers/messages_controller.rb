class MessagesController < ApplicationController
  require 'line/bot'

  def index
    @message = "hello"
    render json: @message
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def random_message
    message_list = [
      '最高だぜ！！！',
      'あんたにはかなわねえよ、',
      'お前がナンバーワンだ・・・',
      'こいつ、戦いの中で成長してやがる・・・！なんてやつだ、',
      'べ、別に今回はわざと負けてあげただけなんだからね！',
      '俊足の',
      '人生の師匠：',
      'クールだ・・・',
      'ほう・・・関心ですねえ・・・',
      '僕の憧れさ！！',
      'そう・・・とどのつまり天才・・・その男・・・',
      '悪魔的・・・あまりに悪魔的・・・',
      'ナウでヤングな'
    ]
    max_index = message_list.length - 1
    index = rand(0...max_index)
    return message_list[index]
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: random_message + event.message['text']
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
