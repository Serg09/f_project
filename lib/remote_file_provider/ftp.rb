require 'net/ftp'

class Net::FTP
  def puttextcontent(content, remotefile, &block)
    storlines "STOR " + remotefile, content, &block
  end
end

module RemoteFileProvider
  class Ftp
    def initialize(url, username, password, options = {})
      options = options || {}
      @url = url
      @username = username
      @password = password
      @root_directories = (options[:root_directory] || "").split('/')
    end

    def send_file(local_file, remote_file_name, *directories)
      open do |ftp|
        directories.each{|d| ftp.chdir d}
        ftp.puttextcontent(local_file, remote_file_name)
      end
    end

    # Yields the files in the specified directory
    #
    # if the block returns true, it also deletes the file
    def get_and_delete_files(*directories)
      open do |ftp|
        directories.each{|d| ftp.chdir d}
        ftp.nlst.each do |filename|

          content = ""
          ftp.gettextfile(filename) do |line|
            content << line.rstrip
            content << "\r\n"
          end

          if yield content, filename
            ftp.delete filename
          end
        end
      end
    end

    private

    def open
      Net::FTP.open(@url, @username, @password) do |ftp|
        @root_directories.each{|d| ftp.chdir d}
        yield ftp
      end
    end
  end
end
