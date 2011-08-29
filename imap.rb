#!/usb/bin/env ruby
require 'net/imap'
require 'mattscilipoti-rdialog'

$USER = 'some_user_possibly@some_domain_if_your_users_use_this_format.net'
$PASS = 'change_me'
$HOST = 'your_imap_server.net'
$PORT = 993
$SSL = true

$folders = Array.new
$msgs = Array.new

# helper method for instantiating our dialog API...
# using this, you only have to configure it in one spot.
def new_dialog()
    # instantiate our dialog and set some options...
    # ...then return it as an object
    dialog = RDialog.new
    dialog.nocancel = true
    dialog.shadow = false
    return dialog
end # new_dialog

def init_imap()
    # connect to IMAP
    puts "Connecting..."
    $imap = Net::IMAP.new($HOST, $PORT, $SSL)
    puts "Logging in..."
    $imap.login($USER, $PASS)

    # list folders
    $imap.list("", "*").each do |folder|
        $folders.push([folder[2]])
    end # imap.list
end # init_imap

def get_mail()
    # get messages in the folder
    folder = new_dialog.menu("Select a folder to view new messages or ^c to quit", $folders)
    $imap.examine(folder)
    (msglist = $imap.search(["RECENT"])).each do |message_id|
        puts "Getting info for message #{message_id}, which is message #{msglist.index(message_id).to_i + 1}/#{msglist.count}"
        envelope = $imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
        $msgs.push([message_id, envelope.subject])
    end # msglist.each
end # get_mail

init_imap()
get_mail()
loop do
    selected_msg = new_dialog.menu("Select a message to read it or ^c to quit", $msgs)
    body = $imap.fetch(selected_msg.to_i, "BODY[]")[0].attr["BODY[]"]
    new_dialog.msgbox(body)
end
#$imap.logout()
#$imap.disconnect()
