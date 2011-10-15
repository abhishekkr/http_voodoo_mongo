#!/usr/bin/env ruby

require 'socket'

class WebPages
  def home
    <<-HOME_HTML
         <html>
           <head>
           </head>
           <body>
             <div style="text-align:center">
               <b>HTTP Voodoo MongoDB</b>
               <br/><br/><br/>
               control your remote/local MongoDB instances over HTTP
             </div>
           </body>
         </html>
    HOME_HTML
  end

  def err404
    <<-ERR404_HTML
         <html>
           <head>
           </head>
           <body>
             <div style="text-align:center">
               <b>HTTP Voodoo MongoDB</b>
               <br/><br/><br/>
               Can't understand what to do with your request.
             </div>
           </body>
         </html>
    ERR404_HTML
  end
end

class MongoRESPONSE
  def initialize(session,result)
    @session = session
    @result = result
  end

  def serve_200(content)
    @session.print "HTTP/1.1 200/OK\r\nContent-type:text/html\r\n\r\n"
    @session.print content
  end

  def serve_404(content=nil)
    content ||= "Request can't be Served"
    @session.print "HTTP/1.1 404/ Not Found\r\nContent-type:text/html\r\n\r\n"
    @session.print content
  end

  def send
    begin
      action_status = @result.split[-1].to_i
      content = @result.split[0..-2].join(" ")
      if action_status == 0
        serve_200 content
      else
        serve_404 content
      end
    rescue
      serve_404 "Code Exception error raised"
    end
  end
end

class MongoREQUEST
  def initialize(session, request)
    @session = session
    @request = request
  end

  def get_db
    @db=@request.split("/")[0].split("?")[0]
  end

  def get_collection
    @collection=@request.split("/")[1].split("?")[0]
  end

  def get_request_params
    credentials=@request.split("?")[1]
    @authentication=username=password=""
    unless credentials.nil?
      credentials.split("&").each do |creds|
        if creds.split("=")[0]=="username" then
          username=creds.split("=")[1]
        elsif creds.split("=")[0]=="password" then
          password=creds.split("=")[1]
        elsif creds.split("=")[0]=="port" then
          @port=creds.split("=")[1]
        elsif creds.split("=")[0]=="dir" then
          @dir=creds.split("=")[1]
        elsif creds.split("=")[0]=="action" then
          @action=creds.split("=")[1]
        elsif creds.split("=")[0]=="more_switch" then
          @more_switch=creds.split("=")[1]
        end
      end
    end
    unless username==""
      @authentication="--username=#{username} --password=#{password}"
    end
    @dir ||= "/var/backups/mongodb/migration_backup"
    @port ||= "27017"
    @more_switch ||= ""
  end

  def service_logic
    begin
      return WebPages.new.home if @request===""
      get_db
      get_request_params
      result = case @action
      when "mongodump"
        result = %x{mongodump --host=localhost:#{@port} --db=#{@db} #{@authentication} --out=#{@dir} #{@more_switch}; echo $? }
      else
        WebPages.new.err404 + "404"
      end
      result
    rescue
      "Service raised some exception."
    end
  end
end

class HTTP_Voodoo
  def initialize(ip_address, port)
    @ip_address=ip_address
    @port=port
  end

  def Mongo
    begin
      webserver = TCPServer.new(@ip_address, @port)
      puts "MongoREST Server has been started at port 30303"
      while (session = webserver.accept)
        request = session.gets
        Thread.start(session, request) do |session, request|
          trimmedrequest = request.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '')
          request = trimmedrequest.chomp
          result = MongoREQUEST.new(session,request).service_logic()
          MongoRESPONSE.new(session,result).send()
          session.close
        end
      end
    rescue
      puts "MongoREST Server failed."
    end
  end
end


HTTP_Voodoo.new('0.0.0.0', 30303).Mongo
