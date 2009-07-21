require 'digest/sha1'

class Dokuwiki  
  def initialize(users_auth_php = "path/to/conf/users.auth.php")
    @users_file = users_auth_php
    File.open(@users_file, 'w') unless File.exist?(@users_file)
  end
  
  class Error < ::StandardError
    #TODO: error handling
  end
  
  def add_user(username, params)
    unless user_exists?(username)
      group = "user" || params[:groups]
      injected = "#{username}:#{Digest::SHA1.hexdigest(params[:password])}:#{params[:name]}:#{params[:email]}:#{group}\n"
      fout = File.open(@users_file, "a")
      fout.puts injected
      fout.close
      true
    else
      false
    end
  end
  
  def delete_user!(username)
    file = File.new(@users_file)
    lines = file.readlines
    file.close

    changes = false
    lines.each do |line|
      changes = true if line.gsub!(/^#{username}:.*\n/i, '')
    end

    # Don't write the file if there are no changes
    if changes
      file = File.new(@users_file,'w')
      lines.each do |line|
        file.write(line)
      end
      file.close
    end
    changes
  end
  
  def user_exists?(username)
    File.open(@users_file, "r") do |f|
      while (line = f.gets)
        return true if line.split(":")[0]==username && line.length > 10
      end
    end
    false
  end
end

if __FILE__ == $0
  require "test/unit"
  require 'fileutils'
  
  class DokuwikiTest < Test::Unit::TestCase
    def setup
      @tmpfile = "/Users/jonas/Desktop/iwiki/conf/users.auth.txt"
      @d = Dokuwiki.new(@tmpfile)      
      @user1 = ['jonny', {:password => "jonas", :email => "jonny", :name => "jonny banan"}]
    end

    def clear_tmpfile
      FileUtils.rm(@tmpfile)
      File.open(@tmpfile, 'w')
    end
    
    def test_adding_user
      assert_equal(true, @d.add_user(@user1[0], @user1[1]))
      clear_tmpfile
    end
    
    def test_exist
      @d.add_user(@user1[0], @user1[1])
      assert_equal(true, @d.user_exists?(@user1[0]))
      clear_tmpfile
    end
    
    def test_nonexistent_user    
      assert_equal(false, @d.user_exists?(@user1[0]))
      clear_tmpfile
    end    
    
    def test_deleting_nonexisting_user
      assert_equal(false, @d.delete_user!(@user1[0]))
      clear_tmpfile      
    end
    
    def test_deleting_existing_user
      @d.add_user(@user1[0], @user1[1])
      assert_equal(true, @d.delete_user!(@user1[0]))
      clear_tmpfile
    end

  end
end

# @d = Dokuwiki.new() #path to users.auth.php single argument optional
# @d.add_user("jonny", "secret", "Jonny Kula", "jonny@kula.se") #=> true/false
# @d.delete_user!("jonny") #=> true/false
# @d.user_exists?("jonny") #=> true/false