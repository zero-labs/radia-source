require 'rubygems'
require 'openwfe/def'
require 'openwfe/workitem'
require 'openwfe/engine/engine'
require 'participants'

#
# instantiating an engine

engine = OpenWFE::Engine.new

#
# adding some participants

engine.register_participant :delivery, RadiaSource::Participants::Delivery.new
engine.register_participant :validation, RadiaSource::Participants::Validation.new
engine.register_participant :broadcast, RadiaSource::Participants::Broadcast.new
engine.register_participant :post_broadcast, RadiaSource::Participants::PostBroadcast.new
engine.register_participant :alternative, RadiaSource::Participants::Alternative.new
engine.register_participant :alert, RadiaSource::Participants::Alert.new
engine.register_participant :waiter, RadiaSource::Participants::Waiter.new

#
# recorded emission process
class RecordedProcess < OpenWFE::ProcessDefinition
  cursor do
    
    # Step 0 - entrance
    
    # Step 1
    participant :delivery
    _if do
      equals :field_value => :delivered, :other_value => 'n' # ! delivered?
      sequence do
        participant :alternative
        participant :alert
        skip 2 # skip validation
      end
    end
    
    # Step 2
    participant :validation
    _if do
      equals :field_value => :modified, :other_value => 'y' # modified?
      participant :alert
    end
    
    # Step 3
    _timeout :after => "6s" do
      participant :waiter
    end
    
    # Step 4
    participant :broadcast
    _if do
      equals :field_value => :normal, :other_value => 'n'
      skip 5 # skip post_broadcast if nothing should be done
    end
    
    # Step 5
    participant :post_broadcast
  end
end

#
# launching the process

li = OpenWFE::LaunchItem.new(RecordedProcess)

fei = engine.launch li
#
# 'fei' means FlowExpressionId, the fei returned here is the
# identifier for the root expression of the newly launched process

puts "started process '#{fei.workflow_instance_id}'"

engine.wait_for fei
#
# blocks until the process terminates