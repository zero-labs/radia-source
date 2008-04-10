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
