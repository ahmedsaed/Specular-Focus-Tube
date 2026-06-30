// =====================================================================
//  QR BRACKET  -- screw-free tube attachment, PUSH-ON + INSIDE CLIP
//
//  The plain base lives in focuser_base.scad; this is the screw-free
//  attachment version.
//
//  How it works:
//    - 3 straight SNUG pins (~hole size) go through the 3 tube holes.
//      The snug fit is what gives rigidity / no wobble.
//    - Push the bracket straight onto the tube; pins poke into the cage.
//    - From inside the open cage, snap a printed C-CLIP onto each pin's
//      groove. The clip traps the wall between the saddle and the clip.
//    - Screw-free, tool-free, rigid. Removable (pop the clips) but this
//      joint is rarely removed, so that's fine.
//
//  Two pin modes (pin_mode):
//    "clip"   = grooved pins + snap-on C-clips (print the clip x3)
//    "thread" = M4 external studs + nuts (steel M4 nut, or the curved nut)
//
//  part = "bracket" | "clip" | "pins" | "washer" | "wall"
//  (clip: print 3.  pins: the 3 pins alone for a fit test.  washer: curved head-
//   washer for screw mode, print 3 at washer_tilt 0 / +13 / -13.  wall: mock tube-
//   wall segment to push the pins through.)
// =====================================================================

part = "bracket";

// ---- tube + base (shared with focuser_base) ----
tube_od        = 160.7;
wall_thk       = 5;
pad_diameter   = 60;
base_thickness = 6.8;
saddle_wrap    = 7;
bore_d         = 31;
stud_spacing   = 36.5;
clocking_angle = 90;
carbon_hole_d  = 4.0;       // measured hole diameter (set when scope is back)

// ---- pin mode ----
pin_mode   = "clip";        // "clip"   = grooved pins + C-clips
                            // "thread" = M4 studs + nuts (steel M4 or the curved nut)
                            // "screw"  = NO pins; captive M4 nut slid into the base from
                            //            the bore side, a 12mm M4 screw driven from inside
                            //            the cage into it. Print 3 curved head-washers
                            //            (part="washer", washer_tilt = 0 / +13 / -13).

// ---- pins (shared) ----
pin_clear  = 0.30;          // pin = hole - this (snug fit = rigidity). Raise if too tight.

// ---- clip mode ----
groove_d   = 2.3;           // necked groove diameter the clip grabs
groove_w   = 2.0;           // groove width (>= clip thickness)
tip_h      = 1.6;           // shoulder below the groove (+ a rounded end)

// ---- thread mode (M4 x 0.7 external stud into the cage) ----
thread_pitch = 0.7;
thread_clear = 0.35;        // crest undersize so a steel M4 nut threads on AND it
                            // passes the hole. Bigger = looser; smaller = tighter.
thread_len   = 8;           // threaded length protruding into the cage (plenty for a nut)
thread_tooth = 110;         // thread profile tooth angle
right_hand   = 1;           // 1 = standard RH thread; -1 if a nut won't start

// ---- screw mode (12mm M4 from inside the cage into a captive nut in the base) ----
//  The screw enters from the cage, crosses the tube wall + a thin clamp shelf, and
//  threads into a hex nut that you slide in radially from the central bore. Tightening
//  pulls the bracket onto the tube; the screw HEAD bears on the concave inner wall, so
//  it needs a curved washer (part="washer") just like the curved nut.
bscrew_clear = 4.6;     // M4 screw-shaft clearance through the bracket (carbon hole locates it)
bnut_af      = 7.4;     // M4 nut across-flats (7.0) + 0.4 -> 0.2/side slot & pocket
bnut_thk     = 3.6;     // slot height: M4 nut (3.2) + 0.4 headroom (screw seats it down on tighten)
bnut_roof    = 1.6;     // material left above the nut, under the base top (retains the nut)
bnut_grip    = 0.3;     // floor ridge at the channel mouth: nut rides over it and is held
bnut_grip_len= 1.2;     // length of that ridge

// ---- curved head-washer (screw mode; print 3: washer_tilt = 0 / +13 / -13) ----
washer_od    = 9;       // washer outer diameter (M4 head ~7mm sits on it)
washer_clr   = 4.0;     // M4 through-hole (snug on the shaft so the washer self-centres)
washer_h     = 2.5;     // min thickness at the thin edge after the convex carve
washer_tilt  = 0;       // 0 = centre hole; +13 / -13 = the two side holes (mirror pair)
washer_marg  = 4;       // stock above the apex, trimmed by the wall curve

// ---- clip (C-washer, print 3) ----
clip_od    = 9;
clip_thk   = 1.6;
clip_bore  = groove_d + 0.3;   // hugs the groove with a little clearance
clip_mouth = groove_d - 0.5;   // opening < groove_d so it snaps on and grips

// ---- bayonet receiver (FEMALE; the focuser's male lugs lock into this) ----
add_bayonet   = true;
bay_socket_id = 42;     // socket bore (the male body drops into this)
bay_ledge_id  = 37;     // inward lip diameter (lugs catch under it; > bore_d)
bay_ring_od   = 54;     // outer diameter of the bayonet ring (the male skirt wraps this)
bay_ring_h    = 8;      // ring height above the register face
bay_ledge_t   = 2.2;    // lip thickness at the top
bay_n         = 3;      // number of lugs / gaps
bay_gap_arc   = 64;     // entry-gap arc (deg) the lugs pass through
bay_stop_arc  = 4;      // width of the rotation stop

// ---- lock screw (radial M3; nut is captive in the male skirt) ----
lock_tap      = 3.3;    // DOWEL hole in the ring for the screw TIP (threads are in
                        // the skirt nut now, so this is a clearance dowel, not a tap)
lock_angle    = 0;      // angular position of the lock screw (bracket frame)
lock_drop     = 2.8;    // lock centre below the ring top (match the male)

// ---- wall mock (for bench testing) ----
wall_patch_d = 58;

$fn = 120;
// =====================================================================
Rt       = tube_od/2;
wall_R   = (tube_od - 2*wall_thk)/2;
stud_bcd = stud_spacing/sqrt(3)*2;
pin_d    = carbon_hole_d - pin_clear;
top_z    = base_thickness;

// The tube is a cylinder whose axis runs along Y, apex at z=0. So the wall
// height at a hole depends ONLY on its X (circumferential) position. The
// centreline hole (X=0) is at the apex; the side holes sit lower.
function zo(x) = -Rt + sqrt(Rt*Rt    - x*x);   // outer wall (saddle contact) z
function zi(x) = -Rt + sqrt(wall_R*wall_R - x*x); // inner wall z

function holexy(a) = [(stud_bcd/2)*cos(a), (stud_bcd/2)*sin(a)];
A = holexy(clocking_angle);
B = holexy(clocking_angle + 120);
C = holexy(clocking_angle + 240);

// ---------------- base ----------------
module saddle_cut()
    translate([0,0,-Rt]) rotate([90,0,0]) cylinder(r = Rt, h = pad_diameter*2, center = true);

module base_solid()
    difference() {
        translate([0,0,-saddle_wrap]) cylinder(d = pad_diameter, h = base_thickness + saddle_wrap);
        saddle_cut();
        translate([0,0,-saddle_wrap-1]) cylinder(d = bore_d, h = base_thickness + saddle_wrap + 2);
    }

module hole_positions() for (p = [A,B,C]) translate([p[0],p[1],0]) children();

// ---------------- clip-mode pin: straight grooved ----------------
//  full-diameter (snug) through the wall, then a groove for the clip, then
//  a short shoulder + rounded end. Groove sits at THIS hole's inner-wall
//  height, so side pins come out longer than the centreline pin.
module pin_clip(p) translate([p[0], p[1], 0]) {
    w = zi(p[0]);                                                       // inner wall z here
    translate([0,0, w])               cylinder(d = pin_d,   h = top_z - w); // through + into base
    translate([0,0, w-groove_w])      cylinder(d = groove_d, h = groove_w);  // clip groove
    translate([0,0, w-groove_w-tip_h]) cylinder(d = pin_d, h = tip_h);       // lower shoulder
    translate([0,0, w-groove_w-tip_h]) sphere(d = pin_d, $fn = 40);          // rounded end
}

// ---------------- thread-mode pin: M4 external stud ----------------
//  smooth snug section through the wall (rigidity), then an M4 external
//  thread protruding into the cage for a nut. Groove/thread sit at THIS
//  hole's inner-wall height, so side pins are longer than the centre pin.
module ext_thread(maj_d, p, length) {
    Rmaj  = maj_d/2 - thread_clear/2;
    Rmin  = Rmaj - 0.6134*p;
    turns = length/p;
    linear_extrude(height = length, twist = right_hand*-360*turns,
                   convexity = 10, slices = ceil(turns*24))
        union() {
            circle(r = Rmin, $fn = 40);
            polygon([[Rmin*cos( thread_tooth/2), Rmin*sin( thread_tooth/2)],
                     [Rmaj, 0],
                     [Rmin*cos(-thread_tooth/2), Rmin*sin(-thread_tooth/2)]]);
        }
}

module pin_thread(p) translate([p[0], p[1], 0]) {
    w = zi(p[0]);                                                  // inner wall z here
    translate([0,0, w]) cylinder(d = pin_d, h = top_z - w);        // smooth snug through-wall
    translate([0,0, w-thread_len]) ext_thread(4.0, thread_pitch, thread_len); // M4 stud into cage
    translate([0,0, w-thread_len-1.2]) cylinder(d1 = 1.0, d2 = pin_d, h = 1.2); // lead-in tip
}

// ---------------- bayonet receiver (female) ----------------
//  A ring on top of the base. Inward lip at the top, broken by 3 gaps; a
//  channel below; the base top is the register face. The focuser's lugs
//  pass the gaps, then twist under the lip until they hit a stop.
module bayonet_female() {
    ledge_arc = 360/bay_n - bay_gap_arc;          // solid lip arc between gaps
    rr0 = bay_ledge_id/2;                          // lip inner radius
    rw  = (bay_socket_id - bay_ledge_id)/2 + 0.8;  // lip width (+overlap into the ring wall)
    translate([0,0, top_z]) {
        // outer ring wall (socket)
        difference() {
            cylinder(d = bay_ring_od, h = bay_ring_h);
            translate([0,0,-1]) cylinder(d = bay_socket_id, h = bay_ring_h + 2);
        }
        for (i = [0:bay_n-1]) {
            c = (360/bay_n)*(i + 0.5);             // lip centres: 60,180,300 for n=3
            // lip (the part the lugs hook under)
            rotate([0,0, c - ledge_arc/2])
                translate([0,0, bay_ring_h - bay_ledge_t])
                    rotate_extrude(angle = ledge_arc)
                        translate([rr0, 0]) square([rw, bay_ledge_t]);
            // rotation stop at the far end (full height; merges with lip + wall)
            rotate([0,0, c + ledge_arc/2 - bay_stop_arc])
                rotate_extrude(angle = bay_stop_arc)
                    translate([rr0, 0]) square([rw, bay_ring_h]);
        }
    }
}

// ---------------- screw-mode captive nut slot ----------------
//  At each tube hole: a hex pocket that seats the M4 nut, an entry channel from the
//  bore so the nut slides in, a screw-shaft clearance up from the saddle face, and a
//  tip relief through the roof into the (empty) socket cavity above. A small floor
//  ridge at the channel mouth holds the nut from sliding back out toward the bore.
module nut_slot(p) {
    ah   = atan2(p[1], p[0]);               // this hole's angle
    rh   = stud_bcd/2;                      // hole radius
    znut_top = top_z - bnut_roof;           // nut band top  (roof above)
    znut_bot = znut_top - bnut_thk;         // nut band bottom (clamp shelf below)
    rotate([0,0, ah]) {
        // hex seat at the hole
        translate([rh, 0, znut_bot]) cylinder(d = bnut_af/cos(30), h = bnut_thk + 0.02, $fn = 6);
        // entry channel from the bore out to the pocket, minus a floor ridge near the mouth
        difference() {
            translate([0, -bnut_af/2, znut_bot]) cube([rh, bnut_af, bnut_thk + 0.02]);
            translate([bore_d/2 - 0.5, -bnut_af/2 - 0.1, znut_bot])
                cube([bnut_grip_len, bnut_af + 0.2, bnut_grip]);            // ridge = retention
        }
        // screw-shaft clearance up from below (through the saddle face) to the nut
        translate([rh, 0, -saddle_wrap - 1])
            cylinder(d = bscrew_clear, h = znut_bot + saddle_wrap + 1.2);
        // tip relief through the roof into the socket cavity (keeps the nut, frees the tip)
        translate([rh, 0, znut_top - 0.01]) cylinder(d = bscrew_clear, h = bnut_roof + 1);
    }
}

module bracket() {
    difference() {
        union() {
            base_solid();
            if (pin_mode == "thread") for (p = [A,B,C]) pin_thread(p);
            else if (pin_mode == "clip") for (p = [A,B,C]) pin_clip(p);
            // pin_mode == "screw": no pins (captive nut + separate screw)
            if (add_bayonet) bayonet_female();
        }
        if (pin_mode == "screw") for (p = [A,B,C]) nut_slot(p);
        // radial lock-screw tap hole through the ring wall
        if (add_bayonet)
            rotate([0,0, lock_angle]) translate([0,0, top_z + bay_ring_h - lock_drop])
                rotate([0,90,0]) cylinder(d = lock_tap, h = bay_ring_od/2 + 3, $fn = 24);
    }
    if (pin_mode == "screw")
        echo(str("BRACKET (screw): captive M4 nut slot, shelf ", top_z - bnut_roof - bnut_thk,
                 " mm at apex; slide nut from bore, drive 12mm M4 from inside + curved washer"));
    else
        echo(str("BRACKET (", pin_mode, "): pin ", pin_d,
                 " mm. Inner-wall z: A=", zi(A[0]), " B/C=", zi(B[0]),
                 " -> side pins ", zi(A[0])-zi(B[0]), " mm longer"));
}

// ---------------- curved head-washer (screw mode; print 3) ----------------
//  Sits between the screw head and the concave inner tube wall so the head seats
//  flush on the off-centre holes. Flat bottom (head bears), convex top (matches the
//  wall, tilted for the side holes). Same trick as the curved nut.
module head_washer() {
    intersection() {
        difference() {
            cylinder(d = washer_od, h = washer_h + washer_marg);
            translate([0,0,-1]) cylinder(d = washer_clr, h = washer_h + washer_marg + 2);
        }
        // keep only what is inside the inner-wall cylinder -> convex tilted top
        translate([wall_R*sin(washer_tilt), 0, washer_h - wall_R*cos(washer_tilt)])
            rotate([90,0,0]) cylinder(r = wall_R, h = washer_od*4, center = true, $fn = 480);
    }
    echo(str("WASHER: od ", washer_od, " hole ", washer_clr, " tilt ", washer_tilt,
             " deg (convex R ", wall_R, ") -- print tilt 0 / +13 / -13"));
}

// ---------------- C-clip (print 3) ----------------
module clip() {
    difference() {
        cylinder(d = clip_od, h = clip_thk);
        translate([0,0,-0.5]) cylinder(d = clip_bore, h = clip_thk + 1);     // groove bore
        translate([-clip_mouth/2, 0, -0.5]) cube([clip_mouth, clip_od, clip_thk + 1]); // mouth
    }
    echo(str("CLIP: od ", clip_od, " thk ", clip_thk, " bore ", clip_bore,
             " mouth ", clip_mouth, " mm (snaps onto a ", groove_d, " mm groove)"));
}

// ---------------- pins-only test piece (print before the whole bracket) ----------------
//  The 3 real pins (same geometry as the bracket), joined by a thin tie plate and
//  flipped so they print upright. Push them through the wall coupon to test the snug
//  fit + clip/nut grab before committing to the full bracket. Honours pin_mode.
module pins_test() {
    plate_t = 2.5;
    translate([0,0, top_z + plate_t]) mirror([0,0,1]) {
        hull() for (p = [A,B,C]) translate([p[0],p[1], top_z]) cylinder(d = pin_d + 7, h = plate_t);
        for (p = [A,B,C]) if (pin_mode == "thread") pin_thread(p); else pin_clip(p);
    }
    echo(str("PINS TEST (", pin_mode, "): 3 pins on a ", plate_t, " mm tie plate, printed upright"));
}

// ---------------- mock tube-wall segment (for testing) ----------------
module wall_seg() {
    difference() {
        intersection() {
            translate([0,0,-Rt]) rotate([90,0,0])
                difference() {
                    cylinder(r = Rt,     h = wall_patch_d*1.6, center = true);
                    cylinder(r = wall_R, h = wall_patch_d*1.6+2, center = true);
                }
            translate([0,0,-8]) cylinder(d = wall_patch_d, h = 10);
        }
        hole_positions() translate([0,0,-9]) cylinder(d = carbon_hole_d, h = 12);
    }
    echo(str("WALL SEGMENT: patch ", wall_patch_d, " mm, 3 holes ", carbon_hole_d, " mm"));
}

// ---------------- select ----------------
if      (part == "bracket") bracket();
else if (part == "clip")    clip();
else if (part == "pins")    pins_test();
else if (part == "washer")  head_washer();
else if (part == "wall")    wall_seg();
