class WebhookController < ApplicationController
  protect_from_forgery :except => [:callback]

  require 'line/bot'
  require 'net/http'

  def client
    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV['CHANNEL_SECRET']
      config.channel_token = ENV['CHANNEL_ACCESS_TOKEN']
    }
  end

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    event = params["events"][0]
    event_type = event["type"]

    input_text = event["message"]["text"]

    events = client.parse_events_from(body)
    events.each { |event|
      case event
        when Line::Bot::Event::Message
          case event.type
            when Line::Bot::Event::MessageType::Text
               message = {
                    type: 'text',
                    text: input_text
                    }
            when Line::Bot::Event::MessageType::Image
              image_url = "https://avatars7.githubusercontent.com/u/16996739"
                message = {
                    type: "image",
                    originalContentUrl: image_url,
                    previewImageUrl: image_url
                    }
           end
           client.reply_message(event['replyToken'],message)
      end
    }
  end
end
