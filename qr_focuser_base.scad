// =====================================================================
//  FOCUSER BASE (MALE bayonet)  -- mates the bracket's female receiver
//
//  Replaces the focuser's bottom base. Top = focuser mount (flat face +
//  3 captive M4 nut pockets at the sandwich BCD, so the lid+cylinder bolt
//  on as before). Bottom = bayonet male: a neck + 3 lugs that drop through
//  the bracket's gaps and twist under its lips.
//
//  *** Bayonet params MUST match qr_bracket.scad ***
//
//  v1: lugs + neck + focuser mount. Clamp RAMP + DETENT to be added next.
// =====================================================================

// ---- must match the bracket ----
bore_d        = 31;
bay_socket_id = 42;
bay_ledge_id  = 37;
bay_ledge_t   = 2.2;
bay_ring_od   = 54;      // bracket ring OD that the skirt wraps (match bracket)
bay_ring_h    = 8;       // bracket ring height (match bracket) - sets lock-hole height
bay_gap_arc   = 64;      // match bracket - used to locate the lock hole
bay_stop_arc  = 4;       // match bracket - used to locate the lock hole
bay_n         = 3;
bay_clear     = 0.4;     // rotating fit clearance (radial)

// ---- lock screw (radial M3; nut sits in a hex cutout in the skirt) ----
lock_angle    = 0;       // bracket-frame lock angle (match bracket)
m3_clear      = 3.4;     // screw clearance
m3_nut_af     = 5.9;     // M3 nut across-flats (5.5) + 0.2 clearance
m3_nut_thk    = 2.5;     // M3 nut thickness + clearance
lpad_out      = 1.5;     // local skirt thickening so the cutout has a back wall (minimal)
lpad_w        = 8;       // pad width (just clears the nut)
lpad_z        = 7;       // pad height (just clears the nut)
lock_drop     = 2.8;     // lock centre below the ring top (keeps the pad inside the skirt)

// ---- outer skirt (wraps the bracket ring -> radial register + centering) ----
skirt_od      = 60;      // flush with the bracket pad
skirt_clear   = 0.6;     // diametral slip-fit gap over the ring OD
skirt_depth   = 7;       // how far the skirt reaches down the ring

// ---- focuser mount (the sandwich) ----
flange_od     = 60;      // flush with the skirt / bracket pad
mount_h       = 19;      // focuser-mount-face height above the register face. The screw
                         // comes DOWN from the top and travels this far to the captive
                         // nut at the BOTTOM. Make it taller to swallow an over-long
                         // screw (less tip pokes past the nut into the socket). Keep it
                         // >= the screw's protrusion length. Adds stack height -> recover
                         // focus by shortening the truss.
stud_spacing  = 36.5;    // -> BCD 42.1 (matches the original screws)
nut_af        = 7.4;     // M4 hex nut across-flats + clearance
nut_thk       = 3.4;     // M4 nut thickness + clearance
screw_clear   = 4.4;     // M4 screw clearance + stud-tip relief
clocking_angle = 90;

// ---- lugs + clamp ramp ----
lug_arc       = 50;      // lug angular width (passes the 64-deg gaps)
lug_h         = 2.6;     // lug body height
entry_clear   = 0.5;     // gap under the lip at the ENTRY end of the lug (easy start)
preload       = 0.15;    // interference at the LOCKED end (the clamp). 0 = just touch.
ramp_dir      = 1;       // which way the ramp rises; flip to -1 if it tightens backwards

$fn = 120;
// =====================================================================
stud_bcd = stud_spacing/sqrt(3)*2;
flange_thk = mount_h;                            // focuser-mount face height (nut at the bottom)
// twist angle from drop-in (lug at gap) to the locked stop -> places the lock hole
ledge_arc  = 360/bay_n - bay_gap_arc;
lock_twist = (360/bay_n)*0.5 + ledge_arc/2 - bay_stop_arc - lug_arc/2;
neck_d   = bay_ledge_id - 2*bay_clear;          // passes within the lips
lug_ir   = bore_d/2 - 0.6;                       // reach inward to the bore wall (the bore
                                                 // cut trims it flush) so each lug fuses
                                                 // solidly into the body instead of floating
lug_or   = (bay_socket_id - 2*bay_clear)/2;     // fits the socket, under the lip

// lug-top heights (the ramp): low at entry, rising to a peak with interference,
// then a small dip = the detent the lip settles into at the locked end.
lug_top_lo   = -(bay_ledge_t + entry_clear);
lug_top_peak = -(bay_ledge_t - preload);
lug_bot      = lug_top_lo - lug_h;
function ztop(a) =
    let (p = (ramp_dir > 0 ? a : lug_arc - a) / lug_arc)            // 0 = entry, 1 = locked
    lug_top_lo + p * (lug_top_peak - lug_top_lo);                   // monotonic rise to peak

// one lug: stepped segments whose top follows the ramp/detent profile
module lug() {
    step = 2;
    for (a = [0 : step : lug_arc - 0.001]) {
        seg = min(step + 0.7, lug_arc - a);
        rotate([0,0, a]) rotate_extrude(angle = seg)
            translate([lug_ir, lug_bot]) square([lug_or - lug_ir, ztop(a) - lug_bot]);
    }
}

// lock boss: encloses the M3 nut at the bottom and runs the FULL height up to the
// mount face, so it's tied into the body (not floating) and doubles as a thumb grip
// / lever for twisting the bayonet home.
module lock_pad() {
    z0 = -lock_drop - lpad_z/2;     // bottom: wraps the captive M3 nut
    z1 = flange_thk;                // top: flush with the focuser-mount face
    rotate([0,0, lock_angle - lock_twist])
        translate([skirt_od/2 - 2, -lpad_w/2, z0])
            cube([lpad_out + 2, lpad_w, z1 - z0]);
}

// hex nut cutout (open at the outer face) + screw clearance through to the ring
module lock_nut_cuts() {
    xin = (bay_ring_od + skirt_clear)/2;              // skirt inner face (toward the ring)
    rotate([0,0, lock_angle - lock_twist]) translate([0,0, -lock_drop]) {
        translate([xin - 0.2, 0, 0]) rotate([0,90,0])                   // hex pocket, opens INWARD
            cylinder(d = m3_nut_af/cos(30), h = m3_nut_thk + 0.5, $fn = 6); // (ring retains the nut)
        translate([skirt_od/2 - 4, 0, 0]) rotate([0,90,0])              // screw clearance
            cylinder(d = m3_clear, h = lpad_out + 6, $fn = 24);
    }
}

module male() {
    difference() {
        union() {
            cylinder(d = flange_od, h = flange_thk);                       // focuser-mount flange
            lock_pad();                                                    // local pad for the nut cutout
            // outer skirt: a tube that drops over the bracket ring OD (radial register)
            difference() {
                translate([0,0, -skirt_depth]) cylinder(d = skirt_od, h = skirt_depth);
                translate([0,0, -skirt_depth-0.5]) cylinder(d = bay_ring_od + skirt_clear, h = skirt_depth + 0.5);
            }
            // neck extends a bit past the lip line to overlap the lugs (manifold)
            translate([0,0, -(bay_ledge_t + 0.6)]) cylinder(d = neck_d, h = bay_ledge_t + 0.62);
            // 3 ramped lugs at the gap angles (0,120,240) so they drop straight in
            for (i = [0:bay_n-1]) rotate([0,0, i*120 - lug_arc/2]) lug();
        }
        // light bore
        translate([0,0, -bay_ledge_t-lug_h-1])
            cylinder(d = bore_d, h = flange_thk + bay_ledge_t + lug_h + 2);
        // sandwich at the screw BCD (90,210,330): captive M4 hex nut at the BOTTOM
        // (inserted from the lug side before the focuser goes on), full-height screw
        // clearance above it. The tall base means the screw reaches the bottom nut
        // without its tip poking far past into the socket.
        for (i = [0:2]) rotate([0,0, clocking_angle + i*120]) translate([stud_bcd/2, 0, 0]) {
            translate([0,0,-0.01]) cylinder(d = screw_clear, h = flange_thk + 1);          // screw clearance
            translate([0,0,-0.01]) cylinder(d = nut_af/cos(30), h = nut_thk + 0.01, $fn = 6); // captive nut, bottom
        }
        lock_nut_cuts();   // screw clearance + captive-nut pocket + insert slot
    }
    echo(str("MALE: flange ", flange_od, " neck ", neck_d, " lug r ", lug_ir, "-", lug_or,
             " at 0/120/240; nuts at ", clocking_angle, "/210/330 (BCD ", stud_bcd, ")"));
}

male();
