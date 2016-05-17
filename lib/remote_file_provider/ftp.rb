require 'net/ftp'

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
        ftp.puttextfile(local_file, remote_file_name)
      end
    end

    # Yields the files in the specified directory
    #
    # if the block returns true, it also deletes the file
    def get_and_delete_files(directory = nil)
      Net::FTP.open(@url, @username, @password) do |ftp|
        ftp.chdir(directory) if directory
        ftp.list.each do |filename|
          if yield ftp.gettextfile(filename)
            ftp.delete filename
          end
        end
      end
    end
  end
end
