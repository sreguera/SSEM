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

proc ::ssem::gui::stopEmu {} {
    variable stopFlag
    set stopFlag true
}

proc ::ssem::gui::runEmu {} {
    variable stopFlag
    set stopFlag false
    .c.step configure -state disabled
    .c.run configure -state disabled
    while {! $stopFlag} {
        if {! [::ssem::step 1001]} {
            set stopFlag true
        }
        update
    }
    .c.step configure -state enabled
    .c.run configure -state enabled
}

proc ::ssem::gui::mainFrame {} {
    grid [ttk::frame .c] -column 0 -row 0

    grid [ttk::label .c.aregl -text "A:"] \
        -column 0 -row 0
    grid [ttk::label .c.areg -textvariable ::ssem::A] \
        -column 1 -row 0

    grid [ttk::label .c.cregl -text "C:"] \
        -column 0 -row 1
    grid [ttk::label .c.creg -textvariable ::ssem::C] \
        -column 1 -row 1

    grid [ttk::label .c.piregl -text "PI:"] \
        -column 0 -row 2
    grid [ttk::label .c.pireg -textvariable ::ssem::PI] \
        -column 1 -row 2

    grid [ttk::label .c.meml -text "M:"] \
        -column 0 -row 3
    grid [tk::listbox .c.mem -height 32 -listvariable ::ssem::Store] \
        -column 1 -row 3

    grid [ttk::button .c.step -text "Step" -command ::ssem::step] \
        -column 0 -row 4
    grid [ttk::button .c.run  -text "Run"  -command ::ssem::gui::runEmu] \
        -column 1 -row 4
    grid [ttk::button .c.stop -text "Stop" -command ::ssem::gui::stopEmu] \
        -column 2 -row 4
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


