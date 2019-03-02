#!/usr/bin/expect
# Ardavan Hashemzadeh
# October 11 2017
# Detect sound in expect
# while linphone is running

set timeout 30
set TriggerLevel 0.19
set SampleDuration 1
set uri [lindex $argv 0]

spawn linphonec -C

expect {
  -re {Registration .+ successful} {}
  -re {Registration .+ failed} {send "quit\r";exit}
}

while true {
  set timeout -1
  set trigger [ exec /bin/bash -c "export AUDIODEV=hw:1,0; paste <(rec -n stat trim 0 $SampleDuration 2>&1 | grep 'Maximum amplitude') <(echo $TriggerLevel) | awk '//{print (\$3>=\$4)?1:0'}" ]
  if { $trigger } {
    send_user "*********Tigger*********\n"
    send "call $uri\r"
    while true {
      expect {
        -re {Syntax error} {break}
        -re {Call .+ error} {break}
        -re {Call .+ ended (No error)} {break}
        -re {Call answered} {send "camera on\r"}
        "Receiving tone 1 from <$uri>" {send_user "hello world"}
      }
    }
  } else {
    send_user "did not detect stuff\n"
    expect "call from <$uri>" {send_user "detected incoming call\n";send "answer\r"}
  }
}
