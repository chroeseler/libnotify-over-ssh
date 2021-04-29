#!/usr/bin/perl -w
use strict;
use IO::Socket;
use File::Basename;
use Cwd 'abs_path';
my $scriptpath = dirname(abs_path($0));

my $weechat_icon="$scriptpath/icons/weechat_icon.png";
my $system_icon="$scriptpath/icons/system_icon.png";
my $HOST = '127.0.0.1';
my $PORT = '1216';


my $socket = IO::Socket::INET->new('LocalPort' => $PORT,
    'Proto' => 'tcp',
    'Listen' => 4)
or die "Can't create socket ($!)\n";
while (my $client = $socket->accept) {
  my ($tag, $title, $summary, $ulevel, $x);
  while (<$client>) {
    my $buf = $_;
    chomp $buf;
    $x++;
    if($x == 1){$tag = $buf;}
    if($x == 2){$title = $buf;}
    if($x == 3){$ulevel = $buf;}
    if($x == 4){
      $summary = $buf;
      message($tag,$title,$summary,$ulevel);
    }
  }
  close $client
    or die "Can't close ($!)\n";
}

sub message{
  my $tag = $_[0];
  my $title = $_[1];
  my $ulevel = $_[2];
  my $summary = $_[3];
  if($tag eq 'weechat'){
    # see if weechat has focus, if not, send notification.  Depends on terminal name starting with weechat
    my $focus = `xwininfo -tree -id \$(xdpyinfo | awk '/focus/ {gsub(",", "", \$3); print \$3}') | grep Parent | awk -F\\" '{print \$2}'`;
    if ($focus !~ /^weechat /){
      $title =~ s/[<&]//g; # remove some characters that libnotify hates
      $summary =~ s/[<&]//g;
      my @args = ('/usr/bin/notify-send', $title, $summary, "--icon=$weechat_icon", "--urgency=$ulevel");
      system @args;
    }
  }
  if($tag eq 'system'){
    $title =~ s/[<&]//g; # remove some characters that libnotify hates
    $summary =~ s/[<&]//g;
    my @args = ('/usr/bin/notify-send', $title, $summary, "--icon=$system_icon", "--urgency=$ulevel");
    system @args;
  }
}
