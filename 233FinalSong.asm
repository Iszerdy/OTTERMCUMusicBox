# Plays either Twinkle Twinkle Little Star or the Pink Panther theme song based on the value of switches 
# SWITCHES = 1: play Twinkle Twinkle, SWITCHES = 2: play Pink Panther, SWITCHES = anything else: play nothing
# An interrupt (BTNL) starts the playing – without it, nothing will play.
# Meant for Basys 3 board with piezo speaker.

.eqv MMIO,     0x11000000      # Base MMIO address for I/O
.eqv LEDS,     0x20            # Offset for LEDS (LED register at 0x11000020)
.eqv SEV_SEG,  0x40            # Offset for seven-seg display (at 0x11000040)
.eqv SPEAKER,  0x60            # Offset for Speaker (at 0x11000060)
.eqv SWITCHES, 0x00            # Offset for SWITCHES (assumed at MMIO base)

    .data
    .align 4
stack_top:
    .space 1024               # Reserve 1024 bytes for the stack

    .text
.globl _start

_start:
    # --- Initialization ---
    la      sp, stack_top       # Initialize stack pointer
    li      s0, MMIO            # s0 holds the base MMIO address

    # Enable interrupts by setting MIE (bit 3) in mstatus.
    li      t1, 8               # 8 = 1<<3
    csrrs   x0, mstatus, t1     # Set mstatus.MIE

    # Set up the interrupt vector: store the address of our ISR in mtvec.
    la      t0, isr            # Load address of our ISR
    csrrw   x0, mtvec, t0      # Write ISR address into mtvec CSR

    # --- Main Loop ---
MAIN_LOOP:
    lw      a0, SWITCHES(s0)   # Read switch values
    andi    a0, a0, 0x03       # Mask lowest 2 bits (switches 1 and 2)
    li      t2, 0
    beq     a0, t2, MAIN_LOOP   # If switches==0, do nothing; keep looping
    j       MAIN_LOOP         # Wait for BTNL interrupt to trigger song playback

# --- Interrupt Service Routine ---
# A BTNL press (debounced in hardware) triggers this ISR.
isr:
    addi    sp, sp, -16        # Create stack frame
    sw      ra, 12(sp)         # Save return address
    sw      t0, 8(sp)          # Save t0

    # Read SWITCHES to determine which song to play
    lw      t0, SWITCHES(s0)
    andi    t0, t0, 0x03       # Consider only bits 0-1

    li      t1, 1             # If SWITCHES = 1, play Twinkle Twinkle
    beq     t0, t1, PLAY_TWINKLE

    li      t1, 2             # If SWITCHES = 2, play Pink Panther
    beq     t0, t1, PLAY_PINK

    j       ISR_EXIT

PLAY_TWINKLE:
    # Seven-seg displays "2" for Twinkle Twinkle.
    li      t2, 2
    sw      t2, SEV_SEG(s0)
    call    twinkle         # Call Twinkle routine.
    j       ISR_EXIT

PLAY_PINK:
    # Seven-seg displays "1" for Pink Panther.
    li      t2, 1
    sw      t2, SEV_SEG(s0)
    call    Pink_Panther    # Call Pink Panther routine.
    j       ISR_EXIT

ISR_EXIT:
    lw      ra, 12(sp)        # Restore registers
    lw      t0, 8(sp)
    addi    sp, sp, 16
    mret                      # Return from interrupt

# --- Song Routines ---
# The following routines call subroutines to play notes.
# In each case, the LED (mapped at MMIO+0x20) is updated only during note playback.
#
# Pink Panther Routine:
Pink_Panther:
    call    pink_panther_phrase  # Segment 1: common phrase
    call    play_B              # B half
    call    delay_half
    call    play_A              # A sixteenth
    call    delay_sixteenth
    call    play_G              # G sixteenth
    call    delay_sixteenth
    call    play_E              # E sixteenth
    call    delay_sixteenth
    call    play_D              # D sixteenth
    call    delay_sixteenth
    call    play_E              # E half
    call    delay_half
    call    play_rest           # Rest for one quarter
    call    delay_quarter

    call    pink_panther_phrase  # Segment 2
    call    play_G              # G sixteenth
    call    delay_sixteenth
    call    play_B              # B sixteenth
    call    delay_sixteenth
    call    play_E              # E sixteenth
    call    delay_sixteenth
    call    play_E              # E whole
    call    delay_whole
    call    play_E              # E half
    call    delay_half
    call    play_rest           # Rest for one quarter
    call    delay_quarter

    call    pink_panther_phrase  # Segment 3
    call    play_rest
    ret

# Pink Panther Phrase Subroutine (with LED control)
pink_panther_phrase:
    addi    sp, sp, -4
    sw      ra, 0(sp)

    # D# quarter
    li      t2, 0x31         # LED pattern for D#
    sw      t2, LEDS(s0)
    call    play_Ds
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    # E quarter
    li      t2, 0x32         # LED pattern for E
    sw      t2, LEDS(s0)
    call    play_E
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    # F# eighth
    li      t2, 0x37         # LED pattern for F#
    sw      t2, LEDS(s0)
    call    play_Fs
    call    delay_eighth
    li      t2, 0
    sw      t2, LEDS(s0)

    # G quarter
    li      t2, 0x38         # LED pattern for G
    sw      t2, LEDS(s0)
    call    play_G
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    # D# eighth
    li      t2, 0x31
    sw      t2, LEDS(s0)
    call    play_Ds
    call    delay_eighth
    li      t2, 0
    sw      t2, LEDS(s0)

    # E sixteenth
    li      t2, 0x32
    sw      t2, LEDS(s0)
    call    play_E
    call    delay_sixteenth
    li      t2, 0
    sw      t2, LEDS(s0)

    # F# sixteenth
    li      t2, 0x37
    sw      t2, LEDS(s0)
    call    play_Fs
    call    delay_sixteenth
    li      t2, 0
    sw      t2, LEDS(s0)

    # G sixteenth
    li      t2, 0x38
    sw      t2, LEDS(s0)
    call    play_G
    call    delay_sixteenth
    li      t2, 0
    sw      t2, LEDS(s0)

    # C6 sixteenth
    li      t2, 0x3D
    sw      t2, LEDS(s0)
    call    play_C6
    call    delay_sixteenth
    li      t2, 0
    sw      t2, LEDS(s0)

    # B sixteenth
    li      t2, 0x3C
    sw      t2, LEDS(s0)
    call    play_B
    call    delay_sixteenth
    li      t2, 0
    sw      t2, LEDS(s0)

    # E sixteenth
    li      t2, 0x32
    sw      t2, LEDS(s0)
    call    play_E
    call    delay_sixteenth
    li      t2, 0
    sw      t2, LEDS(s0)

    # G sixteenth
    li      t2, 0x38
    sw      t2, LEDS(s0)
    call    play_G
    call    delay_sixteenth
    li      t2, 0
    sw      t2, LEDS(s0)

    # B sixteenth
    li      t2, 0x3C
    sw      t2, LEDS(s0)
    call    play_B
    call    delay_sixteenth
    li      t2, 0
    sw      t2, LEDS(s0)

    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret

# Twinkle Subroutine Parts (with LED control)
twinkle_part1:
    addi    sp, sp, -4
    sw      ra, 0(sp)

    li      t2, 0x11       # LED pattern for C
    sw      t2, LEDS(s0)
    call    play_C
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x12       # LED pattern for rest
    sw      t2, LEDS(s0)
    call    play_rest
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x11       # LED pattern for C (again)
    sw      t2, LEDS(s0)
    call    play_C
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x18       # LED pattern for G
    sw      t2, LEDS(s0)
    call    play_G
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x12       # LED pattern for rest
    sw      t2, LEDS(s0)
    call    play_rest
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x18       # LED pattern for G (again)
    sw      t2, LEDS(s0)
    call    play_G
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x1A       # LED pattern for A
    sw      t2, LEDS(s0)
    call    play_A
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x12       # LED pattern for rest
    sw      t2, LEDS(s0)
    call    play_rest
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x1A       # LED pattern for A (again)
    sw      t2, LEDS(s0)
    call    play_A
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x18       # LED pattern for G
    sw      t2, LEDS(s0)
    call    play_G
    call    delay_half
    li      t2, 0
    sw      t2, LEDS(s0)

    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret

twinkle_part2:
    addi    sp, sp, -4
    sw      ra, 0(sp)

    li      t2, 0x16       # LED pattern for F
    sw      t2, LEDS(s0)
    call    play_F
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x12       # LED pattern for rest
    sw      t2, LEDS(s0)
    call    play_rest
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x16       # LED pattern for F (again)
    sw      t2, LEDS(s0)
    call    play_F
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x32       # LED pattern for E
    sw      t2, LEDS(s0)
    call    play_E
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x12       # LED pattern for rest
    sw      t2, LEDS(s0)
    call    play_rest
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x32       # LED pattern for E (again)
    sw      t2, LEDS(s0)
    call    play_E
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x18       # LED pattern for D
    sw      t2, LEDS(s0)
    call    play_D
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x12       # LED pattern for rest
    sw      t2, LEDS(s0)
    call    play_rest
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x18       # LED pattern for D (again)
    sw      t2, LEDS(s0)
    call    play_D
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x11       # LED pattern for C
    sw      t2, LEDS(s0)
    call    play_C
    call    delay_half
    li      t2, 0
    sw      t2, LEDS(s0)

    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret

twinkle_part3:
    addi    sp, sp, -4
    sw      ra, 0(sp)

    li      t2, 0x18       # LED pattern for G
    sw      t2, LEDS(s0)
    call    play_G
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x12       # LED pattern for rest
    sw      t2, LEDS(s0)
    call    play_rest
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x18       # LED pattern for G (again)
    sw      t2, LEDS(s0)
    call    play_G
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x16       # LED pattern for F
    sw      t2, LEDS(s0)
    call    play_F
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x12       # LED pattern for rest
    sw      t2, LEDS(s0)
    call    play_rest
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x16       # LED pattern for F (again)
    sw      t2, LEDS(s0)
    call    play_F
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x32       # LED pattern for E
    sw      t2, LEDS(s0)
    call    play_E
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x12       # LED pattern for rest
    sw      t2, LEDS(s0)
    call    play_rest
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x32       # LED pattern for E (again)
    sw      t2, LEDS(s0)
    call    play_E
    call    delay_quarter
    li      t2, 0
    sw      t2, LEDS(s0)

    li      t2, 0x18       # LED pattern for D
    sw      t2, LEDS(s0)
    call    play_D
    call    delay_half
    li      t2, 0
    sw      t2, LEDS(s0)

    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret

# --- Twinkle Subroutine ---
twinkle:
    call    twinkle_part1
    call    twinkle_part2
    call    twinkle_part3
    call    twinkle_part3
    call    twinkle_part1
    call    twinkle_part2
    call    play_rest
    ret

# --- Delay Subroutines (Single Loop) ---
delay_whole:
    li      t2, 20000000      # 2 seconds delay
delay_whole_loop:
    addi    t2, t2, -1
    bnez    t2, delay_whole_loop
    ret

delay_half:
    li      t2, 10000000      # 1 second delay
delay_half_loop:
    addi    t2, t2, -1
    bnez    t2, delay_half_loop
    ret

delay_quarter:
    li      t2, 5000000       # 0.5 second delay
delay_quarter_loop:
    addi    t2, t2, -1
    bnez    t2, delay_quarter_loop
    ret

delay_eighth:
    li      t2, 2500000       # 0.25 second delay
delay_eighth_loop:
    addi    t2, t2, -1
    bnez    t2, delay_eighth_loop
    ret

delay_sixteenth:
    li      t2, 1250000       # 0.125 second delay
delay_sixteenth_loop:
    addi    t2, t2, -1
    bnez    t2, delay_sixteenth_loop
    ret

# --- Short Delay (allows frequent input checks) ---
short_delay:
    li      t2, 50000000
delay_loop:
    addi    t2, t2, -1
    bnez    t2, delay_loop
    ret

# --- Note Subroutines ---
# Frequency mapping (Octave 5):
#   C:  0x01, C#: 0x02, D:  0x03, D#: 0x04, E:  0x05,
#   F:  0x06, F#: 0x07, G:  0x08, G#: 0x09, A:  0x0A,
#   A#: 0x0B, B:  0x0C
#
# Octave 6:
#   C6:  0x0D, C#6: 0x0E

play_C:
    li      t1, 0x01
    sb      t1, SPEAKER(s0)
    ret

play_Cs:
    li      t1, 0x02
    sb      t1, SPEAKER(s0)
    ret

play_D:
    li      t1, 0x03
    sb      t1, SPEAKER(s0)
    ret

play_Ds:
    li      t1, 0x04      # D#
    sb      t1, SPEAKER(s0)
    ret

play_E:
    li      t1, 0x05
    sb      t1, SPEAKER(s0)
    ret

play_F:
    li      t1, 0x06
    sb      t1, SPEAKER(s0)
    ret

play_Fs:
    li      t1, 0x07      # F#
    sb      t1, SPEAKER(s0)
    ret

play_G:
    li      t1, 0x08
    sb      t1, SPEAKER(s0)
    ret

play_Gs:
    li      t1, 0x09
    sb      t1, SPEAKER(s0)
    ret

play_A:
    li      t1, 0x0A
    sb      t1, SPEAKER(s0)
    ret

play_As:
    li      t1, 0x0B
    sb      t1, SPEAKER(s0)
    ret

play_B:
    li      t1, 0x0C
    sb      t1, SPEAKER(s0)
    ret

play_C6:
    li      t1, 0x0D      # 6th octave C
    sb      t1, SPEAKER(s0)
    ret

play_Cs6:
    li      t1, 0x0E      # 6th octave C#
    sb      t1, SPEAKER(s0)
    ret

# --- Rest Subroutine ---
play_rest:
    li      t1, 0x00
    sb      t1, SPEAKER(s0)
    ret
