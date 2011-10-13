#!/usr/bin/env ruby

namespace "http_mongo" do

  task "copy_mongo_voodoo" do
    Dir.mkdir "/etc/http_voodoo_mongo"
    f_in=File.open("mongo_voodoo.rb","r") 
    f_out=File.open("/etc/http_voodoo_mongo/mongo_voodoo.rb","w") 
    f_out.write f_in.read
    f_in.close
    f_out.close
  end

  task "copy_mongo_voodoo_service" do
    f_in=File.open("mongo_voodoo","r") 
    f_out=File.open("/etc/init.d/mongo_voodoo","w") 
    f_out.write f_in.read
    f_in.close
    f_out.close
  end

  desc "install http_voodoo_mongo as system service"
  task "install" do
    Rake::Task["http_mongo:copy_mongo_voodoo"].invoke
    Rake::Task["http_mongo:copy_mongo_voodoo_service"].invoke
    %x{/etc/init.d/mongo_voodoo start}
  end

end
