require 'digest/sha1'

module Dokuwiki
  extend self
  
  USERS_FILE = "path/to/conf/users.auth.php"  
  
  class Error < ::StandardError
    #TODO: error handling
  end
  
  def add_user(username, password, real_name, email, groups = "user")
    unless user_exists?(username)
      injected = "#{username}:#{Digest::SHA1.hexdigest(password)}:#{real_name}:#{email}:#{groups}\n"
      fout = File.open(USERS_FILE, "a")
      fout.puts injected
      fout.close
    end
  end
  
  def delete_user!(username)
    file = File.new(USERS_FILE)
    lines = file.readlines
    file.close

    changes = false
    lines.each do |line|
      changes = true if line.gsub!(/^#{username}:.*\n/i, '')
    end

    # Don't write the file if there are no changes
    if changes
      file = File.new(USERS_FILE,'w')
      lines.each do |line|
        file.write(line)
      end
      file.close
    end
  end
  
  def user_exists?(username)
    false
    File.open(USERS_FILE, "r") do |f|
      while (line = f.gets)
        return true if line.split(":")[0]==username && line.length > 10
      end
    end
  end
end

if __FILE__ == $0
  require "test/unit"
  
  class Dokuwiki < Test::Unit::TestCase
    def test_dokuwiki
      #TODO: write tests, although they would only depend on regular expressions and File
      # Tested successfully in production 
    end
  end
end

#Dokuwiki.add_user("jonny", "secret", "Jonny Kula", "jonny@kula.se")
#Dokuwiki.delete_user!("jonny")
#Dokuwiki.user_exists?("jonny")