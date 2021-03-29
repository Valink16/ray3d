use nalgebra_glm as glm;
use glm::TVec3;
use sfml::graphics::Color;

pub struct Light {
	pub pos: TVec3<f32>,
	pub color: Color
}

impl Light {
	pub fn new(pos: TVec3<f32>, color: Color) -> Self {
		Self {
			pos,
			color
		}
	}
}