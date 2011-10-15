#!/usr/bin/env ruby

namespace "http_mongo" do

  task "copy_mongo_voodoo" do
    Dir.mkdir "/etc/http_voodoo_mongo" unless File.exists? "/etc/http_voodoo_mongo"
    f_in=File.open("mongo_voodoo.rb","r") 
    f_out=File.open("/etc/http_voodoo_mongo/mongo_voodoo.rb","w") 
    f_out.write f_in.read
    f_in.close
    f_out.close
    status=%x{sudo chmod +x /etc/http_voodoo_mongo/mongo_voodoo.rb}.split[-1].to_i
    if status==0
      "Success: HTTP Voodoo MongoDB has been installed"
    else
      "Problem in installing HTTP Voodoo MongoDB"
    end
  end

  task "copy_mongo_voodoo_service" do
    f_in=File.open("mongo_voodoo","r") 
    f_out=File.open("/etc/init.d/mongo_voodoo","w") 
    f_out.write f_in.read
    f_in.close
    f_out.close
    status=%x{sudo chmod +x /etc/init.d/mongo_voodoo}.split[-1].to_i
    if status==0
      "Success: HTTP Voodoo MongoDB System Service has been installed"
    else
      "Problem in copying HTTP Voodoo MongoDB System Service"
    end
  end

  desc "install http_voodoo_mongo as system service"
  task "install" do
    Rake::Task["http_mongo:copy_mongo_voodoo"].invoke
    Rake::Task["http_mongo:copy_mongo_voodoo_service"].invoke
    status=%x{sudo /etc/init.d/mongo_voodoo start; echo $?}.split[-1].to_i
    if status==0
      "Success: HTTP Voodoo MongoDB Service has been installed & started"
    else
      "Problem in starting HTTP Voodoo MongoDB Service"
    end
  end

end
