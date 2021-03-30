use nalgebra_glm as glm;
use glm::Vec3;
use sfml::graphics::Color;

pub struct Light {
	pub position: Vec3,
	pub color: Color
}

impl Light {
	pub fn new(position: Vec3, color: Color) -> Self {
		Self {
			position,
			color
		}
	}
}