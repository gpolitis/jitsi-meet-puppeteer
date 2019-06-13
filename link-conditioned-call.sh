#!/bin/sh
set -e

LINK_CONDITIONER=$HOME/Projects/jitsi-videobridge/resources/link-conditioner.sh

impair () {
  PLR=0 $LINK_CONDITIONER egress
  sudo pfctl -e
}

restore () {
  $LINK_CONDITIONER flush
  sudo pfctl -d
}

start_call () {
  $CALL_EXEC &
  CALL_PID=$!
}

end_call () {
  kill $CALL_PID
}

wait4_rampup() {
  sleep 90
}

CALL_EXEC=$1
if [ ! -x "$CALL_EXEC" ]; then
  echo "Forgot something? :troll_face:"
  exit 1
fi

start_call
for i in `seq 1 3`
do
  wait4_rampup
  impair
  wait4_rampup
  restore
done
wait4_rampup

echo "Do you wish to end the call?"
read do_end_call
case $do_end_call in
  [Yy]* )
    end_call ;;
esac
