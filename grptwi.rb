#!/usr/local/bin/ruby
# coding: utf-8

require 'mail'
require 'set'
require 'twitter'
require 'yaml'

$yml = YAML.load_file(File.dirname(__FILE__) + '/grptwi.yml')

OK_ADDRS     = $yml['ok_addrs']
NOTICE_ADDRS = $yml['notice_addrs']
FROM_ADDR    = $yml['from_addr']

FROM_REPLACE_STR   = '{from_address}'
TWEET_REPLACE_STR  = '{tweet}'
DEL_ID_REPLACE_STR = '{del_id}'

RETURN_SUBJECT = 'grptwiからのお知らせ'

RETURN_TEXT    = <<EOS
#{FROM_REPLACE_STR} さんからの投稿です。
Twitterへ次の文章を投稿しました。

#{TWEET_REPLACE_STR}

つぶやきを削除する場合は、このメールを「引用返信」してください。内容はそのままで構いません。

*** delete target {#{DEL_ID_REPLACE_STR}}. ***
EOS
DEL_ID_REGEXP  = /delete target {(.+?)}./
DELETED_TEXT   = <<EOS
次のつぶやきを削除しました。

#{TWEET_REPLACE_STR}

EOS

def get_body(m) 
    if m.multipart? then
        if m.text_part then
            return m.text_part.decoded
        elsif m.html_part then
            return m.html_part.decoded
        end
    else
        return m.body.decoded.encode("UTF-8", m.charset)
    end

    return nil
end

def send_email(addr, body)
    to_mail = Mail.new
    to_mail.from    = FROM_ADDR
    to_mail.to      = addr
    to_mail.subject = RETURN_SUBJECT
    to_mail.body    = body
    to_mail.charset = 'utf-8'
    to_mail.deliver
end

def send_notice_email(addr, body)
    send_addrs = Set.new NOTICE_ADDRS
    send_addrs.add(addr)
    send_addrs.each{ |to_address|
        send_email(to_address, body)
    }
end

def get_twitter_client
    client = Twitter::REST::Client.new do |config|
        config.consumer_key        = $yml['twitter_api_key']
        config.consumer_secret     = $yml['twitter_api_secret']
        config.access_token        = $yml['twitter_access_token']
        config.access_token_secret = $yml['twitter_access_token_secret']
    end
    return client
end

def send_tweet(client, tweet)
    response = client.update(tweet)
    return response.id
end

def get_tweet(client, id)
    response = client.status(id)
    return response.text
end

def delete_tweet(client, id)
    client.status_destroy(id)
end


mail = Mail.new(STDIN.read)

if OK_ADDRS.include?(mail.from.first) then
    body = get_body(mail)

    if body then
        if DEL_ID_REGEXP =~ body then
            # delete tweet
            del_id = body.match(DEL_ID_REGEXP)[1].to_i
            client = get_twitter_client
            tweet  = get_tweet(client, del_id)
            delete_tweet(client, del_id)

            send_text = DELETED_TEXT.sub(TWEET_REPLACE_STR, tweet)
            send_notice_email(mail.from.first, send_text)
        else
            # tweet
            client = get_twitter_client
            id     = send_tweet(client, body)

            # send notice mail
            send_text = RETURN_TEXT.sub(DEL_ID_REPLACE_STR, id.to_s).sub(TWEET_REPLACE_STR, body).sub(FROM_REPLACE_STR, mail.from.first)
            send_notice_email(mail.from.first, send_text)
        end
    end
else

end

