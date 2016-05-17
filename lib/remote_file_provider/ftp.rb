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
  end
end
