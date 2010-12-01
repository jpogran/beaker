# Accepts hash of parsed config file as arg
class Group
  attr_accessor :config, :fail_flag
  def initialize(config)
    self.config    = config
    self.fail_flag = 0

    usr_home=ENV['HOME']
    @fail_flag=0


		# Initiate transfer: puppet agent -t
		test_name="Group Resource: puppet agent --test"

    @config["HOSTS"].each_key do|host|
      @config["HOSTS"][host]['roles'].each do |role|
        if /agent/ =~ role then               # If the host is puppet agent
   		    agent_run = RemoteExec.new(host)    # get remote exec obj to agent
	  	    BeginTest.new(host, test_name)
		      result = agent_run.do_remote("puppet agent --test")
          ChkResult.new(host, test_name, result.stdout, result.stderr, result.exit_code)
          @fail_flag+=result.exit_code
        end
      end
    end

		# verify files have been transfered to agents
		test_name="Verify Group Existence on Agents"
    @config["HOSTS"].each_key do|host|
      @config["HOSTS"][host]['roles'].each do |role|
        if /agent/ =~ role then                # If the host is puppet agent
		      agent_run = RemoteExec.new(host)     # get remote exec obj to agent
		      BeginTest.new(host, test_name)
		      result = agent_run.do_remote('cat /etc/group | grep -c puppetgroup')
          ChkResult.new(host, test_name, result.stdout, result.stderr, result.exit_code)
          if (result.stdout =~ /3/ ) then
            puts "Group created correctly"
          else
            puts "Error creating group"
            @fail_flag+=1
          end
                
        end
      end
    end

  end
end
