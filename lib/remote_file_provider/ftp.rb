require 'net/ftp'

class Net::FTP
  def puttextcontent(content, remotefile, &block)
    storlines "STOR " + remotefile, content, &block
  end
end

module RemoteFileProvider
  class Ftp
    def initialize(url, username, password)
      @url = url
      @username = username
      @password = password
    end

    def send_file(local_file, remote_file_name, directory = nil)
      Net::FTP.open(@url, @username, @password) do |ftp|
        ftp.chdir(directory) if directory
        ftp.puttextcontent(local_file, remote_file_name)
      end
    end

    # Yields the files in the specified directory
    #
    # if the block returns true, it also deletes the file
    def get_and_delete_files(directory = nil)
      Net::FTP.open(@url, @username, @password) do |ftp|
        ftp.chdir(directory) if directory
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
  end
end
