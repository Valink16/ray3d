use std::cmp::{max, min};
use log::{debug, info, error, warn, trace};

use glm::Vec3;
use nalgebra_glm as glm;
use sfml::graphics::Color;
use crate::ray::{self, Ray};

/// Traits for objects which can be collided with a ray therefore usable in raytracing engine
pub trait Trace {
	/// Returns a distance from the `r`'s origin where the collision occurs 
	fn trace(&self, r: &Ray) -> Option<f32>;
	fn pos(&self) -> Vec3;
	fn color(&self) -> Color;
	fn mut_pos(&mut self) -> &mut Vec3;
	fn mut_color(&mut self) -> &mut Color;
}

pub struct Sphere {
	pub pos: Vec3,
	pub radius: f32,
	pub color: Color
}

impl Sphere {
	pub fn new(pos: Vec3, radius: f32, color: Color) -> Self {
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

		if delta >= 0.0 {
			let sq_delta = delta.sqrt();

			let t1 = (-b - sq_delta) / (2.0 * a);
			let t2 = (-b + sq_delta) / (2.0 * a);

			let prec = 10e-5;

			if t1 > prec {
				Some(t1)
			} else if t2 > prec {
				Some(t2)
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

	fn pos(&self) -> Vec3 {
		self.pos
	}

	fn mut_color(&mut self) -> &mut Color {
		&mut self.color
	}

	fn mut_pos(&mut self) -> &mut Vec3 {
		&mut self.pos
	}
}
