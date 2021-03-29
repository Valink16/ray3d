use std::cmp::{max, min};

use glm::TVec3;
use nalgebra_glm as glm;
use sfml::graphics::Color;
use crate::ray::{self, Ray};

/// Traits for objects which can be collided with a ray therefore usable in raytracing engine
pub trait Trace {
	/// Returns a distance from the `r`'s origin where the collision occurs 
	fn trace(&self, r: &Ray) -> Option<f32>;
	fn color(&self) -> Color;
}

pub struct Sphere {
	pub pos: TVec3<f32>,
	pub radius: f32,
	pub color: Color
}

impl Sphere {
	pub fn new(pos: TVec3<f32>, radius: f32, color: Color) -> Self {
		Self {
			pos,
			radius,
			color
		}
	}
}

impl Trace for Sphere {
	fn trace(&self, r: &Ray) -> Option<f32> {
		// a, b, c coefficients of a quadratic formula
		let a = r.direction.x*r.direction.x + r.direction.y*r.direction.y + r.direction.z*r.direction.z;
		let b = 2.0 * ((r.direction.x*r.origin.x + r.direction.y*r.origin.y + r.direction.z*r.origin.z) - (r.direction.x*self.pos.x + r.direction.y*self.pos.y + r.direction.z*self.pos.z));
		let c = (self.pos.x*self.pos.x + self.pos.y*self.pos.y + self.pos.z*self.pos.z) - 2.0 * (r.origin.x*self.pos.x + r.origin.y*self.pos.y + r.origin.z*self.pos.z) + (r.origin.x*r.origin.x + r.origin.y*r.origin.y + r.origin.z*r.origin.z) - self.radius*self.radius;
		let delta = b*b - 4.0 * a * c;

		let pres = 0.001;

		if delta >= 0.0 {
			let sq_delta = delta.sqrt();
			// Return the smallest of roots which are positive
			let t1 = (-b - sq_delta) / (2.0 * a);
			let t2 = (-b + sq_delta) / (2.0 * a);
			
			if t1 > pres && t2 > pres {
				Some(t1)
			} else if t1.max(t2) > pres {
				Some(t1.max(t2))
			} else {
				None
			}
		} else {
			None
		}
	}

	fn color(&self) -> Color {
		self.color
	}
}
