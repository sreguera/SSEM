# ssem.tcl
#
#    Manchester Small-Scale Experimental Machine (SSEM) Simulator GUI
#
# Copyright (c) 2010 Sebastián Reguera Candal

package require Tk
#package require ssem
source ssem.tcl

namespace eval ::ssem::gui {

    variable StopFlag false
}

# ::ssem::gui::UpdateMem
#    Update the memory values in the memory table widget
proc ::ssem::gui::UpdateMem {} {
    for {set pos 0} {$pos < [::ssem::msize]} {incr pos} {
        .c.memx set $pos address $pos
        .c.memx set $pos value [::ssem::mget $pos]
        .c.memx set $pos inst [::ssem::decode [::ssem::mget $pos]]
    }
}

# ::ssem::gui::StepEmu
#    Step
proc ::ssem::gui::StepEmu {} {
    ::ssem::step
    UpdateMem
}

# ::ssem::gui::RunEmu
#    Run
proc ::ssem::gui::RunEmu {} {
    variable StopFlag
    set StopFlag false
    .c.but.step configure -state disabled
    .c.but.run configure -state disabled
    while {! $StopFlag} {
        if {! [::ssem::step 1001]} {
            set StopFlag true
        }
        UpdateMem
        update
    }
    .c.but.step configure -state enabled
    .c.but.run configure -state enabled
}

# ::ssem::gui::StopEmu
#    Stop
proc ::ssem::gui::StopEmu {} {
    variable StopFlag
    set StopFlag true
}

# ::ssem::gui::MainFrame
#    Create the main window frame
proc ::ssem::gui::MainFrame {} {
    pack [ttk::frame .c]

    pack [ttk::frame .c.reg]

    pack [ttk::label .c.reg.aregl -text "A:"] -side left
    pack [ttk::label .c.reg.areg -textvariable ::ssem::A -width 11] -side left

    pack [ttk::label .c.reg.cregl -text "C:"] -side left
    pack [ttk::label .c.reg.creg -textvariable ::ssem::C -width 11] -side left

    pack [ttk::label .c.reg.piregl -text "PI:"] -side left
    pack [ttk::label .c.reg.pireg -textvariable ::ssem::PI -width 11] -side left

    pack [ttk::label .c.meml -text "M:"]
    pack [ttk::treeview .c.memx -show headings -height 32 -columns {address value inst}]
    .c.memx heading address -text {Addr}
    .c.memx heading value -text {Value}
    .c.memx heading inst -text {Inst}
    .c.memx column address -width 100 -anchor e
    .c.memx column value -width 120 -anchor e
    .c.memx column inst -width 120
    for {set pos 0} {$pos < [::ssem::msize]} {incr pos} {
        .c.memx insert {} end -id $pos 
    }

    pack [ttk::frame .c.but]

    pack [ttk::button .c.but.step -text "Step" \
              -command [namespace code StepEmu]] \
        -side left
    pack [ttk::button .c.but.run  -text "Run"  \
              -command [namespace code RunEmu]] \
        -side left
    pack [ttk::button .c.but.stop -text "Stop" \
              -command [namespace code StopEmu]] \
        -side left
}

# Start the application
wm title . "SSEM Emulator"
::ssem::gui::MainFrame

# Load a sample program just to show something
set program [::ssem::asm {
    { expr 0 }
    { ldn 18 }
    { ldn 19 }
    { sub 20 }
    { cmp }
    { jrp 21 }
    { sub 22 }
    { sto 24 }
    { ldn 22 }
    { sub 23 }
    { sto 20 }
    { ldn 20 }
    { sto 22 }
    { ldn 24 }
    { cmp }
    { jmp 25 }
    { jmp 23 }
    { stp }
    { expr 0 }
    { expr {- 262144}}
    { expr {262144 - 1}}
    { expr -3 }
    { expr {-(262144 - 1)}}
    { expr 1 }
    { expr 0 }
    { expr 16 }
}]
::ssem::load $program

::ssem::gui::UpdateMem
