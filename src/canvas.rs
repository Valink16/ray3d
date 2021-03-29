use std::{time::{Instant, Duration}};

use log::{debug, info, error, warn, trace};
use nalgebra_glm as glm;
use glm::{TVec2, Vec3, scale2d};
use sfml::{graphics::{Drawable, RenderStates, RenderTarget, RenderTexture, Sprite, Transform, Vertex, VertexArray}, system::Vector2f};

use crate::{light, ray::Ray};
use crate::geom::Trace;
use crate::light::Light;

/// An object abstracting the raytracing renderer used to manage the rays, objects, lights, etc.
/// 2D arrays are all stored in row-major in 1D arrays (rays, pixels)
pub struct Canvas{
	/// Resolution of the canvas (not on screen resolution)
	pub res: TVec2<usize>,
	/// Horizontal field of view
	pub fov: f32,
	/// Stores the rays
	rays: Vec<Ray>,
	/// Objects in the scene
	pub objects: Vec<Box<dyn Trace>>,
	/// Lights in the scene
	pub lights: Vec<Light>,
	/// SFML window
	pub window: sfml::graphics::RenderWindow,
	/// Vertex array storing pixel data
	pixels: VertexArray,
	/// Texture storing unscaled canvas image output
	out: RenderTexture,
	/// Scale of the image image output, for example a scale of (2; 2) means the canvas resolution will be 2 times smaller than the window resolution 
	pub scale: TVec2<f32>,
}

impl Canvas {
	/// Create a new canvas
	pub fn new(res: TVec2<usize>, fov: f32, window: sfml::graphics::RenderWindow, objects: Vec<Box<dyn Trace>>, lights: Vec<Light>) -> Self {

		let mut rays = Vec::<Ray>::new();
		set_rays(res, fov, &mut rays);
		
		let pixels = create_vbuffer(res);

		let out = RenderTexture::new(res.x as u32, res.y as u32, false)
			.expect("Failed to create texture for Canvas output");

		// Compute scale for canvas
		let scale = TVec2::new(window.size().x as f32 / res.x as f32, window.size().y as f32 / res.y as f32);
		
		Self {
			res,
			fov,
			rays,
			window,
			objects,
			lights,
			pixels,
			out,
			scale,
		}
	}

	/// Renders the scene and returns the draw time and ray times as (f32, f32)
	pub fn render(&mut self) -> (f32, f32) {
		let draw_start = Instant::now();

		let ray_start = Instant::now();
		for (i, r) in self.rays.iter().enumerate() {
			self.pixels[i].color = r.get_color(&self.objects, &self.lights);
		}
		let ray_t = ray_start.elapsed();

		self.pixels.draw(&mut self.out, Default::default());
		self.out.display();

		let sprite = Sprite::with_texture(self.out.texture());
		let mut scaled_state = RenderStates::default();
		scaled_state.transform.scale(self.scale.x, self.scale.y);
		sprite.draw(&mut self.window, scaled_state);
		
		self.window.display();

		(draw_start.elapsed().as_secs_f32(), ray_t.as_secs_f32())
	}
	
	/// Resets the rays and scalars, should be used whenever `self.res` is changed or window is resized
	pub fn reset(&mut self) {
		set_rays(self.res, self.fov, &mut self.rays);
		self.pixels = create_vbuffer(self.res);
		self.out = RenderTexture::new(self.res.x as u32, self.res.y as u32, false)
			.expect("Failed to create texture for Canvas output");
	}
}

/// Resets and fills the rays vector with `ray::Ray` objects
/// Computes the rays assuming position at origin and camera directed to the positive z axis depending on FOV and resolution
fn set_rays(res: TVec2<usize>, fov: f32, rays: &mut Vec<Ray>) {
	rays.clear();

	let depth = ((fov / 2.0).cos() * res.x as f32) / (2.0 * (fov / 2.0)); // Trigo properties
	debug!("Setting rays with depth {}", depth);

	for y in ((-(res.y as isize) / 2)..(res.y as isize - (res.y as isize ) / 2)).rev() {
		let yf = y as f32;

		for x in (-(res.x as isize) / 2)..(res.x as isize - (res.x as isize) / 2) {
			let dir_vector = glm::normalize(&Vec3::new(x as f32, yf, depth));
			// trace!("Creating ray with dir {}, {}, {}", dir_vector.x, dir_vector.y, dir_vector.z);
			rays.push(Ray::new(
				Vec3::new(0.0, 0.0, 0.0),
				dir_vector
			));
		}
	}
	debug!("Created {} rays", rays.len());
}

// Creates the the VertexArray  positions depending on the resolution
fn create_vbuffer(res: TVec2<usize>) -> VertexArray {
	let mut arr = VertexArray::new(sfml::graphics::PrimitiveType::Points, res.x * res.y);
	debug!("Current resolution is: {:?}", res);
	debug!("Current vertex buffer size is: {}", arr.vertex_count());

	for i in 0..arr.vertex_count() {
		let y = (i / res.x) as f32 + 0.5;
		let x = (i % res.x) as f32 + 0.5;

		let new_pos = Vector2f::new(x , y);
		let new_color = sfml::graphics::Color::rgb(
			0,
			255,
			0
		);

		arr[i] = Vertex::new(new_pos, new_color, Vector2f::default());

		// trace!("Position: {:?}; Color: {:?}; x: {}; y: {}", arr[i].position, arr[i].color, x, y);
	}

	debug!("Buttom right point: Color: {:?}; Position: {:?}", arr[arr.vertex_count() - 1].color, arr[arr.vertex_count() - 1].position);
	arr
}