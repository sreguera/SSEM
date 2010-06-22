# ssem.tcl
#
#    Manchester Small-Scale Experimental Machine (SSEM) Simulator GUI
#
# Copyright (c) 2010 Sebastián Reguera Candal

package require Tk
#package require ssem
source ssem.tcl

namespace eval ::ssem::gui {

    variable stopFlag false
}

proc ::ssem::gui::updateMem {} {
    for {set pos 0} {$pos < 32} {incr pos} {
        .c.memx set $pos value [lindex $::ssem::Store $pos]
        .c.memx set $pos inst [::ssem::decode [lindex $::ssem::Store $pos]]
    }
}

proc ::ssem::gui::stepEmu {} {
    ::ssem::step
    updateMem
}

proc ::ssem::gui::runEmu {} {
    variable stopFlag
    set stopFlag false
    .c.but.step configure -state disabled
    .c.but.run configure -state disabled
    while {! $stopFlag} {
        if {! [::ssem::step 1001]} {
            set stopFlag true
        }
        updateMem
        update
    }
    .c.but.step configure -state enabled
    .c.but.run configure -state enabled
}

proc ::ssem::gui::stopEmu {} {
    variable stopFlag
    set stopFlag true
}

proc ::ssem::gui::mainFrame {} {
    pack [ttk::frame .c]

    pack [ttk::frame .c.reg]

    pack [ttk::label .c.reg.aregl -text "A:"] -side left
    pack [ttk::label .c.reg.areg -textvariable ::ssem::A] -side left

    pack [ttk::label .c.reg.cregl -text "C:"] -side left
    pack [ttk::label .c.reg.creg -textvariable ::ssem::C] -side left

    pack [ttk::label .c.reg.piregl -text "PI:"] -side left
    pack [ttk::label .c.reg.pireg -textvariable ::ssem::PI] -side left

    pack [ttk::label .c.meml -text "M:"]
    pack [ttk::treeview .c.memx -height 32 -columns {value inst}]
    .c.memx heading #0 -text {Address}
    .c.memx heading value -text {Value}
    .c.memx heading inst -text {Inst}
    for {set pos 0} {$pos < 32} {incr pos} {
        .c.memx insert {} end -id $pos -text $pos
    }

    pack [ttk::frame .c.but]

    pack [ttk::button .c.but.step -text "Step" -command ::ssem::gui::stepEmu] \
        -side left
    pack [ttk::button .c.but.run  -text "Run"  -command ::ssem::gui::runEmu] \
        -side left
    pack [ttk::button .c.but.stop -text "Stop" -command ::ssem::gui::stopEmu] \
        -side left
}

wm title . "SSEM Emulator"
::ssem::gui::mainFrame

set N 262144

::ssem::mset  1 [::ssem::encode ldn 18]
::ssem::mset  2 [::ssem::encode ldn 19]
::ssem::mset  3 [::ssem::encode sub 20]
::ssem::mset  4 [::ssem::encode cmp]
::ssem::mset  5 [::ssem::encode jrp 21]
::ssem::mset  6 [::ssem::encode sub 22]
::ssem::mset  7 [::ssem::encode sto 24]
::ssem::mset  8 [::ssem::encode ldn 22]
::ssem::mset  9 [::ssem::encode sub 23]
::ssem::mset 10 [::ssem::encode sto 20]
::ssem::mset 11 [::ssem::encode ldn 20]
::ssem::mset 12 [::ssem::encode sto 22]
::ssem::mset 13 [::ssem::encode ldn 24]
::ssem::mset 14 [::ssem::encode cmp]
::ssem::mset 15 [::ssem::encode jmp 25]
::ssem::mset 16 [::ssem::encode jmp 23]
::ssem::mset 17 [::ssem::encode stp]
::ssem::mset 18 0
::ssem::mset 19 [expr {- $N}]
::ssem::mset 20 [expr {$N - 1}]
::ssem::mset 21 -3
::ssem::mset 22 [expr {-($N - 1)}]
::ssem::mset 23 1
::ssem::mset 24 0
::ssem::mset 25 16

::ssem::gui::updateMem
