class EMJack::Job
  def jbody
    JSON.parse(body)
  end

  def put_back
    conn.put(body)
  end
end

class Connection < EMJack::Connection
  def inspect
    "#<Connection " <<
    [:used_tube, :watched_tubes].map{|k|
      "%s=%p" % [k, instance_variable_get("@#{k}")]
    }.join(', ') <<
    ">"
  end

  def jput(message, &block)
    p self => message
    put(message.to_json, &block)
  end

  def close_connection
    @conn.close_connection
  end
end

module Common
  def create_io(in_tube, out_tube)
    waiting = {in: nil, out: nil}
    in_conn = out_conn = nil

    done = lambda{|name|
      waiting[name] = true
      yield(in_conn, out_conn) if block_given? && waiting.values.all?
    }

    in_conn = conn_to(in_tube){ done[:in] }
    out_conn = conn_to(out_tube){ done[:out] }

    return in_conn, out_conn
  end

  def conn_to(tube)
    conn = Connection.new # (tube: tube)
    waiting = {use: nil, watch: nil, ignore: nil}
    done = lambda{|name|
      waiting[name] = true
      yield if block_given? && waiting.values.all?
    }

    conn.use(tube){ done[:use] }
    conn.watch(tube){ done[:watch] }
    conn.ignore('default'){ done[:ignore] }
    conn
  end
end
