require 'em-jack'
require 'json'

EM.run do
  conn = EMJack::Connection.new
  status = []

  conn.list do |tubes|
    tubes.each do |tube|
      status << tube
      puts "Reaping #{tube}"

      reaper = EMJack::Connection.new(tube: tube)
      ready = reaper.peek(:ready){
        reaper.each_job do |job|
          puts "Delete %s: %p" % [tube, job]
          job.delete

          jd = reaper.peek(:ready){|job|
            puts "Next job %s: %p" % [tube, job]
          }
          jd.errback{
            status.delete(tube)
            EM.stop if status.empty?
          }
        end
      }
      ready.errback{
        status.delete(tube)
        EM.stop if status.empty?
      }
    end
  end
end
