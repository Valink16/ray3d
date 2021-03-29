use sfml::{self, graphics::Color};
use log::{debug, info, error, warn, trace};
use nalgebra_glm as glm;
use glm::{Vec3};

use rand::{self, Rng};

use crate::{geom::Trace, light::Light};

/// Object representing a ray, can be used to compute collisions with objects
pub struct Ray {
	/// Origin point of the ray
	pub origin: Vec3,
	/// Direction of the ray
	pub direction: Vec3
}

impl Ray {
	/// Creates and returns a ray
	pub fn new(origin: Vec3, direction: Vec3) -> Self {
		Self {
			origin,
			direction
		}
	}

	/// Computes the color for the ray
	pub fn get_color(&self, objects: &Vec<Box<dyn Trace>>, lights: &Vec<Light>) -> Color {
		let mut closest_o: Option<&Box<dyn Trace>> = None;
		let mut closest_d = f32::MAX;
		for o in objects.iter() {
			if let Some(d) = o.trace(&self) {
				if d < closest_d {
					closest_d = d;
					closest_o = Some(o);
				}
			}
		}

		if let Some(o) = closest_o {
			o.color()
		} else {
			Color::BLACK
		}
	}
}