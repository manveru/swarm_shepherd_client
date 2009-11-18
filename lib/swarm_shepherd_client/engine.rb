class Engine
  include Common

  def initialize
    @client_uuid = 0
    @clients_out = {}
    @clients_in = {}

    create_io('engines-in', 'engines-out'){|ein, eout|
      @in, @out = ein, eout
      mainloop
    }
  rescue => ex
    p ex
  end

  def mainloop
    @in.each_job do |job|
      begin
        on_job(job)
      rescue => ex
        p ex
      ensure
        job.delete
      end
    end
  end

  def on_job(job)
    body = job.jbody
    p engine_on_job: body

    if client_id = body['client_add']
      client_add(client_id)
    elsif client_id = body['client_del']
      client_del(client_id)
    end
  end

  def client_del(client_id)
    client_in  = "client-#{client_id}-in"
    @clients_in[client_in].close_connection
    @clients_in[client_in] = nil

    client_out = "client-#{client_id}-out"
    @clients_out[client_out].close_connection
    @clients_out[client_out] = nil
  end

  # TODO: eventually the clients will need to have an API key so we can track
  #       them and control privileges.
  def client_add(given_id)
    # FIXME: so low only to make debugging output nicer
    client_id  = SecureRandom.hex(4)
    client_in  = "client-#{client_id}-in"
    client_out = "client-#{client_id}-out"

    @out.jput(handshake: {
      id: given_id, client_id: client_id, in: client_in, out: client_out }
    )

    create_io(client_in, client_out){|tube_in, tube_out|
      @clients_in[client_in] = tube_in
      @clients_out[client_out] = tube_out

      tube_out.each_job do |job|
        tube_in.put "Echo to #{client_id}: #{job.id}"
      end
    }

    @client_uuid += 1
  rescue => ex
    p ex
  end
end
