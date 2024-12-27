Y_OFFSET = (7.5 - 3) / 2;

WIDTH = 2.6 * 25.4 + 1;
DEPTH = 3.8 * 25.4 + Y_OFFSET + 3;
HEIGHT = 6 + 7.5 + 3;

BATTERY_WIDTH = 60.3;
BATTERY_DEPTH = 49.8;
BATTERY_HEIGHT = 7.4;

SCREW_HEIGHT = 6.3;
SCREW_HEAD_DIAMETER = 4.1;
SCREW_HEAD_HEIGHT = 1.7;
SCREW_SHAFT_DIAMETER = 1.7;

module display() {
	translate([0, -Y_OFFSET, 0])
	linear_extrude(1.6)
	union() {
		difference() {
			union() {
				for (y = [-1, 1]) {
					hull() {
						for (x = [-1, 1]) {
							standoff_x = (2.4 / 2) * x * 25.4;
							standoff_y = (3.6 / 2) * y * 25.4;
							
							translate([standoff_x, standoff_y])
							circle(d = 0.2 * 25.4, $fn = 36);
						}
					}
				}
			}
			
			for (y = [-1, 1]) {
				for (x = [-1, 1]) {
					standoff_x = (2.4 / 2) * x * 25.4;
					standoff_y = (3.6 / 2) * y * 25.4;
					
					translate([standoff_x, standoff_y])
					circle(d = 0.12 * 25.4, $fn = 36);
				}
			}
		}
		
		square([2.2 * 25.4, 3.8 * 25.4], center = true);
	}
	
	translate([0, -Y_OFFSET, 0])
	color("gray")
	linear_extrude(6)
	square([56, 86], center = true);
	
	translate([0, 0, 6])
	color("blue")
	linear_extrude(0.01)
	square([50, 74], center = true);
}

module feather() {
	translate([33, 40, -10])
	rotate([0, 0, 180])
	import("5323 Feather ESP32-S3.stl");
}

module battery() { // 2500mAh
	translate([0, -19, -BATTERY_HEIGHT / 2 - 3])
	cube([BATTERY_WIDTH, BATTERY_DEPTH, BATTERY_HEIGHT], center = true);
}

module enclosure() {
	render()
	difference() {
		translate([-WIDTH / 2 - 1.5, -DEPTH / 2 - 1.5, -HEIGHT + 6 - 1.5])
		cube([WIDTH + 1.5 * 2, DEPTH + 1.5 * 2, HEIGHT + 1.5 * 2]);
		
		translate([-WIDTH / 2, -DEPTH / 2, -HEIGHT + 6 - 1.5])
		cube([WIDTH, DEPTH, HEIGHT + 1.5]);
		
		translate([0, 0, 6])
		hull() {
			translate([0, 0, 1.5])
			cube([50 + 1.5 * 2, 74 + 1.5 * 2, 0.01], center = true);
			cube([50, 74, 0.01], center = true);
		}
		
		usb_c();
		
		screws();
	}
	
	for (y = [-1, 1]) {
		for (x = [-1, 1]) {
			standoff_x = (2.4 / 2) * x * 25.4;
			standoff_y = (3.6 / 2) * y * 25.4 - Y_OFFSET;
			
			standoff_height = 6 - 1.6;
			translate([standoff_x, standoff_y, 1.6])
			render()
			difference() {
				cylinder(d = 4, h = standoff_height, $fn = 36);
				cylinder(d = 2.8, h = standoff_height, $fn = 36);
			}
		}
	}
}


module usb_c() {
	USB_C_WIDTH = 9.4;
	USB_C_DEPTH = 4;
	translate([25, 28.5, -6.7])
	rotate([90, 0, 90])
	union() {		
		for (x = [-1, 1]) {
			translate([(USB_C_WIDTH / 2 - USB_C_DEPTH / 2) * x, 0, 0])
			cylinder(d = USB_C_DEPTH, h = 20, $fn = 20);
		}
		
		translate([0, 0, 20 / 2])
		cube([USB_C_WIDTH - USB_C_DEPTH, USB_C_DEPTH, 20], center = true);
	}
}

module baseplate() {
	translate([0, 0, -HEIGHT + 6 - 1.5 / 2 - 1.5])
	render()
	difference() {
		cube([WIDTH + 1.5 * 2, DEPTH + 1.5 * 2, 1.5], center = true);
		
		translate([-25, 35, -1.5 / 2])
		cylinder(d = 7.5, h = 1.5, $fn = 36);
	}
	
	translate([0, 0, -HEIGHT + 6 - 2 / 2])
	render()
	difference() {
		cube([WIDTH, DEPTH, 2], center = true);
		cube([WIDTH - 2, DEPTH - 2, 2], center = true);
	}
	
	translate([-25, 35,  -HEIGHT + 6 - 1.5 / 2 - 1.5 / 2])
	for (y_delta = [-19 / 2, 19 / 2]) {
		translate([0, y_delta, 0])
		render()
		difference() {
			cylinder(d = 3.5, $fn = 36, h = 4);
			cylinder(d = 2.3, $fn = 36, h = 4);
		}
	}
	
	translate([-17.8, 17.15, -HEIGHT + 6 - 1.5 / 2 - 1.5])
	feather_standoffs();
	
	difference() {
		union() {
			for (x = [-WIDTH / 2, WIDTH / 2 - 5]) {
				for (y = [-DEPTH / 2, DEPTH / 2 - 2]) {
					translate([x, y, -HEIGHT + 6 - 1.5])
					cube([5, 2, 5]);
				}
			}
		}
		
		screws();
	}
}

module feather_standoffs() {
	linear_extrude(2.7) {
		for (y = [0.1 * 25.4, 0.8 * 25.4]) {
			translate([(2 - 0.1) * 25.4, y])
			difference() {
				circle(d = 3.5, $fn = 36);
				circle(d = 2.3, $fn = 36);
			}
		}
			
		for (y = [(0.9 - 0.75) / 2 * 25.4, (0.9 - 0.75) / 2 * 25.4 + (0.75 * 25.4)]) {
			translate([0.1 * 25.4, y])
			difference() {
				circle(d = 3, $fn = 36);
				circle(d = 1.8, $fn = 36);
			}
		}
	}
}

module screw() {
	rotate([90, 0, 0])
	union() {
		cylinder(d = SCREW_SHAFT_DIAMETER, h = SCREW_HEIGHT, $fn = 20);
		
		translate([0, 0, SCREW_HEIGHT - SCREW_HEAD_HEIGHT])
		cylinder(d2 = SCREW_HEAD_DIAMETER, d1 = SCREW_SHAFT_DIAMETER, h = SCREW_HEAD_HEIGHT, $fn = 20);
	}
}

module screws() {
	for (x = [-WIDTH / 2 + 5 / 2, WIDTH / 2 - 5 / 2]) {
		for (y = [-DEPTH / 2 + SCREW_HEIGHT - 1.5, DEPTH / 2 - 2 + 2 + 1.5 - SCREW_HEIGHT]) {
			angle = (y > 0) ? 180 : 0;
			
			translate([x, y, -HEIGHT + 6 - 1.5 / 2 - 1.5 + 5 / 2 + 1.5 / 2])
			rotate([angle, 0, 0])
			screw();
		}
	}
}

render() display();
feather();
battery();
enclosure();
baseplate();