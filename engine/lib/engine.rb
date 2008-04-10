
require 'rubygems'
    #
    # if OpenWFEru was installed via 'gem'

#
# setting up an OpenWFEru engine, step by step

require 'openwfe/engine/engine'
require 'openwfe/engine/file_persisted_engine'
require 'openwfe/participants/participants'
require 'openwfe/expool/history'

# local requires
require 'recorded_process'
require 'participants'

#
# === the ENGINE itself
#

#
# a file persisted engine, with an in-memory cache.
# persistence is done by default under ./work/

engine = OpenWFE::CachedFilePersistedEngine.new
   
at_exit do
    #
    # making sure that the engine gets properly stopped when
    # Ruby exits.
    #
    engine.stop
end

# -- a console

#engine.enable_irb_console
    #
    # by enabling the IRB console, you can jump into the engine object
    # with a CTRL-C hit on the terminal that runs hit.
    #
    # Hit CTRL-D to get out of the IRB console.

# -- process history

# dumps all the process history in a file name "history.log"
# in the work directory
engine.init_service("history", OpenWFE::FileHistory)


#
# === some LISTENERS
#
# listeners 'receive' incoming workitems (InFlowWorkItem coming back from
# participants or LaunchItem requesting the launch of a particular flow)
#

#require 'openwfe/listeners/listeners'

#sl = OpenWFE::SocketListener.new(
#    "socket_listener", @engine.application_context, 7008)
#engine.add_workitem_listener(sl)
    #
    # adding a simple SocketListener on port 7008

#require 'openwfe/listeners/socketlisteners'
#
#engine.add_workitem_listener(OpenWFE::SocketListener)
    #
    # adding a SocketListener on the default port 7007

#engine.add_workitem_listener(OpenWFE::FileListener, "500")
    #
    # listening for workitems (coming as within YAML files dropped in the
    # default ./work/in directory)
    #
    # check for new files every 500 ms

#require 'openwfe/listeners/sqslisteners'
#
#engine.add_workitem_listener(
#    OpenWFE::SqsListener.new(:wiqueue, engine.application_context), 
#    "2s")
    #
    # adds a listener polling an Amazon Simple Queue Service (SQS) 
    # named 'wiqueue' every 2 seconds
    #
    # http://jmettraux.wordpress.com/2007/03/13/openwferu-over-amazon-sqs/
    # http://aws.amazon.com/sqs


#
# === the PARTICIPANTS
#

engine.register_participant :delivery, RadiaSource::Participants::Delivery.new
engine.register_participant :validation, RadiaSource::Participants::Validation.new
engine.register_participant :broadcast, RadiaSource::Participants::Broadcast.new
engine.register_participant :post_broadcast, RadiaSource::Participants::PostBroadcast.new
engine.register_participant :alternative, RadiaSource::Participants::Alternative.new
engine.register_participant :alert, RadiaSource::Participants::Alert.new
engine.register_participant :waiter, RadiaSource::Participants::Waiter.new


# this method has to be called after all the participants have been
# added, it looks for temporal expressions (sleep, cron, ...) to 
# reschedule.

engine.reschedule


#
# === joining the engine's scheduler thread
#
# (preventing the Ruby interpreting from prematurely (immediately) exiting)
#

#
# launching the process

li = OpenWFE::LaunchItem.new(RecordedProcess)

fei = engine.launch li

puts "started process '#{fei.workflow_instance_id}'"

engine.wait_for fei
#
# blocks until the process terminates


#engine.join
    #
    # you don't need to 'join' if the engine uses a listener, the thread of
    # the listener will prevent the Ruby interpreter from exiting.
    #
    # hit CTRL-C to quit (or maybe engine.enable_irb_console has been called,
    # in which case CTRL-C will bring you into a IRB console within the
    # engine itself).

