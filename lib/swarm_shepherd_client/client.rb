class Client
  include Common

  def initialize
    handshake
  rescue => ex
    p ex
  end

  def handshake
    create_io('engines-out', 'engines-in') do |ein, eout|
      id = SecureRandom.hex
      eout.jput(client_add: id)

      ein.reserve do |job|
        begin
          body = job.jbody

          if handshake = body['handshake']
            # we got all we need, get outta here.
            job.delete{|id|
              ein.close_connection
              eout.close_connection
            }

            @clientid = handshake['clientid']

            create_io(*handshake.values_at('in', 'out')){|cin,cout|
              @in, @out = cin, cout
              @in.each_job(&method(:got_job))
              main
            }
          else
            job.put_back
            job.delete
          end
        rescue => ex
          p ex
        end
      end
    end
  end

  def main
    @out.jput(command: 'select_home')
  end

  def got_job(job)
    p client_got_job: job.jbody.map{|marshal| Marshal.load(marshal) }
  end
end
