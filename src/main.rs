mod ray;
mod canvas;
mod geom;
mod light;

use light::Light;
use log::{debug, info, error, warn, trace};
use sfml::{self, graphics::{Color, Rect, RenderTarget}};
use sfml::window::Event;
use env_logger;

use core::f32;
use std::{f64::consts::PI, usize};
use nalgebra_glm as glm;
use glm::{TVec2, TVec3};

use geom::{Trace, Sphere};

const SCALE: usize = 1;
fn main() {
    env_logger::init();

    let mut objects = Vec::<Box<dyn Trace>>::new();
    let mut lights = Vec::<Light>::new();

    let s1 = Sphere::new(TVec3::new(-1.0, 0.0, 20.0), 2.0, Color::BLUE);
    let s2 = Sphere::new(TVec3::new(1.0, 0.0, 20.0), 2.0, Color::GREEN);
    objects.push(Box::new(s1));
    objects.push(Box::new(s2));

    lights.push(Light::new(TVec3::new(0.0, 0.0, 10.0), Color::WHITE));

    let window = sfml::graphics::RenderWindow::new((800, 600), "Ray 3D", Default::default(), &Default::default());
    let mut canvas = canvas::Canvas::new(TVec2::new(800, 600) / SCALE, PI as f32 / 2.0, window, objects, lights);

    let mut clock = sfml::system::Clock::start();
    let mut f = 0;
    let mut avg_fps = 0.0;
    let mut rt = 0.0;
    let mut ray_t = 0.0;
    'running: loop {
        f += 1;

        while let Some(ev) = canvas.window.poll_event() {
            match ev {
                Event::Closed => break 'running,
                Event::Resized {width, height} => on_resize(&mut canvas, width as usize, height as usize),
                _ => ()
            }
        }

        let _tmp = canvas.render();
        rt += _tmp.0;
        ray_t += _tmp.1;
        
        let dt = clock.restart();
        avg_fps += dt.as_seconds();
        if f % 60 == 0 {
            let fps = 1.0 / (avg_fps / 60.0);
            let avg_rt = rt / 60.0;
            let avg_ray_t = ray_t / 60.0;
            avg_fps = 0.0;
            rt = 0.0;
            ray_t = 0.0;
            trace!("FPS: {}, DT: {}, Ray time: {}", fps, avg_rt, avg_ray_t);
        }

    }
}

fn on_resize(c: &mut canvas::Canvas, width: usize, height: usize) {
    c.res = TVec2::new(width as usize, height as usize) / SCALE;
    c.reset();

    let new_view = Rect::new(0.0, 0.0, width as f32, height as f32);
    c.window.set_view(&sfml::graphics::View::from_rect(&new_view));
}