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
			// trace!("Impact @ {}", closest_d);
			let impact_point = closest_d * self.direction;
			self.light(impact_point, objects, lights) - (Color::WHITE - o.color())
		} else {
			Color::BLACK
		}
	}

	fn light(&self, impact_point: Vec3, objects: &Vec<Box<dyn Trace>>, lights: &Vec<Light>) -> Color {
		let mut final_color = Color::BLACK; // This will contain the added color from potential multiple lights

		'light_loop: for l in lights.iter() {
			let to_light = l.position - impact_point;
			let ray_to_light = Ray::new(impact_point, to_light);

			for o in objects.iter() {
				if let Some(d) = o.trace(&ray_to_light) { // Trace to light, if there's an object in between, that's a shadow
					continue 'light_loop;
				}
			}

			final_color += l.color;
		}

		final_color
	}
}