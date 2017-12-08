module Schedule::Job
  JOBS  = Set(String).new
  MUTEX = Mutex.new

  # Run an identified job only once
  #
  # Example:
  # ```
  # Schedule::Job.run("job-1") do
  #   puts "hello"
  #   sleep 1
  # end
  #
  # Schedule::Job.run("job-1") do
  #   puts "hello"
  #   sleep 1
  # end
  # => Runs only the first time
  # ```
  #
  def self.run(identifier : String, accept_duplicated = false, &block)
    return if JOBS.includes? identifier

    MUTEX.synchronize do
      JOBS.add(identifier)
    end
    spawn do
      begin
        block.call
      ensure
        MUTEX.synchronize do
          JOBS.delete(identifier)
        end
      end
    end
  end
end
